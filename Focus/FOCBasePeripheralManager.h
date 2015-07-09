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

@property CBPeripheral *focusDevice;

@end