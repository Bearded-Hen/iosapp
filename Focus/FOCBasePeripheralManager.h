//
//  FOCBasePeripheralManager.h
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;
@import QuartzCore;

#import "FocusConstants.h"

@interface FOCBasePeripheralManager : NSObject<CBPeripheralDelegate>

- (id)initWithPeripheral:(CBPeripheral *) focusDevice;

- (NSString *)loggableServiceName:(CBService *)service;
- (NSString *)loggableCharacteristicName:(CBCharacteristic *)characteristic;

- (NSData *)constructCommandRequest:(Byte)cmdId subCmdId:(Byte)subCmdId;
- (NSData *)constructCommandRequest:(Byte)cmdId subCmdId:(Byte)subCmdId progId:(Byte)progId progDescId:(Byte)progDescId;

@property CBPeripheral *focusDevice;

@end