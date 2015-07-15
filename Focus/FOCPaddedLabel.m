//
//  FOCPaddedLabel.m
//  Focus
//
//  Created by Jamie Lynch on 15/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCPaddedLabel.h"

static const int kPaddingSize = 4;

@implementation FOCPaddedLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(kPaddingSize, kPaddingSize, kPaddingSize, kPaddingSize);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
