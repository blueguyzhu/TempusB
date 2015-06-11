//
//  SecondViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "SettingsViewController.h"
#import "DropdownListViewController.h"

@interface SettingsViewController ()

@property (nonatomic, strong) DropdownListViewController *dropdownListVC;

@end

@implementation SettingsViewController


#pragma mark - Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    self.dropdownListVC = [[DropdownListViewController alloc] init];
    [self.view addSubview:self.dropdownListVC.view];
    [self.dropdownListVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.dropdownListVC.view
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:152]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.actionMoreBtn
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.dropdownListVC.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.dropdownListVC.view
                                                                         attribute:NSLayoutAttributeRightMargin
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
    
    [self.dropdownListVC.view addConstraints:constraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - event response
- (IBAction) didTappedActionMoreBtn:(id)sender {
    
}

@end
