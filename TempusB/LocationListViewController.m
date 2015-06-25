//
//  LocationListViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 23/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "Header.h"
#import "LocationListViewController.h"
#import "TempusRemoteService.h"
#import "TempusRLDataParser.h"
#import "TempusLocation.h"
#import "CocoaLumberjack/CocoaLumberjack.h"
#import "UIViewController+VSpinner.h"
#import <CoreLocation/CoreLocation.h>
#import "LocalDataAccessor.h"

@interface LocationListViewController ()
@property (nonatomic, strong) NSArray *locations;   //all available TempusLocations
@property (nonatomic, strong) NSMutableArray *monitoredLocations;  //TempusLocations loaded from local storage
@property (nonatomic, strong) NSMutableArray *selectedLocations;    //user dynamically selected TempusLocations
@end

@implementation LocationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.allowsMultipleSelection = YES;
    
    [TempusRemoteService preconfLocationsWithSuccess:^(AFHTTPRequestOperation *op, id repObj) {
        self.locations = [TempusRLDataParser R2LParseLocationList:repObj];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *op, NSError *err) {
        DDLogError(@"%@", err.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NETWORK_FAILURE", @"network failure")
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
    
    NSArray *monitoredLocations = [[LocalDataAccessor sharedInstance] monitoredLocations];
    if (monitoredLocations && monitoredLocations.count)
        self.monitoredLocations = [[NSMutableArray alloc] initWithArray: monitoredLocations];
    else
        self.monitoredLocations = [[NSMutableArray alloc] init];
    
    self.selectedLocations = [[NSMutableArray alloc] initWithArray:self.monitoredLocations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillDisappear:(BOOL)animated {
    BOOL update = NO;
    update = self.monitoredLocations.count != self.selectedLocations.count;
    if (!update) {
        [self.monitoredLocations removeObjectsInArray:self.selectedLocations];
        update = [self.monitoredLocations count];
    }
    
    if (update) {
        [[LocalDataAccessor sharedInstance] storeMonitoredLocations:self.selectedLocations];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTI_GEO_LOC_UPDATE object:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *locCellName = @"locationTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locCellName];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locCellName];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TempusLocation *tempusLocation = self.locations[indexPath.row];
    [cell.textLabel setText:tempusLocation.address];
    
    if ([self.selectedLocations containsObject:tempusLocation])
        [cell.textLabel setTextColor:[UIColor blueColor]];
    
    if ((tempusLocation.coordinate.latitude != tempusLocation.coordinate.latitude ||
         tempusLocation.coordinate.longitude != tempusLocation.coordinate.longitude)) {
        [self showSpinnerWithName:[NSString stringWithFormat:@"%@", tempusLocation.identifier] inView:cell];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:tempusLocation.address completionHandler:^(NSArray *placemarks, NSError *error) {
            [self removeSpinnerWithName:[NSString stringWithFormat:@"%@", tempusLocation.identifier]];
            if (error) {
                DDLogError(@"Geodecode address %@ failed.", tempusLocation.address);
                DDLogError(@"%@", error.description);
            }else {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                tempusLocation.coordinate = placemark.location.coordinate;
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%f, %f", tempusLocation.coordinate.latitude, tempusLocation.coordinate.longitude]];
            }
        }];
    }
    
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UITableViewDelegate methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TempusLocation *tempusLocation = [self.locations objectAtIndex:indexPath.row];
    if ([self.selectedLocations containsObject:tempusLocation]) {
        [self.selectedLocations removeObject:tempusLocation];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
    }else {
        [self.selectedLocations addObject:tempusLocation];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textLabel setTextColor:[UIColor blueColor]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
