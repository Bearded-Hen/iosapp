//
//  FocusUuids.h
//  Focus
//
//  Created by Jamie Lynch on 07/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FocusConstants : NSObject

extern NSString *const BLE_SERVICE_BATTERY;
extern NSString *const BLE_SERVICE_INFO;
extern NSString *const FOC_SERVICE_TDCS;

extern NSString *const FOC_SERVICE_UNKNOWN;

extern NSString *const FOC_CONTROL_CMD_REQUEST;
extern NSString *const FOC_CONTROL_CMD_RESPONSE;
extern NSString *const FOC_DATA_BUFFER;
extern NSString *const FOC_ACTUAL_CURRENT;
extern NSString *const FOC_ACTIVE_MODE_DURATION;
extern NSString *const FOC_ACTIVE_MODE_REMAINING_TIME;

extern const Byte FOC_CMD_MANAGE_PROGRAMS;
extern const Byte FOC_SUBCMD_MAX_PROGRAMS;
extern const Byte FOC_SUBCMD_PROG_STATUS;
extern const Byte FOC_SUBCMD_READ_PROG;
extern const Byte FOC_SUBCMD_WRITE_PROG;
extern const Byte FOC_SUBCMD_ENABLE_PROG;
extern const Byte FOC_SUBCMD_START_PROG;
extern const Byte FOC_SUBCMD_STOP_PROG;

@end
