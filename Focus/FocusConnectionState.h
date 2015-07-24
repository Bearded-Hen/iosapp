//
//  FocusConnectionState.h
//  Focus
//
//  Created by Jamie Lynch on 24/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_FocusConnectionState_h
#define Focus_FocusConnectionState_h

typedef NS_ENUM(NSInteger, FocusConnectionState) {
    CONNECTED,
    CONNECTING,
    SCANNING,
    DISCONNECTED,
    DISABLED,
    UNKNOWN
};

#endif
