//
//  ProgramRequestManager.h
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCBasePeripheralManager.h"
#import "FOCDeviceProgramEntity.h"
#import "FOCCharacteristicDiscoveryManager.h"

@protocol ProgramRequestDelegate <NSObject>

/**
 * Called when a program either starts playing or is stopped on the Focus device.
 */
- (void)didAlterProgramState:(bool)playing error:(NSError *)error;

/**
 * Called when the Focus device updates its current value via a notification.
 */
- (void)didReceiveCurrentNotification:(int)current;

/**
 * Called when the Focus device updates the duration value of a program via a notification.
 */
- (void)didReceiveDurationNotification:(int)duration;

/**
 * Called when the Focus device updates the remaining time of a program via a notification.
 */
- (void)didReceiveRemainingTimeNotification:(int)remainingTime;

@end

@interface FOCProgramRequestManager : FOCBasePeripheralManager {
    __weak id<ProgramRequestDelegate> delegate_;
}

@property (weak) id <ProgramRequestDelegate> delegate;
@property FOCCharacteristicDiscoveryManager *cm;
@property FOCDeviceProgramEntity *activeProgram;

/**
 * Attempt to start the specified program on the device.
 */
- (void)startProgram:(FOCDeviceProgramEntity *)program;

/**
 * Attempt to stop the active program (if any) on the device.
 */
- (void)stopActiveProgram;

/**
 * Starts listening for notifications from the Focus device
 */
- (void)startNotificationListeners:(CBPeripheral *)focusDevice;

@end
