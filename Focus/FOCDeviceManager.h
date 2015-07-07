//
//  FocusDeviceManager.h
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FOCDeviceStateListener.h"

@import CoreBluetooth;
@import QuartzCore;

/**
 * Manages bluetooth communication between the iOS and Focus devices. Consumers of the api should
 * call methods defined in this interface, and receive callbacks by setting the delegate
 * to an appropriate responder.
 */
@interface FOCDeviceManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property id <FOCDeviceStateListener> delegate;

@property FocusConnectionState *connectionState;

- (void)requestUpdate;

@end
