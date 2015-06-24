//
//  UIViewController+VSpinner.h
//  TempusB
//
//  Created by Wenlu Zhang on 24/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(VSpinner)

- (void) showSpinnerWithName: (NSString *)key inView: (UIView *)supView;
- (void) removeSpinnerWithName: (NSString *)key;

@end
