//
//  FirstViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kUUID_STR                   @"f7826da6-4fa2-4e98-8024-bc5b71e0893e"
#define kREGION_ID                  @"Tempus_Beacon"

#import "InfoPresentViewController.h"
#import "NSString+HeightCalc.h"
#import "PeripheralDeviceManager.h"
#import "TempusEmployee.h"
#import "TempusRemoteService.h"
#import "TempusRemoteServiceResponseDelegate.h"
#import "TempusResult.h"
#import "RemoteRegEntry.h"
#import <CocoaLumberjack.h>
#import <CoreLocation/CoreLocation.h>



@interface InfoPresentViewController () <CLLocationManagerDelegate, TempusRemoteServiceResponseDelegate>

@property (nonatomic, strong) NSArray *msgBuf;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSMutableArray *registeredBeaconsMajor;
@property (nonatomic, strong) NSMutableDictionary *registeredBeaconsCounter;
@property (nonatomic, strong) PeripheralDeviceManager *peripheralDeviceManager;

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



#pragma mark - Delegate of CLLocationManager
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
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
        //exists already
        if ([self.registeredBeaconsMajor containsObject:beacon.major]) {
            NSString *shortId = [self.peripheralDeviceManager shortIdByMajor:beacon.major andMinor:beacon.minor];
            
            //the shortId has been disconnected with previous employee
            if (shortId && shortId.length && ![self.peripheralDeviceManager employeeWithShortId:shortId]) {
                DDLogInfo(@"Beacon (%@, %@, %@) has been disconnected with the employee. \nRemoving it from registred beacon list...",
                          beacon.major, beacon.minor, shortId);
                [self.registeredBeaconsMajor removeObject:beacon.major];
                [self.registeredBeaconsCounter removeObjectForKey:beacon.major];
            }else { //update counter
                DDLogInfo(@"Range beacon (%@, %@, %@). Updating counter...", beacon.major, beacon.minor, shortId);
                self.registeredBeaconsCounter[beacon.major] = @0;
            }
            
            continue;
        }
        
        //new beacon detected
        NSString *shortId = [self.peripheralDeviceManager shortIdByMajor:beacon.major andMinor:beacon.minor];
        if (!shortId || shortId.length == 0) { //beacon is not in the to-be-monitored device list
            DDLogDebug(@"Beacon (%@, %@) is not in the device list. Ignore it.", beacon.major, beacon.minor);
            continue;
        }
        //the beacon is not assigned to anyone
        TempusEmployee *employee = [self.peripheralDeviceManager employeeWithShortId:shortId];
        if (!employee) {
            DDLogDebug(@"Beacon (%@, %@) is in the device list, but not assigned to any employee. Ignore it.", beacon.major, beacon.minor);
            continue;
        }
        //the beacon has been assigned to employee
        DDLogInfo(@"Range new beacon (%@, %@, %@) with employee: %@. \nRegistering to server...", beacon.major, beacon.minor, shortId, employee.name);
        RemoteRegEntry *regEntry = [[RemoteRegEntry alloc] init];
        regEntry.regType = IN;
        regEntry.employeeId = employee.identifier;
        TempusResult *result = [TempusRemoteService regInOut:regEntry withSuccess:^(AFHTTPRequestOperation *operation, id responseObj) {
            DDLogDebug(@"%@ has registered in.", shortId);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogDebug(@"%@ registered in failed. check your network connection!", shortId);
        }];
        if (![result isOK]) {
            DDLogError(@"Register employee (%@, %@) with shortId %@ failed.", employee.name, employee.identifier, shortId);
            NSString *errMsg = [result getErrMsg];
            if (errMsg)
                DDLogError(@"%@", errMsg);
            if ([result getErr])
                DDLogError(@"%@", [result getErr].localizedDescription);
        }
    }
}



#pragma mark - UITableView Data Source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [self.msgBuf count];
    return 2;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"MsgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    UILabel *label = (UILabel *) [cell.contentView viewWithTag:10];
    [label setTextColor:[UIColor whiteColor]];
    UIFont *font = [UIFont systemFontOfSize:14.0f];
    if (1 == indexPath.row)
        font = [UIFont boldSystemFontOfSize:15.0f];
    [label setFont:font];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    [label setText: tmpStaticStr];
    
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
    self.msgBuf = [[NSArray alloc] init];
    
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


- (void) newMsg: (NSString *) msg {
    //add to msg buf;
    [self.msgTableView reloadData];
}

@end
