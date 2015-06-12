//
//  OptionSelectResponse.h
//  TempusB
//
//  Created by Wenlu Zhang on 12/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OptionSelectResponse : NSObject

@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) id target;

@end
