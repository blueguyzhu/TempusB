//
//  UIViewController+VSpinner.m
//  TempusB
//
//  Created by Wenlu Zhang on 24/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "UIViewController+VSpinner.h"
#import <objc/runtime.h>

@interface UIViewController ()
@property (nonatomic, strong) NSMutableDictionary *spinners;
@end

@implementation UIViewController(VSpinner)

#pragma mark - setters&getters
- (void) setSpinners:(NSMutableDictionary *)spinners {
    objc_setAssociatedObject(self, @selector(spinners), spinners, OBJC_ASSOCIATION_RETAIN);
}


- (NSMutableDictionary *) spinners {
    return objc_getAssociatedObject(self, @selector(spinners));
}


#pragma mark - public category methods
- (void) showSpinnerWithName: (NSString *)key inView: (UIView *)supView {
    if (!self.spinners) {
        self.spinners = [[NSMutableDictionary alloc] init];
    }
    
    UIActivityIndicatorView *actIndView = [self.spinners objectForKey:key];
    if (actIndView) {
        [actIndView stopAnimating];
        [actIndView removeFromSuperview];
    }else {
        actIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        actIndView.hidesWhenStopped = YES;
        actIndView.backgroundColor = [UIColor whiteColor];
        actIndView.alpha = 0.8;
    }
    
    CGSize size = supView.bounds.size;
    
    [actIndView setFrame:CGRectMake(0, 0, size.width, size.height)];
    actIndView.center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    
    [supView addSubview:actIndView];
    [actIndView startAnimating];
    [self.spinners setObject:actIndView forKey:key];
}


- (void) removeSpinnerWithName: (NSString *)key{
    if (!self.spinners)
        return;
    
    UIActivityIndicatorView *actIndView = [self.spinners objectForKey:key];
    if (actIndView) {
        [actIndView stopAnimating];
        [actIndView removeFromSuperview];
        [self.spinners removeObjectForKey:key];
    }
}
@end