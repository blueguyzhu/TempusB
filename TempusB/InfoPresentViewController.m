//
//  FirstViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kREG_MSG_DISP_LMT           20
#define kUUID_STR                   @"f7826da6-4fa2-4e98-8024-bc5b71e0893e"
#define kREGION_ID                  @"Tempus_Beacon"
#define kBEACON_OUT_OF_RANGE_LIMIT  10

#import "InfoPresentViewController.h"
#import "NSString+HeightCalc.h"
#import "PeripheralDeviceManager.h"
#import "TempusEmployee.h"
#import "TempusRemoteService.h"
#import "TempusRemoteServiceResponseDelegate.h"
#import "TempusResult.h"
//#import "RemoteRegEntry.h"
#import "TempusRegMsg.h"
#import "TempusBeacon.h"
#import "TempusInOutRegRecord.h"
#import "DBManager.h"
#import "LocalDataAccessor.h"
#import <CocoaLumberjack.h>
#import <CoreLocation/CoreLocation.h>



@interface InfoPresentViewController () <CLLocationManagerDelegate, TempusRemoteServiceResponseDelegate>

@property (nonatomic, strong) NSArray *msgBuf;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *beingRangedBeacons;   //tempusBeacons which are being ranged
@property (nonatomic, strong) NSMutableDictionary *beingRangedBeaconsCounter;    //it contains beacons and counters which are being tracked currently
@property (nonatomic, strong) NSMutableArray *cachedRegEntries;

@property (nonatomic, strong) PeripheralDeviceManager *peripheralDeviceManager; //it contains all the beacons

@property (nonatomic, strong) TempusInOutRegRecord *lastInOutRegRecord;
@end



@implementation InfoPresentViewController
static NSString *tmpStaticStr = @"2015-12-01 12:30:41 This is an example message";

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self initiation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.msgBuf = [[DBManager sharedInstance] regMsgsWithLimit:kREG_MSG_DISP_LMT];
    [self.msgTableView reloadData];
    
    self.lastInOutRegRecord = nil;
    NSArray *regRecords = [[DBManager sharedInstance] lastRegRecordsWithLimit:1];
    if (regRecords && regRecords.count)
        self.lastInOutRegRecord = regRecords[0];
}


#pragma mark - Delegate of CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    //CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    DDLogDebug(@"Did start to monitor region: %@", region.identifier);
//    [manager startRangingBeaconsInRegion:beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    DDLogError(@"Monitor region %@ failed. \n%@. %@", region.identifier, error.localizedDescription, error.localizedFailureReason);
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"Location manager failed to retrieve location value. \n %@. %@", error.localizedDescription, error.localizedFailureReason);
}


- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (CLRegionStateInside == state) {
        DDLogInfo(@"Region state is inside.");
        [manager startUpdatingLocation];
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }else if (CLRegionStateOutside == state) {
        [manager stopUpdatingLocation];
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        DDLogInfo(@"Region state is outside.");
    }else {
        DDLogWarn(@"Region state is unknown.");
    }
}


- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    DDLogInfo(@"Enter into region: %@", region.identifier);
    [manager startUpdatingLocation];
    [manager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
}


- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    DDLogInfo(@"Exit region: %@", region.identifier);
    [manager stopUpdatingLocation];
    [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
}


- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    DDLogInfo(@"Found %ld beacons in region %@", beacons.count, region.identifier);
    
    for (CLBeacon *beacon in beacons) {
        TempusBeacon *tempusBeacon = [[TempusBeacon alloc] init];
        tempusBeacon.major = [beacon.major integerValue];
        tempusBeacon.minor = [beacon.minor integerValue];
        //exists already
        //if ([self.registeredBeaconsMajor containsObject:beacon.major]) {
        if ([self.beingRangedBeacons containsObject:tempusBeacon]) {
            NSString *shortId = [self.peripheralDeviceManager shortIdByMajor:beacon.major andMinor:beacon.minor];
        
            //the shortId has been disconnected with previous employee
            if (shortId && shortId.length && ![[[LocalDataAccessor sharedInstance] localAccount].shortId isEqualToString:shortId]) {
                DDLogInfo(@"Beacon (%@, %@, %@) has been disconnected with the employee. \nRemoving it from registred beacon list...",
                          beacon.major, beacon.minor, shortId);
                //[self.registeredBeaconsMajor removeObject:beacon.major];
                [self.beingRangedBeacons removeObject:tempusBeacon];
                //[self.registeredBeaconsCounter removeObjectForKey:beacon.major];
                [self.beingRangedBeaconsCounter removeObjectForKey:tempusBeacon];
            }else { //update counter
                DDLogInfo(@"Range beacon (%@, %@, %@). Updating counter...", beacon.major, beacon.minor, shortId);
                //self.registeredBeaconsCounter[beacon.major] = @0;
                self.beingRangedBeaconsCounter[tempusBeacon] = @0;
            }
            
            continue;
        }
        
        //new beacon detected
        NSString *shortId = [self.peripheralDeviceManager shortIdByMajor:beacon.major andMinor:beacon.minor];
        
        //beacon is not in the to-be-monitored device list
        if (!shortId || shortId.length == 0) {
            DDLogDebug(@"Beacon (%@, %@) is not in the device list. Ignore it.", beacon.major, beacon.minor);
            continue;
        }
        
        tempusBeacon.shortId = shortId;
        
        //the beacon is not assigned to anyone
        TempusEmployee *employee = [[LocalDataAccessor sharedInstance] localAccount];
        if (!(employee && [employee.shortId isEqualToString:shortId])) {
            DDLogDebug(@"Beacon (%@, %@) is in the device list, but not assigned to any employee. Ignore it.", beacon.major, beacon.minor);
            continue;
        }
        
        //the beacon has been assigned to employee,
        //then send registration request to server
        DDLogInfo(@"Range new beacon (%@, %@, %@) with employee: %@. \nRegistering to server...", beacon.major, beacon.minor, shortId, employee.name);
        [self.beingRangedBeacons addObject:tempusBeacon];
        /*
        RemoteRegEntry *regEntry = [[RemoteRegEntry alloc] init];
        regEntry.regType = IN;
        regEntry.employeeId = employee.identifier;
         */
        
        NSDate *regDate = [[NSDate alloc] init];
        TempusInOutRegRecord *regEntry = [[TempusInOutRegRecord alloc] init];
        regEntry.type = kREG_TYPE_IN;
        regEntry.userId = employee.identifier;
        regEntry.beaconShortId = shortId;
        regEntry.date = regDate;
        
        /*
         * If the last registration is triggered by the same beacon as the same reg type
         * just add the counter to the dictionary
         */
        if (![regEntry isEqual:self.lastInOutRegRecord]) {
            /*
             * if suc, add the beacon to the being tracked collection
             * else, do nothing, waiting for the beacon to be ranged again
             */
            TempusResult *result = [TempusRemoteService regInOut:regEntry withSuccess:^(AFHTTPRequestOperation *operation, id responseObj) {
                DDLogError(@"Employee (%@, %@) with shortId %@ registered in.", employee.name, employee.identifier, shortId);
                
                [self.beingRangedBeaconsCounter setObject:@0 forKey:tempusBeacon];
                
                TempusRegMsg *msg = [[TempusRegMsg alloc] init];
                msg.time = regDate;
                msg.msg = [NSString stringWithFormat:@"%@ %@", employee.name, NSLocalizedString(@"REG_IN", @"Register in")];
                [self newMsg:msg];
                
                [self newInOutRegRecord:regEntry];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                DDLogError(@"%@ registered in failed. check your network connection!", shortId);
                DDLogError(@"%@", error.localizedDescription);
                [self.beingRangedBeacons removeObject:tempusBeacon];
            }];
            
            
            if (result && ![result isOK]) {
                DDLogError(@"Register employee (%@, %@) with shortId %@ failed.", employee.name, employee.identifier, shortId);
                NSString *errMsg = [result getErrMsg];
                if (errMsg)
                    DDLogError(@"%@", errMsg);
                if ([result getErr])
                    DDLogError(@"%@", [result getErr].localizedDescription);
            }
        } else {
            [self.beingRangedBeaconsCounter setObject:@0 forKey:tempusBeacon];
        }
        
    }
    
    
    //update counter
    NSMutableArray *toBeRemovedBeacons = [[NSMutableArray alloc] init];
    //for (NSNumber *major in [self.registeredBeaconsCounter allKeys]) {
    [self.beingRangedBeaconsCounter enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        NSUInteger counter = [((NSNumber *) obj) unsignedIntegerValue];
        if (++counter > kBEACON_OUT_OF_RANGE_LIMIT) {
            TempusEmployee *employee = [[LocalDataAccessor sharedInstance] localAccount];
            
            if (employee) {
                TempusInOutRegRecord *regRecord = [[TempusInOutRegRecord alloc] init];
                NSDate *regDate = [[NSDate alloc] init];
                regRecord.date = regDate;
                regRecord.type = kREG_TYPE_OUT;
                regRecord.beaconShortId = employee.shortId;
                regRecord.userId = employee.identifier;
                
                /*
                 * if the beacon has triggered the last reg as the same type, 
                 * then we won't trigger it again
                 */
                if (![regRecord isEqual:self.lastInOutRegRecord]) {
                    
                    [self.cachedRegEntries addObject:regRecord];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        [TempusRemoteService regInOut:regRecord withSuccess:^(AFHTTPRequestOperation *operation, id responseObj) {
                            DDLogInfo(@"Employee (%@, %@) registered out.", employee.name, employee.shortId);
                            
                            [self.cachedRegEntries removeObject:regRecord];
                            
                            TempusRegMsg *msg = [[TempusRegMsg alloc] init];
                            msg.time = regDate;
                            msg.msg = [NSString stringWithFormat:@"%@ %@", employee.name, NSLocalizedString(@"REG_OUT", @"Register out")];
                            [self newMsg:msg];
                            
                            [self newInOutRegRecord:regRecord];
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            DDLogError(@"Employee (%@, %@) with shortId %@  could NOT registered out.", employee.name, employee.shortId, ((TempusBeacon *)key).shortId);
                        }];
                    });
                }
            }
            
            [toBeRemovedBeacons addObject:key];
        } else {
            [self.beingRangedBeaconsCounter setObject:[NSNumber numberWithUnsignedInteger:counter] forKey:key];
        }
    }];
    
    //remove beacons from tracked array and counter dict
    if (toBeRemovedBeacons.count) {
        [self.beingRangedBeacons removeObjectsInArray:toBeRemovedBeacons];
        [self.beingRangedBeaconsCounter removeObjectsForKeys:toBeRemovedBeacons];
    }
}



#pragma mark - UITableView Data Source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.msgBuf count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"MsgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    UILabel *label = (UILabel *) [cell.contentView viewWithTag:10];
    [label setTextColor:[UIColor whiteColor]];
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    if (0 == indexPath.row)
        font = [UIFont boldSystemFontOfSize:16.0f];
    [label setFont:font];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    /*
    NSString *dateTemplate = @"yyyyMMdd";
    NSString *formatStr = [NSDateFormatter dateFormatFromTemplate:dateTemplate options:0 locale:currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatStr];
     */
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setLocale:currentLocale];
    
    TempusRegMsg *tempusRegMsg = [self.msgBuf objectAtIndex:indexPath.row];
    NSString *msgStr = [formatter stringFromDate:tempusRegMsg.time];
    [label setText:[msgStr stringByAppendingString:tempusRegMsg.msg]];
    
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    if (1 == indexPath.row)
        font = [UIFont boldSystemFontOfSize:15.0f];
    CGFloat height = [tmpStaticStr  heightForWidth:tableView.frame.size.width usingFont:font];
    return height;
}



#pragma mark - TempusRemoteServiceResponseDelegate methods
- (void) didReceiveResponseObject:(id)repObj {
}



#pragma mark - User Interaction Handler
- (IBAction)beaconBtnPressed:(id)sender {
}



#pragma mark - Private Methods
- (void) initiation {
    self.beingRangedBeacons = [[NSMutableArray alloc] init];
    self.beingRangedBeaconsCounter = [[NSMutableDictionary alloc] init];
    self.cachedRegEntries = [[NSMutableArray alloc] init];
    
    /*todo, init self.lastInOutRegRecord*/
    
    
    //instantiate peripheral device manager
    self.peripheralDeviceManager = [PeripheralDeviceManager sharedManager];

    
    //init location manager
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    
    if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [self.locManager requestAlwaysAuthorization];
    
    
    //init beacon region
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kUUID_STR];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:kREGION_ID];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    self.beaconRegion.notifyOnEntry = YES;
    self.beaconRegion.notifyOnExit = YES;
    
    [self.locManager startMonitoringForRegion:self.beaconRegion];
}


- (void) newMsg: (TempusRegMsg *) msg {
    //add to msg buf;
    if ([[DBManager sharedInstance] storeRegMsg:msg]) {
        self.msgBuf = [[DBManager sharedInstance] regMsgsWithLimit:kREG_MSG_DISP_LMT];
        [self.msgTableView reloadData];
    }
}


- (BOOL) newInOutRegRecord: (TempusInOutRegRecord *)record {
    if ([[DBManager sharedInstance] storeInOutRegRecord:record]) {
        self.lastInOutRegRecord = record;
        return YES;
    }
    
    return NO;
}

@end
