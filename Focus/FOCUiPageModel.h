//
//  FOCUiPageModel.h
//  Focus
//
//  Created by Jamie Lynch on 17/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FOCDeviceProgramEntity.h"
#import "FOCDeviceStateDelegate.h"

/**
 * Contains all the state for how a single program should be displayed in the ViewPager.
 */
@interface FOCUiPageModel : NSObject

- (id)initWithProgram:(FOCDeviceProgramEntity *)program;

@property bool isPlaying;
@property bool settingsHidden;
@property FOCDeviceProgramEntity *program;
@property FocusConnectionState connectionState;
@property NSString *connectionText;

@end
