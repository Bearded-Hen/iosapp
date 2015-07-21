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
    else if ([FOC_ACTUAL_CURRENT isEqualToString:characteristic.UUID.UUIDString]) {
        int current = [FOCDeviceProgramEntity getIntegerFromBytes:characteristic.value].intValue;
        [_delegate didReceiveCurrentNotification:current];
    }
    else if ([FOC_ACTIVE_MODE_DURATION isEqualToString:characteristic.UUID.UUIDString]) {
        int duration = [FOCDeviceProgramEntity getIntegerFromBytes:characteristic.value].intValue;
        [_delegate didReceiveDurationNotification:duration];
    }
    else if ([FOC_ACTIVE_MODE_REMAINING_TIME isEqualToString:characteristic.UUID.UUIDString]) {
        int remainingTime = [FOCDeviceProgramEntity getIntegerFromBytes:characteristic.value].intValue;
        [_delegate didReceiveRemainingTimeNotification:remainingTime];
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
        if (FOC_STATUS_CMD_SUCCESS == status) {
            NSLog(@"Program request success"); // TODO device manager callback
        }
        else if (FOC_STATUS_CMD_FAILURE == status) { // TODO check whether failure is ok for stopping program
            NSLog(@"Program request failure");
        }
        else if (FOC_STATUS_CMD_UNSUPPORTED == status) {
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
    NSLog(@"Command response error %@", error);
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

- (void)startNotificationListeners:(CBPeripheral *)focusDevice
{
    [focusDevice setNotifyValue:true forCharacteristic:_cm.actualCurrent];
    [focusDevice setNotifyValue:true forCharacteristic:_cm.activeModeDuration];
    [focusDevice setNotifyValue:true forCharacteristic:_cm.activeModeRemainingTime];
}

#pragma mark CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Updated notification listen state to %hhd for characteristic %@",
          characteristic.isNotifying, [self loggableCharacteristicName:characteristic]);
}

@end
