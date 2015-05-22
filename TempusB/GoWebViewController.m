//
//  GoWebViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 22/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "GoWebViewController.h"

@interface GoWebViewController ()

@end

@implementation GoWebViewController

#pragma mark - View Life Cycle
- (void) viewDidLoad {
    [super viewDidLoad];
    NSURL *url = nil;
    if (true) {
        url = [NSURL URLWithString:@"http://www.tempus.no"];
    }
    
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlReq];
}


- (void) didReceiveMemoryWarning {
}

@end
