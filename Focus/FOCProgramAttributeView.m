//
//  FOCProgramAttributeView.m
//  Focus
//
//  Created by Jamie Lynch on 16/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCProgramAttributeView.h"
#import "FOCPaddedLabel.h"
#import "FOCColorMap.h"

static NSString *kAttrDarkDefault = @"#CC404040";
static NSString *kAttrDarkPressed = @"#EE404040";
static NSString *kAttrLightDefault = @"#CCFFFFFF";
static NSString *kAttrLightPressed = @"#EEFFFFFF";

static const float kLabelWeighting = 0.63;
static const float kFontSize = 11.0;

@interface FOCProgramAttributeView ()

@property UIColor *colorDarkDefault;
@property UIColor *colorDarkPressed;
@property UIColor *colorLightDefault;
@property UIColor *colorLightPressed;

@property UIButton *keyLabel;
@property UIButton *valueLabel;

@end

@implementation FOCProgramAttributeView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _colorDarkDefault = [FOCColorMap colorFromString:kAttrDarkDefault];
        _colorLightDefault = [FOCColorMap colorFromString:kAttrLightDefault];
        _colorDarkPressed = [FOCColorMap colorFromString:kAttrDarkPressed];
        _colorLightPressed = [FOCColorMap colorFromString:kAttrLightPressed];
        
        int width = self.frame.size.width;
        int height = self.frame.size.height;
        int valueStart = width * kLabelWeighting;
        
        CGRect keyFrame = CGRectMake(0, 0, valueStart, height);
        CGRect valueFrame = CGRectMake(valueStart, 0, width - valueStart, height);
        
        _keyLabel = [[UIButton alloc] initWithFrame:keyFrame];
        _valueLabel = [[UIButton alloc] initWithFrame:valueFrame];
        
        [_keyLabel.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
        [_valueLabel.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
        
        [self setViewColorState:false];
        
        [_keyLabel addTarget:self action:@selector(didTouchDown:)
           forControlEvents:UIControlEventTouchDown];
        
        [_keyLabel addTarget:self action:@selector(didTouchUpInside:)
           forControlEvents: UIControlEventTouchUpInside];
        
        [_keyLabel addTarget:self action:@selector(didTouchUpOutside:)
            forControlEvents: UIControlEventTouchUpOutside];
        
        [self addSubview:_keyLabel];
        [self addSubview:_valueLabel];
    }
    return self;
}

- (void)didTouchDown:(id)sender
{
    [self setViewColorState:true];
}

- (void)didTouchUpInside:(id)sender
{
    [self setViewColorState:false];
}

- (void)didTouchUpOutside:(id)sender
{
    [self setViewColorState:false];
}

- (void)setViewColorState:(bool) pressed
{
    [_valueLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_keyLabel setTitleColor:pressed ? _colorLightPressed : _colorLightDefault forState:UIControlStateNormal] ;
    _keyLabel.backgroundColor = pressed ? _colorDarkPressed : _colorDarkDefault;
    _valueLabel.backgroundColor = pressed ? _colorLightPressed : _colorLightDefault;
}

- (void)updateModel:(FOCDisplayAttributeModel *) model
{
    [_keyLabel setTitle:model.attrLabel forState:UIControlStateNormal];
    [_valueLabel setTitle:model.attrValue forState:UIControlStateNormal];
}

@end
