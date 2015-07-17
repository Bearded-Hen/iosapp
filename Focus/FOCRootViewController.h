//
//  RootViewController.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FOCAppDelegate.h"
#import "FOCDataViewController.h"

@class FOCUiPageModel;

@interface FOCRootViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, FOCDeviceStateDelegate, FOCProgramSyncDelegate, FOCUiPageChangeDelegate> {
}

@property (strong, nonatomic) UIPageViewController* pageViewController;

- (FOCDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(FOCDataViewController *)viewController;
- (void)reloadData;

@end
