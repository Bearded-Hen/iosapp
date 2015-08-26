//
//  FOCDeviceListViewController.m
//  Focus
//
//  Created by Jamie Lynch on 25/08/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDeviceListViewController.h"
#import "FOCDeviceManager.h"
#import "FOCAppDelegate.h"

static NSString *kCellIdentifier = @"DeviceTableItem";

@interface FOCDeviceListViewController ()
@property NSArray *deviceList;
@property FOCDeviceManager *deviceManager;
@end

@implementation FOCDeviceListViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super initWithCoder:aDecoder]) {
        _deviceList = [NSArray arrayWithObject:@"Test device"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FOCAppDelegate *delegate = (FOCAppDelegate *) [[UIApplication sharedApplication] delegate];
        
    _deviceManager = delegate.focusDeviceManager;
    _deviceManager.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_deviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    cell.textLabel.text = [_deviceList objectAtIndex:indexPath.row];
    return cell;
}

- (IBAction)didSelectDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
