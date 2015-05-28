//
//  FirstViewController.h
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoPresentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *msgTableView;
@property (nonatomic, weak) IBOutlet UIButton *beaconBtn;

- (IBAction)beaconBtnPressed:(id)sender;

@end

