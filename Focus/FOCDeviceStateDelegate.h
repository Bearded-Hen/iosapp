//
//  FocusDeviceApi.h
//  Focus
//
//  Created by Jamie Lynch on 30/06/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

/**
 * Defines callbacks that will be fired when the Focus device state changes.
 */
@protocol FOCDeviceStateDelegate <NSObject>

typedef NS_ENUM(NSInteger, FocusConnectionState) {
    CONNECTED,
    CONNECTING,
    SCANNING,
    DISCONNECTED,
    DISABLED,
    UNKNOWN
};

@required
- (void)didChangeConnectionState: (FocusConnectionState)connectionState;

@end
