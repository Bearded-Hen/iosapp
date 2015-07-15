//
//  ProgramEntity.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDeviceProgramEntity.h"
#import "FocusConstants.h"
#import "FOCProgramModeWrapper.h"

@implementation FOCDeviceProgramEntity

NSString *const PROG_ATTR_MODE = @"PROG_ATTR_MODE";
NSString *const PROG_ATTR_SHAM = @"PROG_ATTR_SHAM";
NSString *const PROG_ATTR_BIPOLAR = @"PROG_ATTR_BIPOLAR";
NSString *const PROG_ATTR_RAND_CURR = @"PROG_ATTR_RAND_CURR";
NSString *const PROG_ATTR_RAND_FREQ = @"PROG_ATTR_RAND_FREQ";
NSString *const PROG_ATTR_DURATION = @"PROG_ATTR_DURATION";
NSString *const PROG_ATTR_CURRENT = @"PROG_ATTR_CURRENT";
NSString *const PROG_ATTR_VOLTAGE = @"PROG_ATTR_VOLTAGE";
NSString *const PROG_ATTR_SHAM_DURATION = @"PROG_ATTR_SHAM_DURATION";
NSString *const PROG_ATTR_CURR_OFFSET = @"PROG_ATTR_CURR_OFFSET";
NSString *const PROG_ATTR_MIN_FREQ = @"PROG_ATTR_MIN_FREQ";
NSString *const PROG_ATTR_MAX_FREQ = @"PROG_ATTR_MAX_FREQ";
NSString *const PROG_ATTR_FREQUENCY = @"PROG_ATTR_FREQUENCY";
NSString *const PROG_ATTR_DUTY_CYCLE = @"PROG_ATTR_DUTY_CYCLE";

- (void)deserialiseDescriptors:(NSData *)firstDescriptor secondDescriptor:(NSData *)secondDescriptor
{
    [self deserialiseFirstDescriptor:firstDescriptor];
    [self deserialiseSecondDescriptor:secondDescriptor];
}

- (void)deserialiseFirstDescriptor:(NSData *)firstDescriptor
{
    int length = [firstDescriptor length];
    
    Byte *descriptor = (Byte*)malloc(length);
    memcpy(descriptor, [firstDescriptor bytes], length);
    
    // serialise bools
    _valid = [[NSNumber alloc] initWithBool:descriptor[0]];
    _sham = [[NSNumber alloc] initWithBool:descriptor[13]];
    
    // serialise program mode
    switch (descriptor[10]) {
        case 0x00: _programMode = DCS; break;
        case 0x01: _programMode = ACS; break;
        case 0x02: _programMode = RNS; break;
        case 0x03: _programMode = PCS; break;
    }
    
    // serialise program name
    int nameLength = 0;
    
    for (int i=1; i<=9; i++) {
        if (descriptor[i] != FOC_EMPTY_BYTE) { // don't want to include empty bytes
            nameLength++;
        }
        else {
            break;
        }
    }
    NSData *nameData = [firstDescriptor subdataWithRange:NSMakeRange(1, nameLength)];
    _name = [[NSString alloc] initWithBytes:nameData.bytes length:nameData.length encoding:NSUTF8StringEncoding];
    
    // serialise duration/current data
    NSData *durationData = [firstDescriptor subdataWithRange:NSMakeRange(11, 2)];
    NSData *shamDurationData = [firstDescriptor subdataWithRange:NSMakeRange(14, 2)];
    NSData *currentData = [firstDescriptor subdataWithRange:NSMakeRange(16, 2)];
    NSData *currentOffset = [firstDescriptor subdataWithRange:NSMakeRange(18, 2)];
    
    _duration = [self getIntegerFromBytes:durationData];
    _shamDuration = [self getIntegerFromBytes:shamDurationData];
    _current = [self getIntegerFromBytes:currentData];
    _currentOffset = [self getIntegerFromBytes:currentOffset];
    
    free(descriptor);
}

- (void)deserialiseSecondDescriptor:(NSData *)secondDescriptor
{
    int length = [secondDescriptor length];
    
    Byte *descriptor = (Byte*)malloc(length);
    memcpy(descriptor, [secondDescriptor bytes], length);
    
    // serialise bools
    _bipolar = [[NSNumber alloc] initWithBool:descriptor[1]];
    _randomCurrent = [[NSNumber alloc] initWithBool:descriptor[10]];
    _randomFrequency = [[NSNumber alloc] initWithBool:descriptor[11]];
    
    //serialise misc values
    if (FOC_EMPTY_BYTE != descriptor[0]) {
        _voltage = [[NSNumber alloc] initWithInt:descriptor[0]];
    }
    
    // TODO below values
    NSData *frequencyData = [secondDescriptor subdataWithRange:NSMakeRange(2, 4)];
    NSData *dutyData = [secondDescriptor subdataWithRange:NSMakeRange(6, 4)];
    
    _frequency = [self getLongFromBytes:frequencyData];
    _dutyCycle = [self getLongFromBytes:dutyData];
    
    free(descriptor);
}

- (NSString *)programDebugInfo
{
    NSMutableString *info = [[NSMutableString alloc] init];
    
    [info appendString:[NSString stringWithFormat:@"Program Name '%@', ", _name]];
    [info appendString:[NSString stringWithFormat:@"id='%hhu'", _programId]];
    return info;
}

- (NSNumber *)getIntegerFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    int n = (bytes[1] & 0xff << 8) + (bytes[0] & 0xff);
    free(bytes);
    return [[NSNumber alloc] initWithInt:n];
}

- (NSNumber *)getLongFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    long n =    ((long) (bytes[3] & 0xff) << 24) +
                ((long) (bytes[2] & 0xff) << 16) +
                ((long) (bytes[1] & 0xff) << 8) +
                ((long) (bytes[0] & 0xff));
    free(bytes);
    return [[NSNumber alloc] initWithLong:n];
}

- (NSDictionary *)editableAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    FOCProgramModeWrapper *wrapper = [[FOCProgramModeWrapper alloc] initWithMode:_programMode];
    
    // mandatory attributes

    [attributes setValue:wrapper forKey:PROG_ATTR_MODE];
    [attributes setObject:_duration forKey:PROG_ATTR_DURATION];
    [attributes setObject:_current forKey:PROG_ATTR_CURRENT];
    [attributes setObject:_sham forKey:PROG_ATTR_SHAM];
    [attributes setObject:_shamDuration forKey:PROG_ATTR_SHAM_DURATION];
    [attributes setObject:_voltage forKey:PROG_ATTR_VOLTAGE];
    
    // optional attributes
    
    if (_bipolar != nil) {
        [attributes setObject:_bipolar forKey:PROG_ATTR_BIPOLAR];
    }
    if (_randomCurrent != nil) {
        [attributes setObject:_randomCurrent forKey:PROG_ATTR_RAND_CURR];
    }
    if (_randomFrequency != nil) {
        [attributes setObject:_randomFrequency forKey:PROG_ATTR_RAND_FREQ];
    }
    if (_currentOffset != nil) {
        [attributes setObject:_currentOffset forKey:PROG_ATTR_CURR_OFFSET];
    }
    if (_frequency != nil) {
        [attributes setObject:_frequency forKey:PROG_ATTR_FREQUENCY];
    }
    if (_dutyCycle != nil) {
        [attributes setObject:_dutyCycle forKey:PROG_ATTR_DUTY_CYCLE];
    }
    
    return attributes;
}

- (NSArray *)orderedEditKeys
{
    NSMutableArray *editKeys = [[NSMutableArray alloc] init];
    
    [editKeys addObject:PROG_ATTR_MODE];
    [editKeys addObject:PROG_ATTR_DURATION];
    [editKeys addObject:PROG_ATTR_CURRENT];
    [editKeys addObject:PROG_ATTR_SHAM];
    [editKeys addObject:PROG_ATTR_SHAM_DURATION];
    [editKeys addObject:PROG_ATTR_VOLTAGE];
    
    if (_bipolar != nil) {
        [editKeys addObject:PROG_ATTR_BIPOLAR];
    }
    if (_randomCurrent != nil) {
        [editKeys addObject:PROG_ATTR_RAND_CURR];
    }
    if (_randomFrequency != nil) {
        [editKeys addObject:PROG_ATTR_RAND_FREQ];
    }
    if (_currentOffset != nil) {
        [editKeys addObject:PROG_ATTR_CURR_OFFSET];
    }
    if (_frequency != nil) {
        [editKeys addObject:PROG_ATTR_FREQUENCY];
    }
    if (_dutyCycle != nil) {
        [editKeys addObject:PROG_ATTR_DUTY_CYCLE];
    }

    return editKeys;
}

@end
