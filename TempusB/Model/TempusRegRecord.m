//
//  TempusRegRecord.m
//  TempusB
//
//  Created by Wenlu Zhang on 18/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusRegRecord.h"

@implementation TempusRegRecord

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.type = 0;
        self.date = [[NSDate alloc] init];
    }
    
    return self;
}


- (BOOL) isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    TempusRegRecord *other = (TempusRegRecord *)object;
    
    return [self.userId isEqualToString:self.userId] && self.type == other.type && [self.date isEqualToDate:other.date];
}

@end
