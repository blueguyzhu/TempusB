//
//  LocalDataAccessor.m
//  TempusB
//
//  Created by Wenlu Zhang on 17/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#define kMONITORED_BEACONS_PLIST            @"monBeacons"
#define kUSER_ACCOUNT_PLIST                 @"user"
#define kMONITORED_LOCATIONS_PLIST          @"locations"

#import "LocalDataAccessor.h"
#import "TempusEmployee.h"
#import "TempusLocation.h"
#import "TempusBeacon.h"
#import "CocoaLumberjack/CocoaLumberjack.h"


@interface LocalDataAccessor ()
+ (id) readDataOfName: (NSString *)fileName;
+ (BOOL) writeData: (id)data toFile: (NSString *)fileName;
@end


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


+ (id)readDataOfName:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [[path stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        DDLogError(@"Cannot find file %@", path);
        return nil;
    }
    
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSError *err = nil;
    NSPropertyListFormat format;
    id plist = [NSPropertyListSerialization propertyListWithData:plistData
                                              options:NSPropertyListBinaryFormat_v1_0
                                               format:&format
                                                error:&err];
    if (err) {
        DDLogError([err description]);
        return nil;
    }
    
    return plist;
}


+ (BOOL) writeData:(id)data toFile:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    path = [[path stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"plist"];
    
    NSString *errStr = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:data
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                          errorDescription:&errStr];
    
    NSError *err = nil;
    [plistData writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (err) {
        DDLogError(@"Write data to file %@ failed.", path);
        DDLogError(err.description);
    }
    
    return err == nil;
}


#pragma mark - public methods
- (TempusEmployee *) localAccount {
    if (localAccReadCount >= localAccWriteCount) {
        return localAccount;
    }
    
    NSDictionary *accDictObj = [self.class readDataOfName:kUSER_ACCOUNT_PLIST];//[LightLocalStorageManager readUserAccount];
    
    if (accDictObj)
        localAccount = [[TempusEmployee alloc] initFromCocoaObj:accDictObj];
    ++localAccReadCount;
    
    return localAccount;
}


- (BOOL) storeLocalAccount:(TempusEmployee *)account {
    NSDictionary *accDictObj = [account toCocoaObj];
    BOOL suc = [self.class writeData:accDictObj toFile:kUSER_ACCOUNT_PLIST]; //[LightLocalStorageManager writeUserAccount:accDictObj];
    
    if (suc)
        ++localAccWriteCount;
    
    return suc;
}


- (NSArray *) monitoredLocations {
    NSArray *cocoaObjs = [self.class readDataOfName:kMONITORED_LOCATIONS_PLIST]; //[LightLocalStorageManager readMonitoredLocations];
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
    
    return [self.class writeData:cocoaObjs toFile:kMONITORED_LOCATIONS_PLIST];
}


- (NSArray *) monitoredBeacons {
    NSArray *cocoaBeacons = (NSArray *)[self.class readDataOfName:kMONITORED_BEACONS_PLIST];
    if (!cocoaBeacons)
        return nil;
    
    NSMutableArray *tempusBeacons = [[NSMutableArray alloc] initWithCapacity:cocoaBeacons.count];
    
    for (NSDictionary *cocoaBeacon in cocoaBeacons) {
        TempusBeacon *tpsBeacon = [[TempusBeacon alloc] init];
        tpsBeacon.identifier = cocoaBeacon[@"id"];
        tpsBeacon.major = [cocoaBeacon[@"major"] integerValue];
        tpsBeacon.minor = [cocoaBeacon[@"minor"] integerValue];
        tpsBeacon.shortId = cocoaBeacon[@"shortId"];
        tpsBeacon.domain = cocoaBeacon[@"domain"];
        
        [tempusBeacons addObject:tpsBeacon];
    }
    
    return tempusBeacons;
}


- (BOOL) storeMonitoredBeacons:(NSArray *)beacons {
    NSMutableArray *cocoaObjs = [[NSMutableArray alloc] initWithCapacity:beacons.count];
    
    for (TempusBeacon *tpsBeacon in beacons) {
        NSMutableDictionary *cocoaBeacon = [[NSMutableDictionary alloc] init];
        cocoaBeacon[@"id"] = tpsBeacon.identifier;
        cocoaBeacon[@"major"] = [@(tpsBeacon.major) stringValue];
        cocoaBeacon[@"minor"] = [@(tpsBeacon.minor) stringValue];
        cocoaBeacon[@"shortId"] = tpsBeacon.shortId;
        cocoaBeacon[@"domain"] = tpsBeacon.domain;
        
        [cocoaObjs addObject:cocoaBeacon];
    }
    
    return [self.class writeData:cocoaObjs toFile:kMONITORED_BEACONS_PLIST];
}


#pragma mark - private methods
- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}



@end
