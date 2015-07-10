//
//  MaxProgramCountRequest.m
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramSyncManager.h"

@interface FOCProgramSyncManager ()

@property CBCharacteristic *controlCmdRequest;
@property CBCharacteristic *controlCmdResponse;
@property CBCharacteristic *dataBuffer;

@property Byte lastSubCmd;
@property int programCount;
@property int currentProgram;

@property NSData* firstDescriptor;
@property NSData* secondDescriptor;

@end

@implementation FOCProgramSyncManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer
{
    _controlCmdRequest = controlCmdRequest;
    _controlCmdResponse = controlCmdResponse;
    _dataBuffer = dataBuffer;
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_MAX_PROGRAMS];
    
    [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
    
    _lastSubCmd = FOC_SUBCMD_MAX_PROGRAMS;
    
    NSLog(@"Writing %@", [self loggableCharacteristicName:_controlCmdRequest]);
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    if (error == nil) {
        if ([FOC_CONTROL_CMD_RESPONSE isEqualToString:characteristic.UUID.UUIDString]) {
            [self interpretCommandResponse:characteristic]; // read response buffer data
        }
        else if ([FOC_DATA_BUFFER isEqualToString:characteristic.UUID.UUIDString]) {
            [self interpretDataBuffer:characteristic];
        }
        else {
            NSLog(@"Program sync manager encountered unknown udpate value characteristic %@", [self loggableCharacteristicName:characteristic]);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    
    if (error == nil) {
        if ([FOC_CONTROL_CMD_REQUEST isEqualToString:characteristic.UUID.UUIDString]) {
            [peripheral readValueForCharacteristic:_controlCmdResponse]; // read the response buffer
        }
        else {
            NSLog(@"Program Sync Manager failed to handle update to %@", [self loggableCharacteristicName:characteristic]);
        }
    }
}

#pragma mark - deserialisation

- (NSData *)constructCommandRequest:(Byte)cmdId subCmdId:(Byte)subCmdId
{
    return [self constructCommandRequest:cmdId subCmdId:subCmdId progId:FOC_EMPTY_BYTE progDescId:FOC_EMPTY_BYTE];
}

- (NSData *)constructCommandRequest:(Byte)cmdId subCmdId:(Byte)subCmdId progId:(Byte)progId progDescId:(Byte)progDescId
{
    const unsigned char bytes[] = {cmdId, subCmdId, progId, progDescId, FOC_EMPTY_BYTE};
    NSLog(@"{cmdId=%hhu, subCmdId=%hhu, progId=%hhu, progDescId=%hhu, lastByte=%hhu}", cmdId, subCmdId, progId, progDescId, FOC_EMPTY_BYTE);
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];;
}

- (void)interpretCommandResponse:(CBCharacteristic *)characteristic
{
    NSData *data = characteristic.value;
    
    if (data != nil) {
        int length = [data length];
        
        Byte *bd = (Byte*)malloc(length);
        memcpy(bd, [data bytes], length);
        
        Byte cmdId = bd[0];
        Byte status = bd[1];
        
        const unsigned char data[] = {bd[2], bd[3], bd[4], bd[5]};
        free(bd);
        
        if (status == FOC_STATUS_CMD_SUCCESS && FOC_CMD_MANAGE_PROGRAMS == cmdId) {

            // Handles Program sync callbacks.
            
            if (FOC_SUBCMD_MAX_PROGRAMS == _lastSubCmd) {
                _programCount = data[0];
                
                NSLog(@"========================================");
                NSLog(@"*****Beginning sync of %d programs*****", _programCount);
                
                // Only begin syncing process if there remain unsynced programs
                if (_currentProgram <= _programCount) {
                    [self checkCurrentProgramEnabled];
                }
            }
            else if (FOC_SUBCMD_PROG_STATUS == _lastSubCmd) {
                int progStatus = data[0];
                
                if (FOC_PROG_STATUS_VALID == progStatus) {
                    [self writeProgramDescriptor:FOC_PROG_DESC_FIRST];
                }
                else {
                    NSLog(@"Program %d status is not valid, skipping", _currentProgram);
                    _currentProgram++;
                    [self checkCurrentProgramEnabled];
                }
            }
            else if (FOC_SUBCMD_READ_PROG == _lastSubCmd) {
                [self readProgramDescriptorBuffer];
            }
        }
        else if (status == FOC_STATUS_CMD_FAILURE) {
            NSLog(@"Command resulted in failure for Command %hhu with characteristic %@", cmdId, [self loggableCharacteristicName:characteristic]);
        }
        else if (status == FOC_STATUS_CMD_UNSUPPORTED) {
            NSLog(@"Command %hhu unsupported for characteristic %@", cmdId, [self loggableCharacteristicName:characteristic]);
        }
        else {
            NSLog(@"Failed to handle control command response");
        }
    }
    else {
        [self.delegate didFinishProgramSync:
         [[NSError alloc] initWithDomain:FOCUS_ERROR_DOMAIN code:0 userInfo:nil]];
    }
}

-(void)interpretDataBuffer:(CBCharacteristic *)characteristic
{
    NSData *data = characteristic.value;
    
    if (_firstDescriptor == nil) { // retrieve second descriptor before proceeding
        _firstDescriptor = data;
        NSLog(@"Retrieving second descriptor.");
        [self writeProgramDescriptor:FOC_PROG_DESC_SECOND];
    }
    else {
        _secondDescriptor = data;
        
        // deserialise first descriptor
        int length = [_firstDescriptor length];
    
        Byte *fd = (Byte*)malloc(length);
        memcpy(fd, [_firstDescriptor bytes], length);
    
        bool valid = fd[0];
        int mode = fd[10];
        bool sham = fd[13];
        
        NSData *durationData = [_firstDescriptor subdataWithRange:NSMakeRange(11, 2)];
        NSData *shamDurationData = [_firstDescriptor subdataWithRange:NSMakeRange(14, 2)];
        NSData *currentData = [_firstDescriptor subdataWithRange:NSMakeRange(16, 2)];
        NSData *currentOffset = [_firstDescriptor subdataWithRange:NSMakeRange(18, 2)];
        
        int nameLength = 0;
        
        for (int i=1; i<=9; i++) {
            if (fd[i] != FOC_EMPTY_BYTE) { // don't want to include empty bytes
                nameLength++;
            }
            else {
                break;
            }
        }
        NSData *nameData = [_firstDescriptor subdataWithRange:NSMakeRange(1, nameLength)];
        
        
        
        free(fd);
        
        // deserialise second descriptor
        length = [_secondDescriptor length];
        
        Byte *sd = (Byte*)malloc(length);
        memcpy(sd, [_secondDescriptor bytes], length);
        
        Byte volt = sd[0];
        bool bipolar = sd[1];
        bool randomCurrent = sd[10];
        bool randomFreq = sd[11];

        NSData *frequencyData = [_secondDescriptor subdataWithRange:NSMakeRange(2, 4)];
        NSData *dutyCycle = [_secondDescriptor subdataWithRange:NSMakeRange(6, 4)];
        
        free(sd);
        
        // handle deserialised data
        
//        const unsigned char terminator[] = {'\0'};
//        NSMutableData *data = [[NSMutableData alloc] init];
//        
//        [data appendBytes:terminator length:1];
//        
//        NSLog(@"Program bytes %@", data);
        NSString *programName = [[NSString alloc] initWithBytes:nameData.bytes length:nameData.length encoding:NSUTF8StringEncoding];
        NSLog(@"Program bytes %@", nameData);
        
        NSLog(@"*****Finished sync for program '%@'*****", programName);
        NSLog(@"========================================");
        
        _currentProgram++;
        [self checkCurrentProgramEnabled]; // continue iterating over available programs
    }
}

/**
 * Initiates the syncing process for one program, which involves the following:
 *
 * 1. Check if program status is valid, if not skip to the next program.
 * 2. Write program descriptor[0] to the data buffer & deserialise contents.
 * 3. Write program descriptor[1] to the data buffer & deserialise contents.
 */
-(void)checkCurrentProgramEnabled
{
    if (_currentProgram < _programCount) {
        _firstDescriptor = nil;
        _secondDescriptor = nil;
        
        NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_PROG_STATUS];
        
        _lastSubCmd = FOC_SUBCMD_PROG_STATUS;
        
        [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
    }
    else {
        NSLog(@"Finishing program sync!");
        [self.delegate didFinishProgramSync:nil];
    }
}

/**
 * Writes the first program descriptor to the data buffer.
 */
-(void)writeProgramDescriptor:(Byte)progDescId
{
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_READ_PROG progId:_currentProgram progDescId:progDescId];

    _lastSubCmd = FOC_SUBCMD_READ_PROG;
    
    [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

/**
 * Reads the program descriptor from the data buffer (assumes a write command has been called before)
 */
-(void)readProgramDescriptorBuffer
{
    [self.focusDevice readValueForCharacteristic:_dataBuffer];
}


@end
