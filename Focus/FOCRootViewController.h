//
//  RootViewController.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOCRootViewController : UIViewController <UIPageViewControllerDelegate, FOCDeviceStateDelegate>

@property (strong, nonatomic) UIPageViewController* pageViewController;

@end
