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
#import <CocoaLumberjack.h>
#import <CoreLocation/CoreLocation.h>

@interface InfoPresentViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *msgBuf;
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
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
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    DDLogDebug(@"Start to monitor region: %@", region.identifier);
    [manager startRangingBeaconsInRegion:beaconRegion];
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    DDLogError(@"Monitor region %@ failed. \n%@. %@", region.identifier, error.localizedDescription, error.localizedFailureReason);
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



#pragma mark - User Interaction Handler
- (IBAction)beaconBtnPressed:(id)sender {
}



#pragma mark - Private Methods
- (void) initiation {
    self.msgBuf = [[NSArray alloc] init];
    
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
