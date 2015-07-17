//
//  DataViewController.m
//  Focus
//
//  Created by Jamie Lynch on 26/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDataViewController.h"
#import "FOCFontAwesome.h"
#import "FOCDisplayAttributeModel.h"
#import "FOCProgramModeWrapper.h"
#import "FOCPaddedLabel.h"
#import "FOCColorMap.h"
#import "FOCProgramAttributeView.h"
#import "ActionSheetPicker.h"

@interface FOCDataViewController ()

@end

static NSString *kBluetoothConnected = @"bluetooth_connected.png";
static NSString *kBluetoothDisconnected = @"bluetooth_disconnected.png";
static NSString *kBluetoothDisabled = @"bluetooth_disabled.png";

static const int kVerticalEdgeInset = 20;
static const int kHorizontalEdgeInset = 10;
static const float kAnimDuration = 0.3;

@interface FOCDataViewController ()

@property NSDictionary *editableAttributes;
@property NSArray *orderedEditKeys;
@property FocusConnectionState lastKnownState;

@end

@implementation FOCDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_btnPlayProgram.titleLabel setFont:[FOCFontAwesome font]];
    [_btnProgramSettings.titleLabel setFont:[FOCFontAwesome font]];
    
    [_btnPlayProgram setTitle:[FOCFontAwesome unicodeForIcon:@"fa-play"] forState:UIControlStateNormal];
    [_btnProgramSettings setTitle:[FOCFontAwesome unicodeForIcon:@"fa-cog"] forState:UIControlStateNormal];
    
    _programTitleLabel.text = [[_pageModel.program name] capitalizedString];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    _backgroundImageView.image = [UIImage imageNamed:_pageModel.program.imageName];
    
    _orderedEditKeys = [_pageModel.program orderedEditKeys];
    _editableAttributes = [_pageModel.program editableAttributes];
    
    [_btnProgramSettings addTarget:self action:@selector(didClickSettingsButton) forControlEvents:UIControlEventTouchUpInside];
    [_collectionView reloadData];
    
    _collectionView.hidden = _pageModel.settingsHidden;
    [self notifyConnectionStateChanged:_lastKnownState];
}

-(void)notifyConnectionStateChanged:(FocusConnectionState)state
{
    _lastKnownState = state;
    NSString *imagePath;
    
    switch (state) {
        case CONNECTED: {
            imagePath = kBluetoothConnected;
            break;
        }
        case CONNECTING: {
            imagePath = kBluetoothDisconnected;
            break;
        }
        case SCANNING: {
            imagePath = kBluetoothDisconnected;
            break;
        }
        case DISCONNECTED: {
            imagePath = kBluetoothDisconnected;
            break;
        }
        case DISABLED: {
            imagePath = kBluetoothDisabled;
            break;
        }
        case UNKNOWN: {
            imagePath = kBluetoothDisconnected;
            break;
        }
        default: {
            imagePath = kBluetoothConnected;
            break;
        }
    }
    _bluetoothConnectionIcon.image = [UIImage imageNamed:imagePath];
}

- (void)didClickSettingsButton
{
    _pageModel.settingsHidden = !_pageModel.settingsHidden;
    
    if (_pageModel.settingsHidden) {
        [UIView animateWithDuration:kAnimDuration animations:^{
            _collectionView.alpha = 0;
        } completion: ^(BOOL finished) {
            _collectionView.hidden = finished;
        }];
    }
    else {
        _collectionView.alpha = 0;
        _collectionView.hidden = NO;
        [UIView animateWithDuration:kAnimDuration animations:^{
            _collectionView.alpha = 1;
        }];
    }
    [_delegate didAlterPageState:_pageModel];
}

-(FOCDisplayAttributeModel *)displayAttributeModelForIndex:(NSIndexPath *)indexPath
{
    NSString *dataKey = _orderedEditKeys[indexPath.item];
    FOCDisplayAttributeModel *model = [[FOCDisplayAttributeModel alloc] init];
    
    model.attrLabel = [self labelForAttrKey:dataKey];
    model.attrValue = [self valueForAttrKey:dataKey];

    return model;
}

/**
 * Returns a human-readable string that describes a Program Attribute
 */
- (NSString *)labelForAttrKey:(NSString *)dataKey
{
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        return @"MODE";
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey]) {
        return @"SHAM";
    }
    else if ([PROG_ATTR_BIPOLAR isEqualToString:dataKey]) {
        return @"BIPOLAR";
    }
    else if ([PROG_ATTR_RAND_CURR isEqualToString:dataKey]) {
        return @"R. CURRENT";
    }
    else if ([PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        return @"R. FREQ";
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey]) {
        return @"TIME";
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        return @"CURRENT";
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        return @"VOLTAGE";
    }
    else if ([PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        return @"SHAM PERIOD";
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        return @"OFFSET";
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        return @"FREQUENCY";
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        return @"DUTY CYCLE";
    }
    else {
        return @"";
    }
}

/**
 * Returns a human-readable string that describes a Program Attribute's current value.
 */
- (NSString *)valueForAttrKey:(NSString *)dataKey
{
    id value = [_editableAttributes objectForKey:dataKey];
    
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        FOCProgramModeWrapper *wrapper = (FOCProgramModeWrapper *) value;
        return [FOCDeviceProgramEntity readableLabelFor:wrapper.mode];
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey] ||
             [PROG_ATTR_BIPOLAR isEqualToString:dataKey] ||
             [PROG_ATTR_RAND_CURR isEqualToString:dataKey] ||
             [PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        
        return [self readableBoolString:value];
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey] ||
             [PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        
        return [self readableTimeString:value];
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey] ||
             [PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        
        return [self readableCurrentString:value];
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        return [self readableVoltageString:value];
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        return [self readableFrequencyString:value];
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        return [self readablePercentageString:value];
    }
    else {
        return @"";
    }
    return nil;
}

- (NSString *)readableBoolString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    return number.boolValue ? @"ON" : @"OFF";
}

- (NSString *)readableTimeString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    int seconds = number.intValue % 60;
    int mins = (number.intValue - seconds) / 60;
    return [NSString stringWithFormat:@"%02d:%02d", mins, seconds];
}

- (NSString *)readableVoltageString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    return [NSString stringWithFormat:@"%dV", number.intValue];
}

- (NSString *)readableFrequencyString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    float freq = number.intValue;
    freq /= 1000; // convert from amps to mA
    return [NSString stringWithFormat:@"%dHz", (int)freq];
}

- (NSString *)readablePercentageString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    return [NSString stringWithFormat:@"%ld%%", number.longValue];
}

- (NSString *)readableCurrentString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    float current = number.intValue;
    current /= 1000; // convert from amps to mA
    return [NSString stringWithFormat:@"%.1fmA", current];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [_editableAttributes count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProgramAttributeCell" forIndexPath:indexPath];
    
    FOCDisplayAttributeModel *model = [self displayAttributeModelForIndex:indexPath];
    
    FOCProgramAttributeView *view = [[FOCProgramAttributeView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    
    [view updateModel:model];
    [cell addSubview:view];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *dataKey = _orderedEditKeys[indexPath.item];
    
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        NSArray *options = [NSArray arrayWithObjects:@"Direct", @"Alternating", @"Random", @"Pulse", nil];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Select Mode" rows:options
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               // TODO
                                           }
                                         cancelBlock:nil
                                              origin:_collectionView];
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey]) {
        [self showBooleanPicker:nil currentState:_pageModel.program.sham.boolValue];
    }
    else if ([PROG_ATTR_BIPOLAR isEqualToString:dataKey]) {
        [self showBooleanPicker:nil currentState:_pageModel.program.bipolar.boolValue];
    }
    else if ([PROG_ATTR_RAND_CURR isEqualToString:dataKey]) {
        [self showBooleanPicker:nil currentState:_pageModel.program.randomCurrent.boolValue];
    }
    else if ([PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        [self showBooleanPicker:nil currentState:_pageModel.program.randomFrequency.boolValue];
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        [self showCurrentPicker:nil title:@"Select Current"];
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        [self showVoltagePicker];
    }
    else if ([PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        [self showSecondPicker:nil];
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        [self showCurrentPicker:nil title:@"Select Current Offset"];
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {

    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        [self showPercentagePicker:nil];
    }
    else {
        NSLog(@"Unknown attribute edit attempted");
    }
}

- (void)showSecondPicker:(ActionStringDoneBlock)doneBlock
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=0; i<=50; i++) {
        [options addObject:[NSString stringWithFormat:@"%d s", i]];
    }
    int index = 0; // FIXME index selection
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Sham Period" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showPercentagePicker:(ActionStringDoneBlock)doneBlock
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=20; i<=80; i++) {
        [options addObject:[NSString stringWithFormat:@"%d %%", i]];
    }
    int index = 0; // FIXME index selection
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Duty Cycle" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showCurrentPicker:(ActionStringDoneBlock)doneBlock title:(NSString *)title;
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=1; i<=18; i++) {
        [options addObject:[NSString stringWithFormat:@"%.1f mA", ((float)i) / 10]];
    }
    int index = 0; // FIXME index selection
    
    [ActionSheetStringPicker showPickerWithTitle:title rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showVoltagePicker
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=10; i<=60; i++) {
        [options addObject:[NSString stringWithFormat:@"%d V", i]];
    }
    int index = _pageModel.program.voltage.intValue - 10;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Voltage" rows:options initialSelection:index doneBlock:nil cancelBlock:nil origin:_collectionView];
}

- (void)showBooleanPicker:(ActionStringDoneBlock)doneBlock currentState:(bool)currentState
{
    NSArray *options = [NSArray arrayWithObjects:@"On", @"Off", nil];
    int index = currentState == true ? 0 : 1;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Mode" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float availableSpace = _collectionView.frame.size.width - (kHorizontalEdgeInset * 3);
    return CGSizeMake(availableSpace / 2, 44);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kVerticalEdgeInset, kHorizontalEdgeInset, kVerticalEdgeInset, kHorizontalEdgeInset);
}

@end
