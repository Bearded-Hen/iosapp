//
//  ProgramRequestManager.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramRequestManager.h"

@interface FOCProgramRequestManager ()

@property FOCDeviceProgramEntity *startProgram;

@end

@implementation FOCProgramRequestManager

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    // need to interpret
    if ([FOC_CONTROL_CMD_RESPONSE isEqualToString:characteristic.UUID.UUIDString]) {
        [self deserialiseCommandResponse:characteristic]; // read response buffer data
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    [self.focusDevice readValueForCharacteristic:_cm.controlCmdResponse]; // read to check success
}

- (void)interpretCommandResponse:(Byte)cmdId status:(Byte)status data:(const unsigned char *)data characteristic:(CBCharacteristic *)characteristic
{
    if (FOC_CMD_MANAGE_PROGRAMS == cmdId) {
        if (FOC_STATUS_CMD_SUCCESS) {
            NSLog(@"Program request success"); // TODO device manager callback
            
            
        }
        else if (FOC_STATUS_CMD_FAILURE) { // TODO check whether failure is ok for stopping program
            NSLog(@"Program request failure");
        }
        else if (FOC_STATUS_CMD_UNSUPPORTED) {
            NSLog(@"Program request UNSUPPORTED");
        }
        
        if (_startProgram != nil) { // start requested program
            NSLog(@"Requesting program start");
            
            Byte programId = _startProgram.programId.intValue;
            _startProgram = nil;
            
            NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_START_PROG progId:programId progDescId:FOC_EMPTY_BYTE];
            [self.focusDevice writeValue:data forCharacteristic:_cm.controlCmdRequest type:CBCharacteristicWriteWithResponse];
        }
        else {
            NSLog(@"FINISHED"); // TODO device manager callback
        }
    }
    else {
        NSLog(@"Unrecognised command sent to program request manager");
    }
}

- (void)interpretCommandResponse:(NSError *)error
{
    // FIXME handle error
}

- (void)startProgram:(FOCDeviceProgramEntity *)program
{
    _startProgram = program;
    [self stopActiveProgram];
}

- (void)stopActiveProgram
{
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_STOP_PROG];
    [self.focusDevice writeValue:data forCharacteristic:_cm.controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

@end
