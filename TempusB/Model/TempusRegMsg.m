//
//  TempusRegMsg.m
//  TempusB
//
//  Created by Wenlu Zhang on 26/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusRegMsg.h"

@interface TempusRegMsg ()

@end

@implementation TempusRegMsg

- (instancetype) init {
    self = [super init];
    if (self) {
        self.time = [[NSDate date] timeIntervalSince1970];
        self.msg = nil;
    }
    
    return self;
}

@end
