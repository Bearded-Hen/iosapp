//
//  ProgramRequestManager.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramRequestManager.h"

static const int kTimeoutSeconds = 3;

@interface FOCProgramRequestManager ()

@property bool requestProgramStart;
@property bool requestProgramStop;
@property bool hasSentStartRequest;
@property long lastNotificationInterval;

@end

@implementation FOCProgramRequestManager

- (id)initWithPeripheral:(CBPeripheral *)focusDevice
{
    if (self = [super initWithPeripheral:focusDevice]) {
        _lastNotificationInterval = 0;
    }
    return self;
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    // need to interpret
    if ([FOC_CONTROL_CMD_RESPONSE isEqualToString:characteristic.UUID.UUIDString]) {
        [self deserialiseCommandResponse:characteristic]; // read response buffer data
    }
    else {
        _lastNotificationInterval = [[[NSDate alloc] init] timeIntervalSince1970];;
        
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
    NSError *error = (FOC_STATUS_CMD_SUCCESS == status) ? nil : [[NSError alloc] initWithDomain:FOCUS_ERROR_DOMAIN code:0 userInfo:nil];
    [_delegate didAlterProgramState:self.activeProgram playing:false error:error];
}

- (void)handleStartResponse:(Byte)status
{
    if (_hasSentStartRequest) {
        NSError *error = (FOC_STATUS_CMD_SUCCESS == status) ? nil : [[NSError alloc] initWithDomain:FOCUS_ERROR_DOMAIN code:0 userInfo:nil];
        
        [_delegate didAlterProgramState:_activeProgram playing:true error:error];
    }
    else { // failure doesn't matter if no program was playing in the first place
        if (FOC_STATUS_CMD_SUCCESS == status || FOC_STATUS_CMD_FAILURE) {
            [self sendProgramStartRequest];
        }
        else {
            NSLog(@"Unsupported operation attempting to start program");
        }
    }
}

- (void)sendProgramStartRequest
{
    NSLog(@"Requesting program start");
    Byte programId = _activeProgram.programId.intValue;
    _hasSentStartRequest = true;
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_START_PROG progId:programId progDescId:FOC_EMPTY_BYTE];
    [self.focusDevice writeValue:data forCharacteristic:_cm.controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

- (void)sendProgramStopRequest
{
    NSLog(@"Requesting program stop");
    
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_STOP_PROG];
    [self.focusDevice writeValue:data forCharacteristic:_cm.controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

- (void)interpretCommandResponse:(NSError *)error
{
    // FIXME handle error
    NSLog(@"Command response error %@", error);
}

- (void)startProgram:(FOCDeviceProgramEntity *)program
{
    _activeProgram = program;
    _requestProgramStart = true;
    
    long diff = [[[NSDate alloc] init ] timeIntervalSince1970] - _lastNotificationInterval;
    
    if (_lastNotificationInterval == 0) {
        diff = 0;
    }
    
    if (diff > kTimeoutSeconds) { // if no notifications in 3s, program is stopped or disconnected
        [self stopActiveProgram];
    }
    else {
        [self sendProgramStartRequest];
    }
}

- (void)stopActiveProgram
{
    _activeProgram = nil;
    _requestProgramStop = true;
    [self sendProgramStopRequest];
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
