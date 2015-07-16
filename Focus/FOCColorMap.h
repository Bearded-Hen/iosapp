//
//  FOMColorMap.h
//  Focus
//
//  Created by Jamie Lynch on 16/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Converts hex strings to UIColors
 */
@interface FOCColorMap : NSObject

+(UIColor *) colorFromString: (NSString *) colorString;

@end
