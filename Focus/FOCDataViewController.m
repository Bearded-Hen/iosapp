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
#import "ActionSheetPickerTimeDelegate.h"

#import "FOCModeAttributeSetting.h"
#import "FOCBoolAttributeSetting.h"
#import "FOCShamDurationAttributeSetting.h"
#import "FOCDutyCycleAttributeSetting.h"
#import "FOCVoltageAttributeSetting.h"
#import "FOCCurrentAttributeSetting.h"
#import "FOCCurrentOffsetAttributeSetting.h"
#import "FOCFrequencyAttributeSetting.h"

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

@end

@implementation FOCDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_btnPlayProgram.titleLabel setFont:[FOCFontAwesome font]];
    [_btnProgramSettings.titleLabel setFont:[FOCFontAwesome font]];
    
    NSString *faCode = _pageModel.isPlaying ? @"fa-stop" :  @"fa-play";
    
    [_btnPlayProgram setTitle:[FOCFontAwesome unicodeForIcon:faCode] forState:UIControlStateNormal];
    [_btnProgramSettings setTitle:[FOCFontAwesome unicodeForIcon:@"fa-cog"] forState:UIControlStateNormal];
    
    [_btnProgramSettings addTarget:self action:@selector(didClickSettingsButton) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnPlayProgram addTarget:self action:@selector(didClickChangePlayStateButton) forControlEvents:UIControlEventTouchUpInside];
    
    _programTitleLabel.text = [[_pageModel.program name] capitalizedString];
    _backgroundImageView.image = [UIImage imageNamed:_pageModel.program.imageName];
    
    _orderedEditKeys = [_pageModel.program orderedEditKeys];
    _editableAttributes = [_pageModel.program editableAttributes];
    
    [_collectionView reloadData];
    _collectionView.hidden = _pageModel.settingsHidden;
    
    [self setBluetoothImage:_pageModel.connectionState];
    [self updateConnectionText:_pageModel.connectionText];
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

- (void)didClickChangePlayStateButton
{
    [_delegate didRequestProgramStateChange:_pageModel play:!_pageModel.isPlaying];
}

-(FOCDisplayAttributeModel *)displayAttributeModelForIndex:(NSIndexPath *)indexPath
{
    NSString *dataKey = _orderedEditKeys[indexPath.item];
    FOCDisplayAttributeModel *model = [[FOCDisplayAttributeModel alloc] init];
    
    model.attrLabel = [self labelForAttrKey:dataKey];
    model.attrValue = [self valueForAttrKey:dataKey];

    return model;
}

#pragma mark DeviceStateDelegate

-(void)setBluetoothImage:(FocusConnectionState)state
{
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
            imagePath = kBluetoothDisconnected;
            break;
        }
    }
    _bluetoothConnectionIcon.image = [UIImage imageNamed:imagePath];
}

- (void)updateConnectionText:(NSString *)connectionText
{
    _statusLabel.text = connectionText;
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
        
        return [FOCBoolAttributeSetting labelForValue:((NSNumber *) value).boolValue];
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey] ||
             [PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        
        return [self readableTimeString:value];
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        return [FOCCurrentAttributeSetting labelForValue:((NSNumber *) value).intValue];
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        return [FOCCurrentOffsetAttributeSetting labelForValue:((NSNumber *) value).intValue];
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        return [FOCVoltageAttributeSetting labelForValue:((NSNumber *)value).intValue];
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        return [FOCFrequencyAttributeSetting labelForValue:((NSNumber *) value).longValue];
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        return [self readablePercentageString:value];
    }
    else {
        return @"";
    }
    return nil;
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
    FOCDeviceProgramEntity *program = _pageModel.program;
    
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        [self showModePicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            ProgramMode newMode = [FOCModeAttributeSetting valueForIncrementIndex:selectedIndex];
            // TODO attempt update to program mode
            
        } mode:program.programMode];
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey]) {
        [self showBooleanPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {

            bool newSham = [FOCBoolAttributeSetting valueForIncrementIndex:selectedIndex];
            // TODO update model
            
        } currentState:program.sham.boolValue];
    }
    else if ([PROG_ATTR_BIPOLAR isEqualToString:dataKey]) {
        [self showBooleanPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            bool newBipolar = [FOCBoolAttributeSetting valueForIncrementIndex:selectedIndex];
            // TODO update model
            
        } currentState:program.bipolar.boolValue];
    }
    else if ([PROG_ATTR_RAND_CURR isEqualToString:dataKey]) {
        [self showBooleanPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            bool newRandCurr = [FOCBoolAttributeSetting valueForIncrementIndex:selectedIndex];
            // TODO update model
            
        } currentState:program.randomCurrent.boolValue];
    }
    else if ([PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        [self showBooleanPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            bool newRandFreq = [FOCBoolAttributeSetting valueForIncrementIndex:selectedIndex];
            // TODO update model
            
        } currentState:program.randomFrequency.boolValue];
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey]) { // FIXME
        [self showTimePicker];
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) { // FIXME
        [self showCurrentPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            int newCurrent = [FOCCurrentAttributeSetting valueForIncrementIndex:selectedIndex];
            NSLog(@"");
        }
        title:@"Select Current" current:((NSNumber *)program.current).intValue];
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        [self showVoltagePicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            int newVoltage = [FOCVoltageAttributeSetting valueForIncrementIndex:selectedIndex];
            
        } voltage:program.voltage.intValue];
    }
    else if ([PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        [self showSecondPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            int newShamDuration = [FOCShamDurationAttributeSetting valueForIncrementIndex:selectedIndex];
            
        } shamDuration:program.shamDuration.intValue];
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) { // FIXME
        [self showCurrentOffsetPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            int newCurrentOffset = [FOCCurrentOffsetAttributeSetting valueForIncrementIndex:selectedIndex];
            NSLog(@"");
            
        } title:@"Select Current Offset" current:((NSNumber *)program.currentOffset).intValue];
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        [self showFrequencyPicker:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            long newFreq = [FOCFrequencyAttributeSetting valueForIncrementIndex:selectedIndex];
            
        } frequency:((NSNumber *)program.frequency).longValue];
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) { // FIXME
        [self showDutyCyclePicker:nil dutyCycle:program.dutyCycle.intValue];
    }
    else {
        NSLog(@"Unknown attribute edit attempted");
    }
}

- (void)showModePicker:(ActionStringDoneBlock)doneBlock mode:(ProgramMode)mode
{
    NSArray *options = [FOCModeAttributeSetting labelsForAttribute];
    int index = [FOCModeAttributeSetting indexForValue:mode];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Mode" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showBooleanPicker:(ActionStringDoneBlock)doneBlock currentState:(bool)currentState
{
    NSArray *options = [FOCBoolAttributeSetting labelsForAttribute];
    int index = [FOCBoolAttributeSetting indexForValue:currentState];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Mode" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showSecondPicker:(ActionStringDoneBlock)doneBlock shamDuration:(int)shamDuration
{
    NSArray *options = [FOCShamDurationAttributeSetting labelsForAttribute];
    int index = [FOCShamDurationAttributeSetting indexForValue:shamDuration];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Sham Period" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showVoltagePicker:(ActionStringDoneBlock)doneBlock voltage:(int)voltage
{
    NSArray *options = [FOCVoltageAttributeSetting labelsForAttribute];
    int index = [FOCVoltageAttributeSetting indexForValue:voltage];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Voltage" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showFrequencyPicker:(ActionStringDoneBlock)doneBlock frequency:(long)frequency
{
    NSArray *options = [FOCFrequencyAttributeSetting labelsForAttribute];
    int index = [FOCFrequencyAttributeSetting indexForValue:frequency];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Frequency" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}


// FIXME below pickers


- (void)showTimePicker
{
    ActionSheetPickerTimeDelegate *delg = [[ActionSheetPickerTimeDelegate alloc] init];
    
    NSNumber *yass1 = @0;
    NSNumber *yass2 = @0;
    
    NSArray *initialSelections = @[yass1, yass2];
    
    [ActionSheetCustomPicker showPickerWithTitle:@"Select Time" delegate:delg showCancelButton:true origin:_collectionView initialSelections:initialSelections];
}

- (void)showCurrentPicker:(ActionStringDoneBlock)doneBlock title:(NSString *)title current:(int)current;
{
    NSArray *options = [FOCCurrentAttributeSetting labelsForAttribute];
    int index = [FOCCurrentAttributeSetting indexForValue:current];
    
    [ActionSheetStringPicker showPickerWithTitle:title rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (void)showCurrentOffsetPicker:(ActionStringDoneBlock)doneBlock title:(NSString *)title current:(int)current;
{
    NSArray *options = [FOCCurrentOffsetAttributeSetting labelsForAttribute];
    int index = [FOCCurrentOffsetAttributeSetting indexForValue:current];
    
    [ActionSheetStringPicker showPickerWithTitle:title rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

// FIXME requires formatting

- (void)showDutyCyclePicker:(ActionStringDoneBlock)doneBlock dutyCycle:(int)dutyCycle
{
    NSArray *options = [FOCDutyCycleAttributeSetting labelsForAttribute];
    int index = 0; // FIXME index selection
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Duty Cycle" rows:options initialSelection:index doneBlock:doneBlock cancelBlock:nil origin:_collectionView];
}

- (NSString *)readableTimeString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    int seconds = number.intValue % 60;
    int mins = (number.intValue - seconds) / 60;
    return [NSString stringWithFormat:@"%02d:%02d", mins, seconds];
}

- (NSString *)readablePercentageString:(id)value
{
    NSNumber *number = (NSNumber *) value;
    return [NSString stringWithFormat:@"%ld%%", number.longValue];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float availableSpace = _collectionView.frame.size.width - (kHorizontalEdgeInset * 3);
    return CGSizeMake(availableSpace / 2, 44);
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kVerticalEdgeInset, kHorizontalEdgeInset, kVerticalEdgeInset, kHorizontalEdgeInset);
}

@end
