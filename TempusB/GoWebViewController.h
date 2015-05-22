//
//  GoWebViewController.h
//  TempusB
//
//  Created by Wenlu Zhang on 22/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface GoWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end