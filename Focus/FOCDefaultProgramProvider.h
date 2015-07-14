//
//  FOCDefaultProgramProvider.h
//  Focus
//
//  Created by Jamie Lynch on 14/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FOCDeviceProgramEntity.h"

/**
 * Returns Focus Program models with their default settings.
 */
@interface FOCDefaultProgramProvider : NSObject

+(FOCDeviceProgramEntity *)gamer;
+(FOCDeviceProgramEntity *)enduro;
+(FOCDeviceProgramEntity *)wave;
+(FOCDeviceProgramEntity *)pulse;
+(FOCDeviceProgramEntity *)noise;

+(NSArray *) allDefaults;

@end
