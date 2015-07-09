//
//  FOCPeripheralDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FOCBasePeripheralManager.h"

/**
 * Delegate which will be called as soon as the required characteristics & services have been discovered on the device
 */
@protocol CharacteristicDiscoveryListener <NSObject>

- (void)didFinishCharacteristicDiscovery:(NSError *) error;

@end

/**
 * Delegate which handles the discovery of services & characteristics on the Focus device.
 */
@interface FOCCharacteristicDiscoveryManager : FOCBasePeripheralManager {
    __weak id<CharacteristicDiscoveryListener> delegate_;
}

- (id)initWithPeripheral:(CBPeripheral *) focusDevice;

@property (weak) id <CharacteristicDiscoveryListener> delegate;
@property (readonly) CBCharacteristic *controlCmdResponse;
@property (readonly) CBCharacteristic *controlCmdRequest;
@property (readonly) CBCharacteristic *dataBuffer;

@end