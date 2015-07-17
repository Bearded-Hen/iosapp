//
//  ProgramRequestManager.h
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCBasePeripheralManager.h"
#import "FOCDeviceProgramEntity.h"

@protocol ProgramRequestDelegate <NSObject>

- (void)didFinishProgramRequest:(NSError *) error;

@end

@interface FOCProgramRequestManager : FOCBasePeripheralManager {
    __weak id<ProgramRequestDelegate> delegate_;
}

@property (weak) id <ProgramRequestDelegate> delegate;

@property CBCharacteristic *controlCmdRequest;
@property CBCharacteristic *controlCmdResponse;
@property CBCharacteristic *dataBuffer;

/**
 * Attempt to start the specified program on the device.
 */
- (void)startProgram:(FOCDeviceProgramEntity *)program;

/**
 * Attempt to stop the specified program on the device.
 */
- (void)stopProgram:(FOCDeviceProgramEntity *)program;

@end
