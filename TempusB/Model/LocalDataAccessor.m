//
//  LocalDataAccessor.m
//  TempusB
//
//  Created by Wenlu Zhang on 17/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "LocalDataAccessor.h"
#import "TempusEmployee.h"
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
    return nil;
}


- (BOOL) storeMonitoredLocations:(NSArray *)locations {
    return YES;
}


#pragma mark - private methods
- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}



@end
