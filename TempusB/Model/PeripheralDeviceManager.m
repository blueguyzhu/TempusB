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

@property (nonatomic, strong) NSMutableDictionary *devices;
@property (nonatomic, strong) NSMutableArray *employeeList;
@property (nonatomic, strong) NSMutableDictionary *employees;

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


- (TempusEmployee *)employeeWithShortId:(NSString *)shortId {
    return self.employees[shortId];
}



#pragma mark - private methods

- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        //load beacon device list from DB
        self.devices = [[NSMutableDictionary alloc] init];
        NSArray *beaconList = [[DBManager sharedInstance] beaconDeviceList];
        for (TempusBeacon *tempusBeacon in beaconList) {
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
