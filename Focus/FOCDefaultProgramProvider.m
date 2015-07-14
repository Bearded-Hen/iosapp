//
//  FOCDefaultProgramProvider.m
//  Focus
//
//  Created by Jamie Lynch on 14/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDefaultProgramProvider.h"

@implementation FOCDefaultProgramProvider

+(FOCDeviceProgramEntity *)gamer
{
    FOCDeviceProgramEntity *entity = [[FOCDeviceProgramEntity alloc] init];
    entity.name = @"Gamer";
    entity.programMode = DCS;
    entity.current = 1500;
    entity.duration = 600;
    entity.voltage = 20;
    entity.sham = false;
    entity.shamDuration = 35;
    
    return entity;
}

+(FOCDeviceProgramEntity *)enduro
{
    FOCDeviceProgramEntity *entity = [[FOCDeviceProgramEntity alloc] init];
    entity.name = @"Enduro";
    entity.programMode = DCS;
    entity.current = 1700;
    entity.duration = 900;
    entity.voltage = 20;
    entity.sham = false;
    entity.shamDuration = 45;
    
    return entity;
}

+(FOCDeviceProgramEntity *)wave
{
    FOCDeviceProgramEntity *entity = [[FOCDeviceProgramEntity alloc] init];
    entity.name = @"Wave";
    entity.programMode = ACS;
    entity.current = 1500;
    entity.duration = 1080;
    entity.voltage = 30;
    entity.sham = false;
    entity.shamDuration = 25;
    
    entity.bipolar = [NSNumber numberWithBool:true];
    entity.currentOffset = 100;
    entity.frequency = 1000;
    
    return entity;
}

+(FOCDeviceProgramEntity *)pulse
{
    FOCDeviceProgramEntity *entity = [[FOCDeviceProgramEntity alloc] init];
    entity.name = @"Pulse";
    entity.programMode = PCS;
    entity.current = 1500;
    entity.duration = 600;
    entity.voltage = 15;
    entity.sham = false;
    entity.bipolar = false;
    entity.shamDuration = 25;
    
    entity.currentOffset = 1200;
    entity.frequency = 40000;
    entity.dutyCycle = 20;
    
    return entity;
}

+(FOCDeviceProgramEntity *)noise
{
    FOCDeviceProgramEntity *entity = [[FOCDeviceProgramEntity alloc] init];
    entity.name = @"Noise";
    entity.programMode = RNS;
    entity.current = 1600;
    entity.duration = 600;
    entity.voltage = 20;
    entity.sham = false;
    entity.bipolar = false;
    entity.shamDuration = 25;
    
    entity.frequency = 1000;
    entity.randomCurrent = [NSNumber numberWithBool:true];
    entity.randomFrequency = [NSNumber numberWithBool:true];
    
    return entity;
}


+(NSArray *) allDefaults
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[self gamer]];
    [array addObject:[self enduro]];
    [array addObject:[self wave]];
    [array addObject:[self pulse]];
    [array addObject:[self noise]];
    return array;
}


@end
