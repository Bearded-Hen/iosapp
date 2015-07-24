//
//  BluetoothPairingDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 24/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_BluetoothPairingDelegate_h
#define Focus_BluetoothPairingDelegate_h

@protocol BluetoothPairingDelegate <NSObject>

- (void)didDiscoverBluetoothPairState:(BOOL)paired error:(NSError *)error;

@end

#endif
