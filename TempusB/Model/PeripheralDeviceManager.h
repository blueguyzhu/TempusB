//
//  NSObject+PeripheralDeviceManager.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TempusEmployee;
@class TempusBeacon;

@interface PeripheralDeviceManager : NSObject 

+ (PeripheralDeviceManager *) sharedManager;

- (NSString *) shortIdByMajor: (NSNumber *)major andMinor: (NSNumber *)minor;
- (NSString *) shortIdByMajorInt: (NSInteger)major andMinorInt: (NSInteger)minor;
//- (TempusEmployee *) employeeWithShortId: (NSString *)shortId;
- (BOOL) beaconExists: (NSString *)shortId;
- (TempusBeacon *) beaconWithShortId: (NSString *)shortId;
@end
