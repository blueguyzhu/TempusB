//
//  BeaconListViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 23/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "BeaconListViewController.h"
#import "QRScannerViewController.h"
#import "CocoaLumberjack/CocoaLumberjack.h"
#import "LocalDataAccessor.h"
#import "Header.h"
#import "TempusBeacon.h"
#import "PeripheralDeviceManager.h"

@interface BeaconListViewController ()
@property (nonatomic, strong) NSArray *monitoredBeacons;
@property (nonatomic, strong) NSMutableArray *selectedBeacons;
@end

@implementation BeaconListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMoreBtnClicked)];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.monitoredBeacons = [[LocalDataAccessor sharedInstance] monitoredBeacons];
    self.selectedBeacons = [[NSMutableArray alloc] initWithArray:self.monitoredBeacons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL update = NO;
    if (self.monitoredBeacons.count != self.selectedBeacons.count)
        update = YES;
    
    if (!update) {
        NSMutableArray *tmpBeaconArr = [[NSMutableArray alloc] initWithArray:self.monitoredBeacons];
        [tmpBeaconArr removeObjectsInArray:self.selectedBeacons];
        update = tmpBeaconArr.count;
    }
    
    if (!update)
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTI_BEACON_UPDATE object:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectedBeacons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *plainCellId = @"PlainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:plainCellId];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:plainCellId];
   
    [cell.textLabel setText:((TempusBeacon *)self.selectedBeacons[indexPath.row]).shortId];
    
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

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        [self.selectedBeacons removeObjectAtIndex:indexPath.row];
        
        [[LocalDataAccessor sharedInstance] storeMonitoredBeacons:self.selectedBeacons];
        
        [self.tableView reloadData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - event response
- (void) addMoreBtnClicked {
    QRScannerViewController *QRScannerVC = [[QRScannerViewController alloc] initWithCompletion:^(NSString *shortId) {
        DDLogDebug(@"%@", shortId);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            TempusBeacon *tempusBeacon = [[PeripheralDeviceManager sharedManager] beaconWithShortId:shortId];
            if (!tempusBeacon) {
                [self.navigationController popViewControllerAnimated:YES];
                
                if (![UIAlertController class]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"NO_BEACON_FOUND", @"Cannot find the beacon in the configured list.")
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                            style:UIAlertActionStyleDefault
                                                                          handler:nil];
                    
                    [alert addAction:defaultAction];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:NSLocalizedString(@"NO_BEACON_FOUND", @"Cannot find the beacon in the configured list.")
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                
            }
            else {
                [self.selectedBeacons addObject:tempusBeacon];
                [[LocalDataAccessor sharedInstance] storeMonitoredBeacons:self.selectedBeacons];
                
                [self.navigationController popViewControllerAnimated:YES];
                [self.tableView reloadData];
            }
        });
        
    }];
    
    [self.navigationController pushViewController:QRScannerVC animated:YES];
}

@end
