//
//  SecondViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 19/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#define kOPTS                   @[@"CHOOSE_ACCOUNT", @"SCAN_QR_CODE", @"SETTINGS"]
#define kOPT_ICONS              @[@"choose_account_btn_icon.png", @"scan_btn_icon.png", @"setting_btn_icon.png"]

#import "CocoaLumberjack/CocoaLumberjack.h"
#import "SettingsViewController.h"
#import "DropdownListViewController.h"
#import "AccountSelectVC.h"
#import "QRScannerViewController.h"
#import "TempusEmployee.h"
#import "LocalDataAccessor.h"

@interface SettingsViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DropdownListViewController *dropdownListVC;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesRecognizer;
@property (nonatomic, strong) TempusEmployee *curEmployee;

@end

@implementation SettingsViewController


#pragma mark - Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    [self setupSubviews];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.curEmployee = [[LocalDataAccessor sharedInstance] localAccount];
    if (self.curEmployee) {
        [self.accDispNameLabel setText:self.curEmployee.name];
        if (self.curEmployee.shortId && self.curEmployee.shortId.length)
            [self.shortIdLabel setText:self.curEmployee.shortId];
        else
            [self.shortIdLabel setText:NSLocalizedString(@"SCAN_QR_CODE", @"Scan a QR code")];
    } else {
        [self.accDispNameLabel setText:NSLocalizedString(@"CHOOSE_ACCOUNT", @"Choose an account from the list")];
        [self.shortIdLabel setText:NSLocalizedString(@"SCAN_QR_CODE", @"Scan a QR code")];
    }
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIGestureRecognizerDelegate Methods
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.view];
    return !CGRectContainsPoint(self.dropdownListVC.view.frame, touchPoint);
}



#pragma mark - event response
- (IBAction) didTappedActionMoreBtn:(id)sender {
    if ([self.dropdownListVC.view isHidden]) {
        [self.dropdownListVC.view setHidden:NO];
        self.tapGesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideListView)];
        self.tapGesRecognizer.delegate = self;
        [self.view addGestureRecognizer:self.tapGesRecognizer];
    }
}



#pragma mark - private methods
- (void) hideListView {
    [self.dropdownListVC.view setHidden:YES];
    [self.view removeGestureRecognizer:self.tapGesRecognizer];
    self.tapGesRecognizer = nil;
}


- (void) presentAccountSelectView {
    AccountSelectVC *accSelectVC = [[AccountSelectVC alloc] initWithFrame:self.view.bounds];
    [self.navigationController pushViewController:accSelectVC animated:YES];
    //[self presentViewController:accSelectVC animated:YES completion:nil];
}


- (void) presentScannerView {
    if (!self.curEmployee) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"CHOOSE_ACC_FIRST", @"select an account first")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    QRScannerViewController *QRScannerVC = [[QRScannerViewController alloc] initWithCompletion:^(NSString *shortId) {
        DDLogDebug(@"%@", shortId);
        self.curEmployee.shortId = shortId;
        [[LocalDataAccessor sharedInstance] storeLocalAccount:self.curEmployee];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
    [self.navigationController pushViewController:QRScannerVC animated:YES];
}


- (void) setupSubviews {

    /*[[self.navigationController navigationBar] setBackgroundImage:[[UIImage imageNamed:@"background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
     */
    
    //init dropdownListVC
    self.dropdownListVC = [[DropdownListViewController alloc] init];
    [self.dropdownListVC registerListTitles:kOPTS];
    [self.dropdownListVC registerListIcons:kOPT_ICONS];
    [self.dropdownListVC registerRowSelectAction:@selector(hideListView) ofTarget:self];
    [self.dropdownListVC registerRowSelectAction:@selector(presentAccountSelectView) ofTarget:self atRow:0];
    [self.dropdownListVC registerRowSelectAction:@selector(presentScannerView) ofTarget:self atRow:1];
    
    [self.view addSubview:self.dropdownListVC.view];
    /*
     prevent auto-generated constraints, so avoid any conflict between user specified constraints and
     autoresizing constraints
     */
    [self.dropdownListVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSMutableArray *subviewConstraints = [[NSMutableArray alloc] init];
    [subviewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dropdownListVC.view
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0f
                                                         constant:152]];
    [subviewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dropdownListVC.view
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:200.0f]];
    
    NSMutableArray *superviewConstraints = [[NSMutableArray alloc] init];
    
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.actionMoreBtn
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.dropdownListVC.view
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
     
    [superviewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.view
                                                                         attribute:NSLayoutAttributeRightMargin
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.dropdownListVC.view
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
    
    [self.dropdownListVC.view addConstraints:subviewConstraints];
    [self.view addConstraints:superviewConstraints];
    [self.dropdownListVC.view setHidden:YES];
    
}

@end
