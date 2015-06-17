//
//  NSObject+PeripheralDeviceManager.m
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "PeripheralDeviceManager.h"
#import "DBManager.h"
#import "TempusBeacon.h"


@interface PeripheralDeviceManager ()

@property (nonatomic, strong) NSMutableDictionary *devices; //Major -> (Minor -> TempusBeacon);
@property (nonatomic, strong) NSMutableDictionary *deviceList;  //shortId -> TempusBeacon;
//@property (atomic, strong) NSMutableArray *employeeList;    //TempusEmployee list
//@property (atomic, strong) NSMutableDictionary *employees;  //shortId -> TempusEmployee

@end



@implementation PeripheralDeviceManager

+ (PeripheralDeviceManager *) sharedManager {
    static PeripheralDeviceManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once (&onceToken, ^{
        sharedInstance = [[PeripheralDeviceManager alloc] initPrivate];
    });
    
    return sharedInstance;
}



#pragma mark - public methods
- (NSString *) shortIdByMajor:(NSNumber *)major andMinor:(NSNumber *)minor {
    NSDictionary  *dict = [self.devices objectForKeyedSubscript: major];;
    
    if (dict) {
        TempusBeacon *tempusBeacon = dict[minor];
        return tempusBeacon.shortId;
    }
    else
        return nil;
}


- (NSString *) shortIdByMajorInt:(NSInteger)major andMinorInt:(NSInteger)minor {
    NSNumber *majorNum = [NSNumber numberWithInteger:major];
    NSNumber *minorNum = [NSNumber numberWithInteger:minor];
    
    return [self shortIdByMajor:majorNum andMinor:minorNum];
}


/*
- (TempusEmployee *)employeeWithShortId:(NSString *)shortId {
    return self.employees[shortId];
}
 */


- (BOOL) beaconExists:(NSString *)shortId {
    return [self.deviceList objectForKey:shortId] != nil;
}



#pragma mark - private methods

- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        //load beacon device list from DB
        NSArray *beaconList = [[DBManager sharedInstance] beaconDeviceList];
        self.devices = [[NSMutableDictionary alloc] initWithCapacity:beaconList.count];
        self.deviceList = [[NSMutableDictionary alloc] initWithCapacity:beaconList.count];
        for (TempusBeacon *tempusBeacon in beaconList) {
            [self.deviceList setObject:tempusBeacon forKey:tempusBeacon.shortId];
            
            NSMutableDictionary *beaconsWithSameMajor = [self.devices objectForKey:[NSNumber numberWithLong:tempusBeacon.major]];
            if (beaconsWithSameMajor) {
                [beaconsWithSameMajor setObject:tempusBeacon forKey:[NSNumber numberWithLong:tempusBeacon.minor]];
            } else {
                beaconsWithSameMajor = [[NSMutableDictionary alloc] init];
                [beaconsWithSameMajor setObject:tempusBeacon forKey:[NSNumber numberWithLong:tempusBeacon.minor]];
                [self.devices setObject:beaconsWithSameMajor forKey:[NSNumber numberWithLong:tempusBeacon.major]];
            }
        }
    }
    
    return self;
}

@end
