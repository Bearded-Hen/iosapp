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

@end

@implementation FOCProgramSyncManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer
{
    _controlCmdRequest = controlCmdRequest;
    _controlCmdResponse = controlCmdResponse;
    _dataBuffer = dataBuffer;
    
    NSData *data = [self generateByteArray:FOC_CMD_MANAGE_PROGRAMS subCmdId:FOC_SUBCMD_MAX_PROGRAMS progId:0x00 progDescId:0x00];
    
    [self.focusDevice writeValue:data forCharacteristic:_controlCmdRequest type:CBCharacteristicWriteWithResponse];
    NSLog(@"Writing %@", [self loggableCharacteristicName:_controlCmdRequest]);
}


- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    if (error == nil) {
        [self deserialiseByteArray:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    
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
