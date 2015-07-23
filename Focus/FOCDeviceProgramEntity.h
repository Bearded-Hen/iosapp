//
//  ProgramEntity.h
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataProgram.h"

/**
 * A POCO which represents the program data stored on the Focus device.
 *
 * The following attributes are ALWAYS PRESENT:
 *
 * program mode, duration, current, sham, sham period, voltage
 *
 * The following attributes are OPTIONALLY PRESENT:
 *
 * bipolar, randomCurrent, randomFrequency, currentOffset, frequency, duty cycle, minFrequency, maxFrequency
 *
 * Additional meta attributes will also be present, such as the program ID.
 */
@interface FOCDeviceProgramEntity : NSObject<NSCopying>

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

- (id)initWithCoreDataModel:(CoreDataProgram *)model;

+ (NSString *)readableLabelFor:(ProgramMode)mode;

/**
 * Serialises the program mode for Core Data.
 */
+ (NSNumber *)persistableValueFor:(ProgramMode)mode;

/**
 * Deserialises the program mode from Core Data.
 */
+ (ProgramMode)modeFromPersistedValue:(NSNumber *)value;

/**
 * Populates the model using data retrieved from the Focus device.
 */
- (void)deserialiseDescriptors:(NSData *)firstDescriptor secondDescriptor:(NSData *)secondDescriptor;

/**
 * Populates a core data model that can be persisted.
 */
- (CoreDataProgram *)serialiseToCoreDataModel:(CoreDataProgram *)data;

- (NSDictionary *)editableAttributes;
- (NSArray *)orderedEditKeys;
- (NSString *)programDebugInfo;

@property NSNumber *programId;
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

/**
 * Deserialises a byte array from the Focus device to a int
 */
+ (NSNumber *)getIntegerFromBytes:(NSData *)data;

/**
 * Deserialises a byte array from the Focus device to a long
 */
+ (NSNumber *)getLongFromBytes:(NSData *)data;

/**
 * Serialises an int to a byte
 */
+ (Byte)byteFromInt:(int)value;

@end
