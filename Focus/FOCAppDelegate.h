//
//  AppDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FOCDeviceManager.h"

/**
 * Contains a Device manager instance which allows the Focus Device to be interacted with
 * via its Bluetooth API.
 */
@interface FOCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FOCDeviceManager *focusDeviceManager;

@end

