//
//  FullSettingsViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#define kSETTING_CELL_NAME          @"GroupSelectionCell"

#import "FullSettingsViewController.h"
#import "GroupSelectionListCell.h"
#import "CocoaLumberjack/CocoaLumberjack.h"

@interface FullSettingsViewController ()

@end

@implementation FullSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UINib *cellNib = [UINib nibWithNibName:@"GroupSelectionListCell" bundle:nil];
    [self.tableView  registerNib:cellNib forCellReuseIdentifier:kSETTING_CELL_NAME];
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    self.tableView.bounces = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    for (int i = 0; i < [self.tableView numberOfSections]; ++i) {
        CGRect sectionFrame = [self.tableView rectForSection:i];
        sectionFrame = CGRectMake(sectionFrame.origin.x, sectionFrame.origin.y + 20.0f, sectionFrame.size.width, sectionFrame.size.height - 30);
        UIView *secBackView = [[UIView alloc] initWithFrame:sectionFrame];
        [secBackView setBackgroundColor:[UIColor colorWithRed:103/255.0f green:174/255.0f blue:209/255.0f alpha:1.0f]];
        [self.tableView addSubview:secBackView];
        [self.tableView sendSubviewToBack:secBackView];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 0;
    
    switch (section) {
        case 0:
            num = 1;
            break;
            
        case 1:
            num = 3;
            break;
            
        case 2:
            num = 1;
            break;
            
        default:
            break;
    }
    
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupSelectionListCell *cell = [tableView dequeueReusableCellWithIdentifier:kSETTING_CELL_NAME];
    
//    [cell setBackgroundColor:[UIColor clearColor]];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.title setText:@"Account"];
                    [cell.headIcon setImage:[UIImage imageNamed:@"users_icon.png"]];
                    cell.funSwitch.hidden = YES;
                    cell.trailIcon.hidden = NO;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.title setText:@"Manage Beacons"];
                    [cell.headIcon setImage:[UIImage imageNamed:@"beacon_icon.png"]];
                    cell.funSwitch.hidden = YES;
                    cell.trailIcon.hidden = NO;
                    break;
                    
                case 1:
                    [cell.title setText:@"Use Geo-location"];
                    [cell.headIcon setImage:[UIImage imageNamed:@"geo_icon.png"]];
                    cell.funSwitch.hidden = NO;
                    cell.trailIcon.hidden = YES;
                    break;
                    
                case 2:
                    [cell.title setText:@"Manage Locations"];
                    [cell.headIcon setImage:[UIImage imageNamed:@"location_icon.png"]];
                    cell.funSwitch.hidden = YES;
                    cell.trailIcon.hidden = NO;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.title setText:@"Time and Timezone"];
                    cell.funSwitch.hidden = YES;
                    cell.trailIcon.hidden = NO;
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
    
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}


- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0f;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 66.0f;
    return 44.0f;
}


- (void)tableView:(UITableView *) tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
}


- (void)tableView:(UITableView *) tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
}


/*
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    [footer setBackgroundColor:[UIColor clearColor]];
    
    return footer;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    [header setBackgroundColor:[UIColor clearColor]];
    
    return header;
}
 */


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


#pragma mark - UITableView Delegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
