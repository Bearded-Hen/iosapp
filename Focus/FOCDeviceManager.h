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
#import "FOCCharacteristicDiscoveryManager.h"

@import CoreBluetooth;
@import QuartzCore;

/**
 * Manages bluetooth communication between the iOS and Focus devices. A delegate is available which
 * allows consumers of the Api to receive callbacks when the Device connection state changes.
 *
 * 
 */
@interface FOCDeviceManager : NSObject<CBCentralManagerDelegate, CharacteristicDiscoveryListener> {
    __weak id<FOCDeviceStateListener> delegate_;
}

@property (weak) id <FOCDeviceStateListener> delegate;

@property FocusConnectionState connectionState;

- (void)refreshStateIfNeeded;

@end
