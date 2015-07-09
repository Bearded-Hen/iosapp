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

@end

@implementation FOCProgramSyncManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer
{
    _controlCmdRequest = controlCmdRequest;
    _controlCmdResponse = controlCmdResponse;
    _dataBuffer = dataBuffer;
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_MAX_PROGRAMS progId:FOC_EMPTY_BYTE progDescId:FOC_EMPTY_BYTE];
    
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

- (NSData *)constructCommandRequest:(Byte)cmdId subCmdId:(Byte)subCmdId progId:(Byte)progId progDescId:(Byte)progDescId
{
    const unsigned char bytes[] = {cmdId, subCmdId, progId, progDescId, FOC_EMPTY_BYTE};
    NSLog(@"Preparing byte array: {cmdId=%hhu, subCmdId=%hhu, progId=%hhu, progDescId=%hhu, lastByte=%hhu}", cmdId, subCmdId, progId, progDescId, FOC_EMPTY_BYTE);
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];;
}

- (void) interpretCommandResponse:(CBCharacteristic *)characteristic
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
            // continue interpretation
            
            if (FOC_SUBCMD_MAX_PROGRAMS == _lastSubCmd) {
                int progCount = data[0];
                NSLog(@"Beginning sync of %d programs", progCount);
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




@end
