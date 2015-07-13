//
//  FOCFontAwesome.h
//  Focus
//
//  Created by Jamie Lynch on 13/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FOCFontAwesome : NSObject

+(NSString *) unicodeForIcon:(NSString *)iconName;
+(UIFont *) font;

extern NSString *const FONT_AWESOME;
extern const float DEFAULT_ICON_SIZE;

@end
