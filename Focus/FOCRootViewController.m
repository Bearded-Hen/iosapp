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
    
    [self reloadData];
    
    FOCAppDelegate *delegate = (FOCAppDelegate *) [[UIApplication sharedApplication] delegate];
    delegate.syncDelegate = self;
    
    _deviceManager = delegate.focusDeviceManager;
    _deviceManager.delegate = self;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    FOCDataViewController* startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray* viewControllers = @[ startingViewController ];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.dataSource = self;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    self.pageViewController.view.frame = self.view.bounds;

    [self.pageViewController didMoveToParentViewController:self];
    [self setupPagingGestureRecognisers];
}

- (void)setupPagingGestureRecognisers
{
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    UIGestureRecognizer* tapRecognizer = nil;
    
    for (UIGestureRecognizer* recognizer in self.pageViewController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            tapRecognizer = recognizer;
            break;
        }
    }
    
    if (tapRecognizer) {
        [self.view removeGestureRecognizer:tapRecognizer];
        [self.pageViewController.view removeGestureRecognizer:tapRecognizer];
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

- (void)reloadData
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
    [dataViewController notifyConnectionStateChanged:_deviceManager.connectionState];
    
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
    [self reloadData];
    
    // FIXME always jumps to first controller, should go back to where the user was previously
    FOCDataViewController* startingViewController = [self viewControllerAtIndex:0 storyboard:self.storyboard];
    
    NSArray* viewControllers = @[ startingViewController ];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - FOCUiPageChangeDelegate

-(void)didAlterPageState:(FOCUiPageModel *)pageModel
{
    FOCDeviceProgramEntity *currentProgram = pageModel.program;
    FOCDeviceProgramEntity *alteredProgram;
    
    for (int i=0; i<[_pageData count]; i++) {
        FOCUiPageModel *model = _pageData[i];
        alteredProgram = model.program;
        
        bool idMatch = currentProgram.programId.intValue == alteredProgram.programId.intValue;
        bool nameMatch = [currentProgram.name isEqualToString:alteredProgram.name];
        
        if (idMatch && nameMatch) {
            _pageData[i] = pageModel;
            break;
        }
    }
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController*)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    FOCDataViewController* currentViewController = [self currentViewController];
    NSArray* viewControllers = @[ currentViewController ];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
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

@end
