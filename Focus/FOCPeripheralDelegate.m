//
//  FOCPeripheralDelegate.m
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCPeripheralDelegate.h"

#import "FocusConstants.h"

@interface FOCPeripheralDelegate ()

@property CBPeripheral *focusDevice;

@property CBCharacteristic *controlCmdResponse;
@property CBCharacteristic *controlCmdRequest;

@end

@implementation FOCPeripheralDelegate


- (id)initWithPeripheral:(CBPeripheral *) focusDevice
{
    if (self = [super init]) {
        _focusDevice = focusDevice;
    }
    return self;
}

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


#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    for (CBService *service in self.focusDevice.services) {
        NSLog(@"Discovered service '%@'", [self loggableServiceName:service]);
        
        NSMutableArray *desiredCharacteristics = [[NSMutableArray alloc] init];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_CONTROL_CMD_REQUEST]];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_CONTROL_CMD_RESPONSE]];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_DATA_BUFFER]];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_ACTUAL_CURRENT]];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_ACTIVE_MODE_DURATION]];
        [desiredCharacteristics addObject:[CBUUID UUIDWithString:FOC_ACTIVE_MODE_REMAINING_TIME]];
        
        [self.focusDevice discoverCharacteristics:desiredCharacteristics forService:service];
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
            //            [peripheral readValueForCharacteristic:characteristic];
            
            if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_REQUEST]) {
                _controlCmdRequest = characteristic;
            }
            
            if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_RESPONSE]) {
                _controlCmdResponse = characteristic;
            }
        }
        
        if (_controlCmdRequest != nil) { // FIXME refactor byte array creation to own method
            
            NSData *data = [self generateByteArray:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_MAX_PROGRAMS progId:0x00 progDescId:0x00];
            
            [peripheral writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
            NSLog(@"Writing %@", [self loggableCharacteristicName:_controlCmdRequest]);
        }
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    if (error != nil) {
        
        if (error.code == CBATTErrorReadNotPermitted) {
            NSLog(@"Error updating characteristic '%@', read not permitted!", [self loggableCharacteristicName:characteristic]);
        }
        else if (error.code == CBATTErrorWriteNotPermitted) {
            NSLog(@"Error updating characteristic '%@', write not permitted!", [self loggableCharacteristicName:characteristic]);
        }
        else if (error.code == CBATTErrorInsufficientAuthentication) {
            NSLog(@"Insufficient authentication when attempting to update characteristic '%@'", [self loggableCharacteristicName:characteristic]);
        }
        else if (error.code == CBATTErrorInsufficientEncryption) {
            NSLog(@"Insufficient encryption when attempting to update characteristic '%@'", [self loggableCharacteristicName:characteristic]);
        }
        else {
            NSLog(@"General CBATT Error updating characteristic '%@' %@", [self loggableCharacteristicName:characteristic], error);
        }
    }
    else {
        NSLog(@"Characteristic '%@' was updated to value %@", [self loggableCharacteristicName:characteristic], characteristic);
        
        [self deserialiseByteArray:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"Wrote characteristic '%@' %@", [self loggableCharacteristicName:characteristic], error);
    
    [peripheral readValueForCharacteristic:_controlCmdResponse];
}

#pragma mark

- (NSData *)generateByteArray:(Byte)cmdId subCmdId:(Byte)subCmdId progId:(Byte)progId progDescId:(Byte)progDescId
{
    Byte lastByte = 0x00;
    
    const unsigned char bytes[] = {cmdId, subCmdId, progId, progDescId, lastByte};
    NSLog(@"Preparing byte array: {cmdId=%hhu, subCmdId=%hhu, progId=%hhu, progDescId=%hhu, lastByte=%hhu}", cmdId, subCmdId, progId, progDescId, lastByte);
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];;
}

- (void) deserialiseByteArray:(NSData *)data
{
    if (data != nil) {
        int length = [data length];
        
        Byte *bd = (Byte*)malloc(length);
        memcpy(bd, [data bytes], length);
        
        Byte cmdId = bd[0];
        Byte status = bd[1];
        
        const unsigned char bytes[] = {bd[2], bd[3], bd[4], bd[5]};
        
        free(bd);
        NSLog(@"Interpreted control command response. {cmdId=%hhu, status=%hhu, data=%s}", cmdId, status, bytes);
    }
}

@end
