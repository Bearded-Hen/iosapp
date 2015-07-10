//
//  FOCBasePeripheralManager.m
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCBasePeripheralManager.h"

@interface FOCBasePeripheralManager ()
@end

@implementation FOCBasePeripheralManager

- (id)initWithPeripheral:(CBPeripheral *) focusDevice
{
    if (self = [super init]) {
        _focusDevice = focusDevice;
    }
    return self;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service '%@'", [self loggableServiceName:service]);
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    if (error != nil) {
        NSLog(@"Error listing characteristics for service, %@", error);
    }
    else {
        NSLog(@"Listing characteristics for service %@", [self loggableServiceName:service]);
        
        for (CBCharacteristic* characteristic in service.characteristics) {
            NSLog(@"Characteristic '%@'", [self loggableCharacteristicName:characteristic]);
        }
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    if (error != nil) {
        
        NSString *characteristicName = [self loggableCharacteristicName:characteristic];
        
        if (error.code == CBATTErrorReadNotPermitted) {
            NSLog(@"Error updating characteristic '%@', read not permitted!", characteristicName);
        }
        else if (error.code == CBATTErrorWriteNotPermitted) {
            NSLog(@"Error updating characteristic '%@', write not permitted!", characteristicName);
        }
        else if (error.code == CBATTErrorInsufficientAuthentication) {
            NSLog(@"Insufficient authentication when attempting to update characteristic '%@'", characteristicName);
        }
        else if (error.code == CBATTErrorInsufficientEncryption) {
            NSLog(@"Insufficient encryption when attempting to update characteristic '%@'", characteristicName);
        }
        else {
            NSLog(@"General CBATT Error updating characteristic '%@' %@", characteristicName, error);
        }
    }
    else {
        NSLog(@"Characteristic '%@' was updated to value %@", [self loggableCharacteristicName:characteristic], characteristic.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Wrote characteristic '%@' %@", [self loggableCharacteristicName:characteristic], error);
}

#pragma mark - Logging code

- (NSString *)loggableServiceName:(CBService *)service
{
    NSString *name;
    
    if ([service.UUID.UUIDString isEqualToString:BLE_SERVICE_BATTERY]) {
        name = @"BLE Device Battery";
    }
    else if ([service.UUID.UUIDString isEqualToString:BLE_SERVICE_INFO]) {
        name = @"BLE Device Info";
    }
    else if ([service.UUID.UUIDString isEqualToString:FOC_SERVICE_TDCS]) {
        name = @"TDCS Service";
    }
    else if ([service.UUID.UUIDString isEqualToString:FOC_SERVICE_UNKNOWN]) {
        name = @"Unknown Focus Service";
    }
    else {
        name = service.UUID.UUIDString;
    }
    return name;
}

- (NSString *)loggableCharacteristicName:(CBCharacteristic *)characteristic
{
    NSString *name;
    
    if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_REQUEST]) {
        name = @"Control Command Request";
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_RESPONSE]) {
        name = @"Control Command Response";
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:FOC_DATA_BUFFER]) {
        name = @"Data Buffer";
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:FOC_ACTUAL_CURRENT]) {
        name = @"Actual Current";
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:FOC_ACTIVE_MODE_DURATION]) {
        name = @"Active Mode Duration";
    }
    else if ([characteristic.UUID.UUIDString isEqualToString:FOC_ACTIVE_MODE_REMAINING_TIME]) {
        name = @"Active Mode Remaining Time";
    }
    else {
        name = characteristic.UUID.UUIDString;
    }
    return name;
}

@end
