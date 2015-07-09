//
//  FOCPeripheralDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;
@import QuartzCore;

@interface FOCPeripheralDelegate : NSObject<CBPeripheralDelegate>

- (id)initWithPeripheral:(CBPeripheral *) focusDevice;

@end