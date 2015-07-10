//
//  ProgramEntity.h
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A POCO which represents the program data stored on the Focus device.
 */
@interface FOCDeviceProgramEntity : NSObject

typedef NS_ENUM(int, ProgramMode){
    DCS,
    ACS,
    RNS,
    PCS
};

- (void)deserialiseDescriptors:(NSData *)firstDescriptor secondDescriptor:(NSData *)secondDescriptor;

@property Byte programId;
@property NSString *name;
@property ProgramMode programMode;

@property bool *valid;
@property bool *sham;

// Nullable bools
@property NSNumber *bipolar;
@property NSNumber *randomCurrent;
@property NSNumber *randomFrequency;

@property NSInteger duration;
@property NSInteger current;
@property NSInteger voltage;
@property NSInteger shamDuration;

@property NSInteger currentOffset;
@property NSInteger frequency;
@property NSInteger dutyCycle;
@property NSInteger minFrequency;
@property NSInteger maxFrequency;

@end
