//
//  FOCPeripheralDelegate.m
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCCharacteristicDiscoveryManager.h"

#import "FocusConstants.h"

@interface FOCCharacteristicDiscoveryManager ()

@property CBPeripheral *focusDevice;

@end

@implementation FOCCharacteristicDiscoveryManager


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
    [super peripheral:peripheral didDiscoverServices:error];
    
    for (CBService *service in self.focusDevice.services) {
        
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
    [super peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    
    if (error == nil) {
        for (CBCharacteristic* characteristic in service.characteristics) {
            
            if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_REQUEST]) {
                _controlCmdRequest = characteristic;
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:FOC_CONTROL_CMD_RESPONSE]) {
                _controlCmdResponse = characteristic;
            }
            else if ([characteristic.UUID.UUIDString isEqualToString:FOC_DATA_BUFFER]) {
                _dataBuffer = characteristic;
            }
        }
        
        if (_controlCmdRequest != nil) { // FIXME refactor byte array creation to own method
            
            NSData *data = [self generateByteArray:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_MAX_PROGRAMS progId:0x00 progDescId:0x00];
            
            [peripheral writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
            NSLog(@"Writing %@", [self loggableCharacteristicName:_controlCmdRequest]);
        }
    }
    
    if (_controlCmdRequest != nil && _controlCmdResponse != nil && _dataBuffer != nil) {
        [self.delegate didFinishCharacteristicDiscovery:nil];
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    if (error == nil) {
        [self deserialiseByteArray:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    [peripheral readValueForCharacteristic:_controlCmdResponse];
}

#pragma mark - deserialisation

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
