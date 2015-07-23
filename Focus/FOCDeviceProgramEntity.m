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

- (id)initWithCoreDataModel:(CoreDataProgram *)model
{
    if (self = [super init]) {
        _programId = model.programId;
        _programMode = [FOCDeviceProgramEntity modeFromPersistedValue:model.programMode];
        
        _name = model.name;
        _imageName = model.imageName;
        
        _valid = model.valid;
        _sham = model.sham;
        _bipolar = model.bipolar;
        _randomCurrent = model.randomCurrent;
        _randomFrequency = model.randomFrequency;
        
        _duration = model.duration;
        _current = model.current;
        _voltage = model.voltage;
        _shamDuration = model.shamDuration;
        _currentOffset = model.currentOffset;
        _minFrequency = model.minFrequency;
        _maxFrequency = model.maxFrequency;
        
        _frequency = model.frequency;
        _dutyCycle = model.dutyCycle;
    }
    return self;
}

- (void)deserialiseDescriptors:(NSData *)firstDescriptor secondDescriptor:(NSData *)secondDescriptor
{
    [self deserialiseFirstDescriptor:firstDescriptor];
    [self deserialiseSecondDescriptor:secondDescriptor];
}

- (void)deserialiseFirstDescriptor:(NSData *)firstDescriptor // FIXME deserialises empty values
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
    
    int nCurrent;
    [currentData getBytes:&nCurrent length:sizeof(nCurrent)];
    
    _duration = [FOCDeviceProgramEntity getIntegerFromBytes:durationData];
    _shamDuration = [FOCDeviceProgramEntity getIntegerFromBytes:shamDurationData];
    _current = [FOCDeviceProgramEntity getIntegerFromBytes:currentData];
    _currentOffset = [FOCDeviceProgramEntity getIntegerFromBytes:currentOffset];
    
    NSLog(@"Deserialised first descriptor %@", firstDescriptor);
    
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
    
    _frequency = [FOCDeviceProgramEntity getLongFromBytes:frequencyData];
    _dutyCycle = [FOCDeviceProgramEntity getLongFromBytes:dutyData];
    
    NSLog(@"Deserialised second descriptor %@", secondDescriptor);
    
    free(descriptor);
}

- (NSString *)programDebugInfo
{
    NSMutableString *info = [[NSMutableString alloc] init];
    
    [info appendString:[NSString stringWithFormat:@"\n***Program Name '%@'***\n", _name]];
    [info appendString:[NSString stringWithFormat:@"id='%@'\n", _programId]];
    [info appendString:[NSString stringWithFormat:@"mode='%d'\n", _programMode]];
    
    [info appendString:[NSString stringWithFormat:@"valid='%d'\n", _valid.boolValue]];
    [info appendString:[NSString stringWithFormat:@"sham='%d'\n", _sham.boolValue]];
    [info appendString:[NSString stringWithFormat:@"bipolar='%d'\n", _bipolar.boolValue]];
    [info appendString:[NSString stringWithFormat:@"randCurr='%d'\n", _randomCurrent.boolValue]];
    [info appendString:[NSString stringWithFormat:@"randFreq='%d'\n", _randomFrequency.boolValue]];
    
    [info appendString:[NSString stringWithFormat:@"duration='%d'\n", _duration.intValue]];
    [info appendString:[NSString stringWithFormat:@"current='%d'\n", _current.intValue]];
    [info appendString:[NSString stringWithFormat:@"voltage='%d'\n", _voltage.intValue]];
    [info appendString:[NSString stringWithFormat:@"shamDuration='%d'\n", _shamDuration.intValue]];
    [info appendString:[NSString stringWithFormat:@"currOffset='%d'\n", _currentOffset.intValue]];
    [info appendString:[NSString stringWithFormat:@"minFreq='%d'\n", _minFrequency.intValue]];
    [info appendString:[NSString stringWithFormat:@"maxFreq='%d'\n", _maxFrequency.intValue]];
    
    [info appendString:[NSString stringWithFormat:@"freq='%ld'\n", _frequency.longValue]];
    [info appendString:[NSString stringWithFormat:@"dutyCycle='%ld'\n", _dutyCycle.longValue]];
    
    return info;
}

+ (NSNumber *)getIntegerFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    int n = (bytes[1] << 8) + bytes[0];
    free(bytes);
    return [[NSNumber alloc] initWithInt:n];
}

+ (NSNumber *)getLongFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    long n =    (((long) bytes[3]) << 24) +
                (((long) bytes[2]) << 16) +
                (((long) bytes[1]) << 8) +
                ((long) bytes[0]);
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
    
    // optional attributes, shown depending on the Program mode.
    
    if (_bipolar != nil && _programMode != DCS) { // not editable for DCS
        [attributes setObject:_bipolar forKey:PROG_ATTR_BIPOLAR];
    }
    if (_randomCurrent != nil && _programMode == RNS) { // only editable for RNS
        [attributes setObject:_randomCurrent forKey:PROG_ATTR_RAND_CURR];
    }
    if (_randomFrequency != nil && _programMode == RNS) { // only editable for RNS
        [attributes setObject:_randomFrequency forKey:PROG_ATTR_RAND_FREQ];
    }
    if (_currentOffset != nil && _programMode != DCS) { // not editable for DCS
        [attributes setObject:_currentOffset forKey:PROG_ATTR_CURR_OFFSET];
    }
    if (_frequency != nil && _programMode != DCS) { // not editable for DCS
        [attributes setObject:_frequency forKey:PROG_ATTR_FREQUENCY];
    }
     // not editable for ACS/DCS
    if (_dutyCycle != nil && (_programMode != ACS && _programMode != DCS)) {
        [attributes setObject:_dutyCycle forKey:PROG_ATTR_DUTY_CYCLE];
    }
    
    return attributes;
}

- (NSArray *)orderedEditKeys
{
    NSMutableArray *editKeys = [[NSMutableArray alloc] init];
    
    [editKeys addObject:PROG_ATTR_SHAM_DURATION];
    [editKeys addObject:PROG_ATTR_VOLTAGE];
    
    if (_bipolar != nil && _programMode != DCS) {
        [editKeys addObject:PROG_ATTR_BIPOLAR];
    }
    
    [editKeys addObject:PROG_ATTR_SHAM];
    
    if (_randomFrequency != nil && _programMode == RNS) {
        [editKeys addObject:PROG_ATTR_RAND_FREQ];
    }
    if (_randomCurrent != nil && _programMode == RNS) {
        [editKeys addObject:PROG_ATTR_RAND_CURR];
    }
    
    if (_currentOffset != nil && _programMode != DCS) {
        [editKeys addObject:PROG_ATTR_CURR_OFFSET];
    }
    if (_dutyCycle != nil && (_programMode != ACS && _programMode != DCS)) {
        [editKeys addObject:PROG_ATTR_DUTY_CYCLE];
    }
    
    [editKeys addObject:PROG_ATTR_DURATION];
    
    if (_frequency != nil && _programMode != DCS) {
        [editKeys addObject:PROG_ATTR_FREQUENCY];
    }
    [editKeys addObject:PROG_ATTR_MODE];
    [editKeys addObject:PROG_ATTR_CURRENT];

    return editKeys;
}

#pragma mark Core Data

- (CoreDataProgram *)serialiseToCoreDataModel:(CoreDataProgram *)data
{
    
    data.programId = _programId;
    data.programMode = [FOCDeviceProgramEntity persistableValueFor:_programMode];
    data.name = _name;
    data.imageName = _imageName;
    
    data.valid = _valid;
    data.sham = _sham;
    data.bipolar = _bipolar;
    data.randomCurrent = _randomCurrent;
    data.randomFrequency = _randomFrequency;
    
    data.duration = _duration;
    data.current = _current;
    data.voltage = _voltage;
    data.shamDuration = _shamDuration;
    data.currentOffset = _currentOffset;
    data.minFrequency = _minFrequency;
    data.maxFrequency = _maxFrequency;
    
    data.frequency = _frequency;
    data.dutyCycle = _dutyCycle;

    return data;
}

- (NSComparisonResult)compare:(FOCDeviceProgramEntity *)otherObject {
    return [self.name compare:otherObject.name];
}

#pragma mark Device data serialisation


+ (NSString *)readableLabelFor:(ProgramMode)mode
{
    switch (mode) {
        case PCS: return @"tPCS";
        case DCS: return @"tDCS";
        case ACS: return @"tACS";
        case RNS: return @"tRNS";
    }
}

+ (NSNumber *)persistableValueFor:(ProgramMode)mode
{
    switch (mode) {
        case PCS: return [[NSNumber alloc] initWithInt:0];
        case DCS: return [[NSNumber alloc] initWithInt:1];
        case ACS: return [[NSNumber alloc] initWithInt:2];
        case RNS: return [[NSNumber alloc] initWithInt:3];
        default: return 0;
    }
}

+ (ProgramMode)modeFromPersistedValue:(NSNumber *)value
{
    switch (value.intValue) {
        case 0: return PCS;
        case 1: return DCS;
        case 2: return ACS;
        case 3: return RNS;
        default: return DCS;
    }
}

+ (Byte)byteFromInt:(int)value
{
    return (Byte) value;
}

//private static void putBoolean(byte[] data, boolean value, int index) {
//
//    data[index] = (byte) (value ? 0x01 : 0x00);
//}
//
//private static void putString(byte[] data, String value, int start, int end) {
//
//    for (int i = start; i <= end; i++) {
//
//        if (i < value.length() + start) {
//            data[i] = (byte) (value.charAt(i - start));
//        }
//        else {
//            data[i] = 0x00;
//        }
//    }
//}
//
//private static void putLong(byte[] data, long value, int start) {
//
//    data[start + 3] = (byte) ((value >> 24) & 0xff);
//    data[start + 2] = (byte) ((value >> 16) & 0xff);
//    data[start + 1] = (byte) ((value >> 8) & 0xff);
//    data[start] = (byte) (value & 0xff);
//}
//
//private static void putInteger(byte[] data, int value, int start) {
//
//    data[start + 1] = (byte) ((value >> 8) & 0xff);
//    data[start] = (byte) (value & 0xff);
//}

@end
