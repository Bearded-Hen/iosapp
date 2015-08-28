//
//  CurrentNotification.h
//  Focus
//
//  Created by Jamie Lynch on 28/08/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentNotification : NSObject

- (id)initWithCurrent:(int)current;

@property int current;
@property NSDate *receivedDate;

@end
