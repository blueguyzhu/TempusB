//
//  DBManager.h
//  TempusB
//
//  Created by Wenlu Zhang on 26/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#ifndef TempusB_DBManager_h
#define TempusB_DBManager_h

#import <Foundation/Foundation.h>

@class TempusRegMsg;
@class TempusRegRecord;

@interface DBManager : NSObject

+ (instancetype) sharedInstance;

- (NSMutableArray *) beaconDeviceList;

- (BOOL) storeRegMsg: (TempusRegMsg *)msg;

- (NSArray *) regMsgsWithLimit: (NSInteger) limit;

- (BOOL) storeInOutRegRecord:(TempusRegRecord *)record;

- (NSArray *) lastRegRecordsWithLimit: (NSInteger)limit;
@end

#endif
