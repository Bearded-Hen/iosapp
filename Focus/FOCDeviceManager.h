//
//  FocusDeviceManager.h
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FOCDeviceStateDelegate.h"
#import "FOCCharacteristicDiscoveryManager.h"

#import "FOCProgramSyncManager.h"
#import "FOCProgramRequestManager.h"
#import "FOCBluetoothPairManager.h"
#import "ProgramSyncDelegate.h"
#import "FOCProgramRequestDelegate.h"
#import "FOCBluetoothPairingDelegate.h"

@import CoreBluetooth;
@import QuartzCore;

/**
 * Manages bluetooth communication between the iOS and Focus devices. A delegate is available
 * which allows consumers of the Api to receive callbacks when the Device connection state 
 * changes.
 */
@interface FOCDeviceManager : NSObject<CBCentralManagerDelegate, FOCCharacteristicDiscoveryDelegate, ProgramSyncDelegate, FOCProgramRequestDelegate, FOCBluetoothPairingDelegate, UIAlertViewDelegate> {
    __weak id<FOCDeviceStateDelegate> delegate_;
}

@property (weak) id <FOCDeviceStateDelegate> delegate;
@property FocusConnectionState connectionState;
@property NSString *connectionText;

/**
 * If the Focus device is not connected, attempt to connect it again, and handle any bluetooth
 * errors such as disabled/no connection
 */
- (void)refreshDeviceState;

/**
 * Close the BLE connection.
 */
- (void)closeConnection;

/**
 * Start playing the given program
 */
- (void)playProgram:(FOCDeviceProgramEntity *)program;

/**
 * Stop the active program (if any)
 */
- (void)stopProgram:(FOCDeviceProgramEntity *)program;

/**
 * Attempt to write an edited program to the device.
 */
- (void)writeProgram:(FOCDeviceProgramEntity *)program;

@end
