//
//  FOCShamDurationAttributeSetting.m
//  Focus
//
//  Created by Jamie Lynch on 22/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCShamDurationAttributeSetting.h"

static const int kMinShamDuration = 0;
static const int kMaxShamDuration = 50;

@implementation FOCShamDurationAttributeSetting

+ (NSArray *)labelsForAttribute
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    for (int i=kMinShamDuration; i<=kMaxShamDuration; i++) {
        [options addObject:[NSString stringWithFormat:@"%d s", i]];
    }
    return [options copy];
}

+ (int)indexForValue:(int)value
{
    return value;
}

+ (int)valueForIncrementIndex:(int)index
{
    return index;
}

@end
