//
//  LocalDataAccessor.m
//  TempusB
//
//  Created by Wenlu Zhang on 17/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "LocalDataAccessor.h"
#import "TempusEmployee.h"
#import "TempusLocation.h"
#import "LightLocalStorageManager.h"


@implementation LocalDataAccessor

static LocalDataAccessor *sharedInstance = nil;
static NSUInteger localAccReadCount = 0;
static NSUInteger localAccWriteCount = 1;
static TempusEmployee *localAccount = nil;


#pragma mark - static methods
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocalDataAccessor alloc] initPrivate];
    });
    
    return sharedInstance;
}


#pragma mark - public methods
- (TempusEmployee *) localAccount {
    if (localAccReadCount >= localAccWriteCount) {
        return localAccount;
    }
    
    NSDictionary *accDictObj = [LightLocalStorageManager readUserAccount];
    if (accDictObj)
        localAccount = [[TempusEmployee alloc] initFromCocoaObj:accDictObj];
    ++localAccReadCount;
    
    return localAccount;
}


- (BOOL) storeLocalAccount:(TempusEmployee *)account {
    NSDictionary *accDictObj = [account toCocoaObj];
    BOOL suc = [LightLocalStorageManager writeUserAccount:accDictObj];
    
    if (suc)
        ++localAccWriteCount;
    
    return suc;
}


- (NSArray *) monitoredLocations {
    NSArray *cocoaObjs = [LightLocalStorageManager readMonitoredLocations];
    NSMutableArray *locObjs = [[NSMutableArray alloc] initWithCapacity:cocoaObjs.count];
    
    for (NSDictionary *cocoaObj in cocoaObjs) {
        TempusLocation *tempusLocation = [[TempusLocation alloc] init];
        tempusLocation.identifier = cocoaObj[@"id"];
        tempusLocation.address = cocoaObj[@"addr"];
        tempusLocation.coordinate = CLLocationCoordinate2DMake([cocoaObj[@"latitude"] floatValue], [cocoaObj[@"longitude"] floatValue]);
        
        [locObjs addObject:tempusLocation];
    }
    
    return locObjs;
}


- (BOOL) storeMonitoredLocations:(NSArray *)locations {
    NSMutableArray *cocoaObjs = [[NSMutableArray alloc] initWithCapacity:locations.count];
    
    for (TempusLocation *loc in locations) {
        NSMutableDictionary *cocoaLocObj = [[NSMutableDictionary alloc] init];
        [cocoaLocObj setObject:loc.identifier forKey:@"id"];
        [cocoaLocObj setObject:loc.address forKey:@"addr"];
        [cocoaLocObj setObject:[NSNumber numberWithFloat:loc.coordinate.latitude] forKey:@"latitude"];
        [cocoaLocObj setObject:[NSNumber numberWithFloat:loc.coordinate.longitude] forKey:@"longitude"];
        
        [cocoaObjs addObject:cocoaLocObj];
    }
    
    return [LightLocalStorageManager writeMonitoredLocations:cocoaObjs];
}


#pragma mark - private methods
- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}



@end
