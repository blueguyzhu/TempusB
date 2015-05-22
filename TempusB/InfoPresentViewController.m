//
//  FirstViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "InfoPresentViewController.h"

@interface InfoPresentViewController ()

@end

@implementation InfoPresentViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - User Interaction Handler

- (IBAction)beaconBtnPressed:(id)sender {
    UIView *parentView = self.msgTableView.superview;
}

@end
