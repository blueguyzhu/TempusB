//
//  DropdownListViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 11/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kCELL_NAME              @"dropdownListCell"

#import "DropdownListViewController.h"
#import "DropdownListCell.h"
#import "OptionSelectResponse.h"


@interface DropdownListViewController ()

@property (nonatomic, assign) SEL generalRowSelectAction;
@property (nonatomic, strong) id generalRowSelectActionTarget;
@property (nonatomic, strong) NSMutableDictionary *rowSelectActions;

@end

@implementation DropdownListViewController

static NSArray *msOptions = nil;
static NSArray *msOptionIcons = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"DropdownListCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kCELL_NAME];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - public methods
- (void) registerRowSelectAction:(SEL)action ofTarget:(id)target {
    self.generalRowSelectAction = action;
    self.generalRowSelectActionTarget = target;
}


- (void) registerRowSelectAction:(SEL)action ofTarget:(id)target atRow:(NSUInteger)row {
    if (!self.rowSelectActions)
        self.rowSelectActions = [[NSMutableDictionary alloc] init];
    
    NSNumber *numFormatRow = [[NSNumber alloc] initWithUnsignedInteger:row];
    OptionSelectResponse *opSelResp = [[OptionSelectResponse alloc] init];
    opSelResp.action = action;
    opSelResp.target = target;
    [self.rowSelectActions setObject:opSelResp forKey:numFormatRow];
}


- (void) registerListIcons:(NSArray *)iconNames {
    msOptionIcons = iconNames;
}


- (void) registerListTitles:(NSArray *)titles {
    msOptions = titles;
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


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if (self.generalRowSelectActionTarget) {
        IMP imp = [self.generalRowSelectActionTarget methodForSelector:self.generalRowSelectAction];
        void (* func) (id, SEL) = (void *)imp;
        func (self.generalRowSelectActionTarget, self.generalRowSelectAction);
    }

    if (self.rowSelectActions) {
        OptionSelectResponse *opSelResp = [self.rowSelectActions objectForKey:[NSNumber numberWithInteger:indexPath.row]];
        if (opSelResp) {
            ((void (*) (id, SEL))[opSelResp.target methodForSelector:opSelResp.action])(opSelResp.target, opSelResp.action);
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    //[self.navigationController pushViewController:detailViewController animated:YES];
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
