//
//  FOCIntAttributeSetting.m
//  Focus
//
//  Created by Jamie Lynch on 22/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCIntAttributeSetting.h"

@implementation FOCIntAttributeSetting

+ (NSString *)labelForValue:(int)value
{
    return [self labelsForAttribute][[self indexForValue:value]];
}

+ (int)indexForValue:(int)value
{
    return -1;
}

+ (int)valueForIncrementIndex:(int)index
{
    return -1;
}

@end
