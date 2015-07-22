//
//  FOCCurrentAttributeSetting.m
//  Focus
//
//  Created by Jamie Lynch on 22/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCCurrentAttributeSetting.h"

static const int kMinCurrent = 1;
static const int kMaxCurrent = 18;
static const int kCurrentScalar = 10;

@implementation FOCCurrentAttributeSetting

+ (NSArray *)labelsForAttribute
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=kMinCurrent; i<=kMaxCurrent; i++) {
        [options addObject:[NSString stringWithFormat:@"%.1f mA", ((float) i) / kCurrentScalar]];
    }
    
    return [options copy];
}

+ (int)indexForValue:(int)value
{
    return -1;
}

+ (int)valueForIncrementIndex:(int)index
{
    return -1;
}

+ (NSString *)labelForValue:(int)value
{
    // FIXME
    return nil;
}

@end
