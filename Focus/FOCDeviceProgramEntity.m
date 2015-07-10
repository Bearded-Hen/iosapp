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
        _voltage = descriptor[0];
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

- (int)getIntegerFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    int n = (bytes[1] & 0xff << 8) + (bytes[0] & 0xff);
    free(bytes);
    return n;
}

- (long)getLongFromBytes:(NSData *)data
{
    Byte *bytes = (Byte*)malloc(data.length);
    memcpy(bytes, data.bytes, data.length);
    
    long n =    ((long) (bytes[3] & 0xff) << 24) +
                ((long) (bytes[2] & 0xff) << 16) +
                ((long) (bytes[1] & 0xff) << 8) +
                ((long) (bytes[0] & 0xff));
    free(bytes);
    return n;
}

@end
