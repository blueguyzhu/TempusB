//
//  LocalDataAccessor.h
//  TempusB
//
//  Created by Wenlu Zhang on 17/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TempusEmployee;

@interface LocalDataAccessor : NSObject

+ (instancetype) sharedInstance;

/*
 * Access local account
 */
- (TempusEmployee *) localAccount;

- (BOOL) storeLocalAccount: (TempusEmployee *)account;

/*
 * Access monitored geolocations;
 * param: 
 *  @locations: TempusLocation array
 */
- (NSArray *) monitoredLocations;

- (BOOL) storeMonitoredLocations: (NSArray *)locations;

/*
 * Access monitored beacons
 * param: 
 *  @beacons: TempusBeacon array
 */
- (NSArray *) monitoredBeacons;

- (BOOL) storeMonitoredBeacons: (NSArray *)beacons;
@end
