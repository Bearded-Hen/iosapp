//
//  ProgramRequestManager.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramRequestManager.h"

@interface FOCProgramRequestManager ()

@property bool requestProgramStart;
@property bool requestProgramStop;
@property bool hasSentStartRequest;

@end

@implementation FOCProgramRequestManager

- (void)interpretCommandResponse:(Byte)cmdId status:(Byte)status data:(const unsigned char *)data characteristic:(CBCharacteristic *)characteristic
{
    if (FOC_CMD_MANAGE_PROGRAMS == cmdId) {
        
        if (_requestProgramStop) {
            [self handleStopResponse:status];
        }
        else if (_requestProgramStart) {
            [self handleStartResponse:status];
        }
        else {
            NSLog(@"Unknown command response sent to Program Request Manager");
        }
    }
    else {
        NSLog(@"Unrecognised command sent to program request manager");
    }
}

- (void)handleStopResponse:(Byte)status
{
    bool playing = !(FOC_STATUS_CMD_SUCCESS == status);
    _requestProgramStop = false;
    
    NSError *error = !playing ? nil : [[NSError alloc] initWithDomain:FOCUS_ERROR_DOMAIN code:0 userInfo:nil];
    [_delegate didAlterProgramState:playing error:error];
}

- (void)handleStartResponse:(Byte)status
{
    bool playing = (FOC_STATUS_CMD_SUCCESS == status);
    _requestProgramStart = false;
    
    NSError *error = playing ? nil : [[NSError alloc] initWithDomain:FOCUS_ERROR_DOMAIN code:0 userInfo:nil];
        
    [_delegate didAlterProgramState:playing error:error];
    NSLog(@"Received start response, playing=%d", playing);
}

- (void)interpretCommandResponse:(NSError *)error
{
    NSLog(@"Command response error %@", error);
}

- (void)startProgram:(FOCDeviceProgramEntity *)program
{
    Byte programId = [FOCDeviceProgramEntity byteFromInt:_activeProgram.programId.intValue];
    NSLog(@"Requesting play for program %d", programId);
    
    _activeProgram = program;
    _requestProgramStart = true;
    _requestProgramStop = false;
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_START_PROG progId:programId progDescId:FOC_EMPTY_BYTE];
    
    [self.focusDevice writeValue:data forCharacteristic:_cm.controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

- (void)stopActiveProgram
{
    NSLog(@"Requesting program stop");
    Byte programId = [FOCDeviceProgramEntity byteFromInt:_activeProgram.programId.intValue];
    
    _activeProgram = nil;
    _requestProgramStart = false;
    _requestProgramStop = true;
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_STOP_PROG progId:programId progDescId:FOC_EMPTY_BYTE];
    
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

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    // need to interpret
    if ([FOC_CONTROL_CMD_RESPONSE isEqualToString:characteristic.UUID.UUIDString]) {
        [self deserialiseCommandResponse:characteristic]; // read response buffer data
    }
    else {
        if ([FOC_ACTUAL_CURRENT isEqualToString:characteristic.UUID.UUIDString]) {
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
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    [self.focusDevice readValueForCharacteristic:_cm.controlCmdResponse]; // read to check success
}

@end
