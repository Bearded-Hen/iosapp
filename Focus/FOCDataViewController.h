//
//  DataViewController.h
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FOCUiPageModel.h"
#import "FOCDeviceProgramEntity.h"
#import "FOCDeviceStateDelegate.h"

@protocol FOCUiPageChangeDelegate <NSObject>

/**
 * Called when the UI model for displaying the program changes e.g. Settings visibility
 */
- (void)didAlterPageState:(FOCUiPageModel *)pageModel;

/**
 * Called when the user requests to stop/start a program through the app UI.
 */
- (void)didRequestProgramStateChange:(FOCUiPageModel *)pageModel play:(bool)play;

/**
 * Called when the user requests an edit to the program. The responder should write the
 * edited program to the Focus device then notify the UI of changes to the model.
 */
- (void)didRequestProgramEdit:(FOCDeviceProgramEntity *)program;

@end

@interface FOCDataViewController : UIViewController<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    
    __weak id<FOCUiPageChangeDelegate> delegate_;
}

@property (weak) id <FOCUiPageChangeDelegate> delegate;
@property (strong, nonatomic) FOCUiPageModel *pageModel;

@property (weak, nonatomic) IBOutlet UILabel *programTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *programControlContainer;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayProgram;
@property (weak, nonatomic) IBOutlet UIButton *btnProgramSettings;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothConnectionIcon;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

-(void)updateConnectionText:(NSString *)connectionText;

@end