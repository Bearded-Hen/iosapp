//
//  CurrentNotification.m
//  Focus
//
//  Created by Jamie Lynch on 28/08/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "CurrentNotification.h"

@implementation CurrentNotification

- (id)initWithCurrent:(int)current
{
    if (self = [super init]) {
        _current = current;
        _receivedDate = [NSDate date];
    }
    return self;
}

@end
