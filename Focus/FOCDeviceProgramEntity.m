//
//  ProgramEntity.m
//  Focus
//
//  Created by Jamie Lynch on 10/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import "FOCDeviceProgramEntity.h"

#import "FocusConstants.h"

@implementation FOCDeviceProgramEntity

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
    if (FOC_EMPTY_BYTE != descriptor[0]) {
        _valid = [[NSNumber alloc] initWithBool:descriptor[0]];
    }
    if (FOC_EMPTY_BYTE != descriptor[13]) {
        _sham = [[NSNumber alloc] initWithBool:descriptor[13]];
    }
    
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
    
    // serialise misc data
    NSData *durationData = [firstDescriptor subdataWithRange:NSMakeRange(11, 2)];
    NSData *shamDurationData = [firstDescriptor subdataWithRange:NSMakeRange(14, 2)];
    NSData *currentData = [firstDescriptor subdataWithRange:NSMakeRange(16, 2)];
    NSData *currentOffset = [firstDescriptor subdataWithRange:NSMakeRange(18, 2)];
    
    free(descriptor);
}

- (void)deserialiseSecondDescriptor:(NSData *)secondDescriptor
{
    int length = [secondDescriptor length];
    
    Byte *descriptor = (Byte*)malloc(length);
    memcpy(descriptor, [secondDescriptor bytes], length);
    
    // serialise bools
    if (FOC_EMPTY_BYTE != descriptor[1]) {
        _bipolar = [[NSNumber alloc] initWithBool:descriptor[1]];
    }
    if (FOC_EMPTY_BYTE != descriptor[10]) {
        _randomCurrent = [[NSNumber alloc] initWithBool:descriptor[10]];
    }
    if (FOC_EMPTY_BYTE != descriptor[11]) {
        _randomFrequency = [[NSNumber alloc] initWithBool:descriptor[11]];
    }

    //serialise misc values
    if (FOC_EMPTY_BYTE != descriptor[0]) {
        _voltage = descriptor[0];
    }
    
    // TODO below values
    NSData *frequencyData = [secondDescriptor subdataWithRange:NSMakeRange(2, 4)];
    NSData *dutyCycle = [secondDescriptor subdataWithRange:NSMakeRange(6, 4)];
    
    free(descriptor);
}

- (NSString *)programDebugInfo
{
    NSMutableString *info = [[NSMutableString alloc] init];
    
    [info appendString:[NSString stringWithFormat:@"Program Name '%@', ", _name]];
    [info appendString:[NSString stringWithFormat:@"id='%hhu'", _programId]];
    return info;
}

//public void parseDescriptors(byte apiId,
//                             byte[] descriptor0,
//                             byte[] descriptor1) {
//    
//    this.apiId = apiId;
//    // Decode the first Descriptor:
//    // Btye 0: Valid
//    // Byte 1-9 : Name
//    // Byte 10 : Mode
//    // Byte 11-12 : Duration
//    // Byte 13 : Sham
//    // Byte 14-15 : Duration (Sham)
//    // Byte 16-17 : Current
//    // Byte 18-19 : Current offset
//    if (descriptor0.length >= 20) {
//        valid = getBoolean(descriptor0, 0);
//        //            programId = getString(descriptor0, 1, 9);
//        programMode = ProgramMode.getFromByte(descriptor0[10]);
//        if (duration != null) {
//            duration = getInteger(descriptor0, 11);
//        }
//        sham = getBoolean(descriptor0, 13);
//        shamDuration = getInteger(descriptor0, 14);
//        if (current != null) {
//            current = getInteger(descriptor0, 16);
//        }
//        if (currentOffset != null) {
//            currentOffset = getInteger(descriptor0, 18);
//        }
//    }
//    
//    // Decode the second Descriptor:
//    // Btye 0: Voltage
//    // Byte 1 : Bipolar
//    // Byte 2-5 : Frequency / Min Frequency
//    // Byte 6-9 : Max Frequency / Duty Cycle
//    // Byte 11 : Random Current
//    // Byte 12 : Random Current
//    if (descriptor1.length >= 20) {
//        voltage = getSmallInteger(descriptor1, 0);
//        if (bipolar != null) {
//            bipolar = getBoolean(descriptor1, 1);
//        }
//        if (frequency != null) {
//            frequency = getLong(descriptor1, 2);
//        }
//        if (minFrequency != null) {
//            minFrequency = getLong(descriptor1, 2);
//        }
//        if (maxFrequency != null) {
//            maxFrequency = getLong(descriptor1, 6);
//        }
//        if (dutyCycle != null) {
//            dutyCycle = getLong(descriptor1, 6);
//        }
//    }
//}

@end
