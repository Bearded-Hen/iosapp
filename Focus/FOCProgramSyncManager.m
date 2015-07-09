//
//  MaxProgramCountRequest.m
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramSyncManager.h"

@implementation FOCProgramSyncManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer
{
    // TODO write
}


- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    [super peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    
    if (error == nil) {
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [super peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
}

@end
