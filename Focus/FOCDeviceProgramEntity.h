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
 *
 * The following attributes are ALWAYS PRESENT:
 *
 * program mode
 * duration
 * current
 * sham
 * sham period
 * voltage
 *
 * The following attributes are OPTIONALLY PRESENT:
 *
 * bipolar
 * randomCurrent
 * randomFrequency
 * currentOffset
 * frequency
 * duty cycle
 * minFrequency
 * maxFrequency
 */
@interface FOCDeviceProgramEntity : NSObject

extern NSString *const PROG_ATTR_MODE;
extern NSString *const PROG_ATTR_SHAM;
extern NSString *const PROG_ATTR_BIPOLAR;
extern NSString *const PROG_ATTR_RAND_CURR;
extern NSString *const PROG_ATTR_RAND_FREQ;
extern NSString *const PROG_ATTR_DURATION;
extern NSString *const PROG_ATTR_CURRENT;
extern NSString *const PROG_ATTR_VOLTAGE;
extern NSString *const PROG_ATTR_SHAM_DURATION;
extern NSString *const PROG_ATTR_CURR_OFFSET;
extern NSString *const PROG_ATTR_MIN_FREQ;
extern NSString *const PROG_ATTR_MAX_FREQ;
extern NSString *const PROG_ATTR_FREQUENCY;
extern NSString *const PROG_ATTR_DUTY_CYCLE;

typedef NS_ENUM(int, ProgramMode) {
    DCS,
    ACS,
    RNS,
    PCS
};

+ (NSString *)readableLabelFor:(ProgramMode)mode;

- (void)deserialiseDescriptors:(NSData *)firstDescriptor secondDescriptor:(NSData *)secondDescriptor;

- (NSDictionary *)editableAttributes;
- (NSArray *)orderedEditKeys;
- (NSString *)programDebugInfo;

@property Byte programId;
@property NSString *name;
@property NSString *imageName;
@property ProgramMode programMode;

// Bools
@property NSNumber *valid;
@property NSNumber *sham;
@property NSNumber *bipolar;
@property NSNumber *randomCurrent;
@property NSNumber *randomFrequency;

// Ints
@property NSNumber *duration;
@property NSNumber *current;
@property NSNumber *voltage;
@property NSNumber *shamDuration;
@property NSNumber *currentOffset;
@property NSNumber *minFrequency;
@property NSNumber *maxFrequency;

// Longs
@property NSNumber *frequency;
@property NSNumber *dutyCycle;

@end
