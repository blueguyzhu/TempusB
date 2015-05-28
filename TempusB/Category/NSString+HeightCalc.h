//
//  NSString+NSString_HeightCalc.h
//  TempusB
//
//  Created by Wenlu Zhang on 28/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (HeightCalc)
- (CGFloat)heightForWidth: (CGFloat)width usingFont: (UIFont *)font;
@end
