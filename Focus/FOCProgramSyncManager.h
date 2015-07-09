//
//  MaxProgramCountRequest.h
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FOCBasePeripheralManager.h"

/**
 * Handles the initial syncing of programs from the Focus Device to the iOS device. This
 * happens as soon as a connection has been established to the Focus Device, and its
 * characteristics have been discovered.
 */
@interface FOCProgramSyncManager : FOCBasePeripheralManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer;

@end
