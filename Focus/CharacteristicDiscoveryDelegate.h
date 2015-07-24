//
//  CharacteristicDiscoveryDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 24/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_CharacteristicDiscoveryDelegate_h
#define Focus_CharacteristicDiscoveryDelegate_h

/**
 * Delegate which will be called as soon as the required characteristics & services have been discovered on the device
 */
@protocol CharacteristicDiscoveryDelegate <NSObject>

- (void)didFinishCharacteristicDiscovery:(NSError *) error;

@end

#endif
