//
//  ProgramRequestManager.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramRequestManager.h"

@implementation FOCProgramRequestManager

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

- (void)startProgram:(FOCDeviceProgramEntity *)program
{
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_START_PROG];
    [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

- (void)stopProgram:(FOCDeviceProgramEntity *)program
{
    NSData *data = [self constructCommandRequest:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_STOP_PROG];
    [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
}

@end
