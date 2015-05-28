//
//  FirstViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "InfoPresentViewController.h"
#import "NSString+HeightCalc.h"
#import <CocoaLumberjack.h>

@interface InfoPresentViewController ()
@property (nonatomic, strong) NSArray *msgBuf;
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
}


- (void) newMsg: (NSString *) msg {
    //add to msg buf;
    [self.msgTableView reloadData];
}

@end
