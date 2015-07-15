//
//  DataViewController.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FOCDeviceProgramEntity.h"
#import "FOCDeviceStateDelegate.h"

@interface FOCDataViewController : UIViewController<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) FOCDeviceProgramEntity *program;

@property (weak, nonatomic) IBOutlet UILabel *programTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *programControlContainer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayProgram;
@property (weak, nonatomic) IBOutlet UIButton *btnProgramSettings;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothConnectionIcon;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)notifyConnectionStateChanged:(FocusConnectionState)state;

@end