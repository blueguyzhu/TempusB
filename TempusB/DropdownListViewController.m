//
//  DropdownListViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 11/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kCELL_NAME              @"dropdownListCell"
#define kOPTS                   @[@"CHOOSE_ACCOUNT", @"SCAN_QR_CODE", @"SETTINGS"]
#define kOPT_ICONS              @[@"choose_account_btn_icon.png", @"scan_btn_icon.png", @"setting_btn_icon.png"]

#import "DropdownListViewController.h"
#import "DropdownListCell.h"

@interface DropdownListViewController ()

@end

@implementation DropdownListViewController

static NSArray *msOptions = nil;
static NSArray *msOptionIcons = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    msOptions = kOPTS;
    msOptionIcons = kOPT_ICONS;
    
    UINib *cellNib = [UINib nibWithNibName:@"DropdownListCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCELL_NAME];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [msOptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DropdownListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCELL_NAME forIndexPath:indexPath];
    
    NSString *key = [msOptions objectAtIndex:indexPath.row];
    NSString *title = NSLocalizedString(key, [@"listOption_" stringByAppendingString:key]);
    
    [cell.listTitle setText:title];
    [cell.listIcon setImage:[UIImage imageNamed:[msOptionIcons objectAtIndex:indexPath.row]]];
    cell.backgroundColor = [UIColor clearColor];
    
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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

@end
