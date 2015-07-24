//
//  FOCProgramSyncDelegate.h
//  Focus
//
//  Created by Jamie Lynch on 24/07/2015.
//  Copyright (c) 2015 Bearded Hen. All rights reserved.
//

#ifndef Focus_FOCProgramSyncDelegate_h
#define Focus_FOCProgramSyncDelegate_h

@protocol FOCProgramSyncDelegate <NSObject> // FIXME should not be in app delegate

- (void)didChangeDataSet:(NSArray *)dataSet;

@end

#endif
