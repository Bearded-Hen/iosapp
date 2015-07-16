//
//  RootViewController.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FOCAppDelegate.h"

@interface FOCRootViewController : UIViewController <UIPageViewControllerDelegate, FOCDeviceStateDelegate, FOCProgramSyncDelegate>

@property (strong, nonatomic) UIPageViewController* pageViewController;

@end
