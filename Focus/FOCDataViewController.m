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

@interface FOCDataViewController ()

@end

static NSString *kBluetoothConnected = @"bluetooth_connected.png";
static NSString *kBluetoothDisconnected = @"bluetooth_disconnected.png";
static NSString *kBluetoothDisabled = @"bluetooth_disabled.png";

static const int kVerticalEdgeInset = 20;
static const int kHorizontalEdgeInset = 10;

@interface FOCDataViewController ()

@property NSDictionary *editableAttributes;
@property NSArray *orderedEditKeys;

@end

@implementation FOCDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [_btnPlayProgram.titleLabel setFont:[FOCFontAwesome font]];
    [_btnProgramSettings.titleLabel setFont:[FOCFontAwesome font]];
    
    [_btnPlayProgram setTitle:[FOCFontAwesome unicodeForIcon:@"fa-play"] forState:UIControlStateNormal];
    [_btnProgramSettings setTitle:[FOCFontAwesome unicodeForIcon:@"fa-cog"] forState:UIControlStateNormal];
    
    _programTitleLabel.text = [_program name];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    _backgroundImageView.image = [UIImage imageNamed:_program.imageName];
    
    _orderedEditKeys = [_program orderedEditKeys];
    _editableAttributes = [_program editableAttributes];
    
    [_collectionView reloadData];
}

-(void)notifyConnectionStateChanged:(FocusConnectionState)state
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
            imagePath = kBluetoothConnected;
            break;
        }
    }
    _bluetoothConnectionIcon.image = [UIImage imageNamed:imagePath];
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
    NSString *title;
    
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        title = @"MODE";
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey]) {
        title = @"SHAM";
    }
    else if ([PROG_ATTR_BIPOLAR isEqualToString:dataKey]) {
        title = @"BIPOLAR";
    }
    else if ([PROG_ATTR_RAND_CURR isEqualToString:dataKey]) {
        title = @"R. CURRENT";
    }
    else if ([PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        title = @"R. FREQ";
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey]) {
        title = @"TIME";
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        title = @"CURRENT";
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        title = @"VOLTAGE";
    }
    else if ([PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        title = @"SHAM PERIOD";
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        title = @"OFFSET";
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        title = @"CURRENT";
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        title = @"FREQUENCY";
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        title = @"DUTY CYCLE";
    }
    else {
        title = @"";
    }
    return title;
}

/**
 * Returns a human-readable string that describes a Program Attribute's current value.
 */
- (NSString *)valueForAttrKey:(NSString *)dataKey
{
    NSString *valueText;
    id value = [_editableAttributes objectForKey:dataKey];
    
    if ([PROG_ATTR_MODE isEqualToString:dataKey]) {
        // TODO
    }
    else if ([PROG_ATTR_SHAM isEqualToString:dataKey] ||
             [PROG_ATTR_BIPOLAR isEqualToString:dataKey] ||
             [PROG_ATTR_RAND_CURR isEqualToString:dataKey] ||
             [PROG_ATTR_RAND_FREQ isEqualToString:dataKey]) {
        
        return [self readableBoolString:value];
    }
    else if ([PROG_ATTR_DURATION isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_VOLTAGE isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_SHAM_DURATION isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_CURR_OFFSET isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_CURRENT isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_FREQUENCY isEqualToString:dataKey]) {
        
    }
    else if ([PROG_ATTR_DUTY_CYCLE isEqualToString:dataKey]) {
        
    }
    else {
        valueText = @"";
    }
    return valueText;
}

- (NSString *)readableBoolString:(id)value
{
    return (BOOL) value ? @"ON" : @"OFF";
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
    
    CGRect cellFrame = cell.frame;
    CGSize cellSize = cell.frame.size;
    
    float valueStart = cellSize.width * 0.6;
    
    CGRect keyFrame = CGRectMake(0, 0, valueStart, cellSize.height);
    CGRect valueFrame = CGRectMake(valueStart, 0, cellSize.width, cellSize.height);
    
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:keyFrame];
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
    
    keyLabel.text = model.attrLabel;
    valueLabel.text = model.attrValue;
    
    keyLabel.font = [UIFont systemFontOfSize:12.0];
    valueLabel.font = [UIFont systemFontOfSize:12.0];
    
    keyLabel.backgroundColor = [UIColor grayColor];
    valueLabel.backgroundColor = [UIColor whiteColor];
    
    for (UIView *view in [cell subviews]) {
        [cell removeFromSuperview];
    }
    
    [cell addSubview:keyLabel];
    [cell addSubview:valueLabel];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO item selected
    NSLog(@"Selected program attribute at index %d", indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO item deselected
    NSLog(@"Deselected program attribute at index %d", indexPath.item);
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float availableSpace = _collectionView.frame.size.width - (kHorizontalEdgeInset * 3);
    return CGSizeMake(availableSpace / 2, 40);
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kVerticalEdgeInset, kHorizontalEdgeInset, kVerticalEdgeInset, kHorizontalEdgeInset);
}

@end
