//
//  MaxProgramCountRequest.h
//  Focus
//
//  Created by Jamie Lynch on 09/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FOCBasePeripheralManager.h"

@interface FOCProgramSyncManager : FOCBasePeripheralManager

- (void)startProgramSync:(CBCharacteristic *)controlCmdRequest controlCmdResponse:(CBCharacteristic *)controlCmdResponse dataBuffer:(CBCharacteristic *)dataBuffer;

@end
