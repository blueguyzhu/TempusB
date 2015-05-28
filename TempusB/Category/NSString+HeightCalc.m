//
//  NSString+NSString_HeightCalc.m
//  TempusB
//
//  Created by Wenlu Zhang on 28/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "NSString+HeightCalc.h"

@implementation NSString (HeightCalc)

- (CGFloat) heightForWidth: (CGFloat)width usingFont: (UIFont *)font {
    NSStringDrawingContext *ctx = [[NSStringDrawingContext alloc] init];
    CGSize labelSize = (CGSize) {width, FLT_MAX};
    CGRect rect = [self boundingRectWithSize:labelSize
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:ctx];
    
    return rect.size.height;
}
@end
