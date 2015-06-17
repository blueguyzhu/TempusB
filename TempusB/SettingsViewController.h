//
//  SecondViewController.h
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *actionMoreBtn;
@property (nonatomic, weak) IBOutlet UILabel *accDispNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *shortIdLabel;

- (IBAction)didTappedActionMoreBtn:(id)sender;

@end

