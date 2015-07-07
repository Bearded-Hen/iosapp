//
//  FocusDeviceApi.h
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_FocusDeviceApi_h
#define Focus_FocusDeviceApi_h

/**
 * Defines callbacks that will be fired when the Focus device state changes.
 */
@protocol FocusDeviceApi <NSObject>

typedef NS_ENUM(NSInteger, FocusConnectionState) {
    CONNECTED,
    CONNECTING,
    DISCONNECTED,
    UNKNOWN
};

- (void)didChangeConnectionState: (FocusConnectionState *)connectionState;

@end

#endif
