//
//  ProgramSyncDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 24/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_ProgramSyncDelegate_h
#define Focus_ProgramSyncDelegate_h

@protocol ProgramSyncDelegate <NSObject>

- (void)didFinishProgramSync:(NSError *) error;

@end

#endif
