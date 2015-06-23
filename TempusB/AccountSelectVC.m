//
//  AccountSelectVC.m
//  TempusB
//
//  Created by Wenlu Zhang on 12/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "AccountSelectVC.h"
#import "TempusEmployee.h"
#import "TempusRemoteService.h"
#import "TempusRLDataParser.h"
#import "LocalDataAccessor.h"
#import "CocoaLumberjack/CocoaLumberjack.h"

@interface AccountSelectVC ()
//@property (nonatomic, weak) UITableView *weakView;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, assign) CGRect preferedFrame;
//@property (nonatomic, strong) TempusEmployee *curEmployee;
@end

@implementation AccountSelectVC

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.preferedFrame = frame;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = [[UITableView alloc] initWithFrame:self.preferedFrame style:UITableViewStylePlain];
    
    self.clearsSelectionOnViewWillAppear = YES;
    
    [TempusRemoteService  employeeListWithSuccess:^(AFHTTPRequestOperation *op, id repObj) {
        self.accounts = [TempusRLDataParser R2LParseEmployeeList:repObj];
        //self.curEmployee = employeeDict ? [[TempusEmployee alloc] initFromCocoaObj: employeeDict] : nil;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *op, NSError *err) {
        DDLogError(@"%@", err.localizedDescription);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NETWORK_FAILURE", @"network error")
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return !(self.accounts || self.accounts.count) ? 0 : self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *accountCell = @"plainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCell];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountCell];
    
    TempusEmployee *account = [self.accounts objectAtIndexedSubscript:indexPath.row];
    [cell.textLabel setText:account.name];
    
    TempusEmployee *curEmployee = [[LocalDataAccessor sharedInstance] localAccount];
    if (curEmployee && [curEmployee.identifier isEqualToString:account.identifier])
        [cell.textLabel setTextColor:[UIColor blueColor]];
    else
        [cell.textLabel setTextColor:[UIColor darkTextColor]];
    
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


#pragma mark - UITableViewDelegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    TempusEmployee *selectedEmployee = self.accounts[row];
    
    BOOL suc = [[LocalDataAccessor sharedInstance] storeLocalAccount:selectedEmployee];
    
    if (!suc) {
        DDLogError(@"Cannot store selected user");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
