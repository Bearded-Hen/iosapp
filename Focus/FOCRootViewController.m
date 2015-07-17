//
//  RootViewController.m
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCAppDelegate.h"
#import "FOCRootViewController.h"
#import "FOCModelController.h"
#import "FOCDataViewController.h"

@interface FOCRootViewController ()

@property FOCDeviceManager *deviceManager;
@property (strong, nonatomic) NSMutableArray *pageData;

@end

@implementation FOCRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageData = [[NSMutableArray alloc] init];
    
    [self refresh];
    
    FOCAppDelegate *delegate = (FOCAppDelegate *) [[UIApplication sharedApplication] delegate];
    delegate.syncDelegate = self;
    
    _deviceManager = delegate.focusDeviceManager;
    _deviceManager.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    FOCDataViewController* startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray* viewControllers = @[ startingViewController ];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.dataSource = self;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController*)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    FOCDataViewController* currentViewController = [self currentViewController];
    NSArray* viewControllers = @[ currentViewController ];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        [[self currentViewController] notifyConnectionStateChanged:_deviceManager.connectionState];
    }
}

- (FOCDataViewController *)currentViewController
{
    return (FOCDataViewController*) self.pageViewController.viewControllers[0];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)refresh
{
    FOCAppDelegate *delegate = (FOCAppDelegate *) [[UIApplication sharedApplication] delegate];
    [_pageData removeAllObjects];
    
    for (FOCDeviceProgramEntity *program in [delegate retrieveFocusPrograms]) {
        [_pageData addObject:[[FOCUiPageModel alloc] initWithProgram:program]];
    }
    
    NSLog(@"Refreshed and displayed %d programs", [_pageData count]);
}

- (FOCDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    if (([_pageData count] == 0) || (index >= [_pageData count])) {
        return nil;
    }
    
    FOCDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"FOCDataViewController"];
    dataViewController.pageModel = _pageData[index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(FOCDataViewController *)viewController {
    return [_pageData indexOfObject:viewController.pageModel];
}

#pragma mark DeviceStateListener

- (void)didChangeConnectionState: (FocusConnectionState)connectionState
{
    [[self currentViewController] notifyConnectionStateChanged:connectionState];
}

#pragma mark ProgramSyncDelegate

- (void)didChangeDataSet:(NSArray *)dataSet
{
    [self refresh];
    
    // FIXME always jumps to first controller, should go back to where the user was previously
    FOCDataViewController* startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    
    NSArray* viewControllers = @[ startingViewController ];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FOCDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FOCDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

#pragma mark - FOCUiPageChangeDelegate

-(void)didAlterPageState:(FOCUiPageModel *)pageModel
{
    FOCUiPageModel *currentModel;
    
    for (int i=0; i<[_pageData count]; i++) {
        currentModel = _pageData[i];
        
        bool idMatch = currentModel.program.programId.intValue == pageModel.program.programId.intValue;
        bool nameMatch = [currentModel.program.name isEqualToString:pageModel.program.name];
        
        if (idMatch && nameMatch) {
            _pageData[i] = pageModel;
            break;
        }
    }
}

@end
