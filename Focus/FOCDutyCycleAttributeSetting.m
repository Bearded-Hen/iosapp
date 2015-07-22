//
//  FOCDutyCycleAttributeSetting.m
//  Focus
//
//  Created by Jamie Lynch on 22/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDutyCycleAttributeSetting.h"

static const int kMinDutyCycle = 20;
static const int kMaxDutyCycle = 80;

@implementation FOCDutyCycleAttributeSetting

+ (NSArray *)labelsForAttribute
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=kMinDutyCycle; i<=kMaxDutyCycle; i++) {
        [options addObject:[NSString stringWithFormat:@"%d %%", i]];
    }
    return [options copy];
}

+ (int)indexForValue:(long)value
{
    return -1; // FIXME
}

+ (long)valueForIncrementIndex:(int)index
{
    return -1; // FIXME
}

+ (NSString *)labelForValue:(long)value
{
    // FIXME
    return nil;
}

@end
