//
//  FOCDurationAttributeSetting.m
//  Focus
//
//  Created by Jamie Lynch on 22/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDurationAttributeSetting.h"

static const int kMinValue = 300;
static const int kMaxValue = 2400;
static const int kIncrement = 1;

@implementation FOCDurationAttributeSetting

+ (NSArray *)labelsForSeconds
{
    NSMutableArray *seconds = [[NSMutableArray alloc] init];
    
    for (int i=0; i<60; i++) {
        [seconds addObject:[NSString stringWithFormat:@"%02d seconds", i]];
    }
    return [seconds copy];
}

+ (NSArray *)labelsForMinutes
{
    NSMutableArray *minutes = [[NSMutableArray alloc] init];
    
    for (int i=5; i<40; i++) {
        [minutes addObject:[NSString stringWithFormat:@"%02d minutes", i]];
    }
    return [minutes copy];
}

@end
