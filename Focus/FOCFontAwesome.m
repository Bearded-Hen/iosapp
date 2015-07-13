//
//  FOCFontAwesome.m
//  Focus
//
//  Created by Jamie Lynch on 13/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCFontAwesome.h"

@implementation FOCFontAwesome

NSString *const FONT_AWESOME = @"FontAwesome";

static NSDictionary *faMap;

+(void)initialize
{
    faMap = @{
              @"fa-play"      : @"\uf04b",
              @"fa-stop"      : @"\uf04d",
              @"fa-cog"      : @"\uf013"
              };
}

+(NSString *) unicodeForIconNamed:(NSString *)iconName
{
    if (faMap == nil) {
        [self initialize];
    }
    
    NSString *unicodeValue = [faMap objectForKey:iconName];
    return (unicodeValue == nil) ? [faMap objectForKey:@"fa-question-circle"] : unicodeValue;
}

@end