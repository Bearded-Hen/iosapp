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
#import "FOCUiPageChangeDelegate.h"

#import "JBChartView.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"

/**
 * Controls how the view for an individual program should be displayed, and provides a
 * delegate for handling any events requiring changes to the model layer e.g. playing a program
 */
@interface FOCDataViewController : UIViewController<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JBLineChartViewDataSource, JBLineChartViewDelegate> {
    
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
@property (weak, nonatomic) IBOutlet JBLineChartView *currentGraph;

/**
 * Updates the text which is displayed on the bottom status bar.
 */
-(void)updateConnectionText:(NSString *)connectionText;

-(void)updateCurrentGraphData:(NSArray *)graphData;

@end