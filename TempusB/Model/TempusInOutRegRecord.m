//
//  TempusInOutRegRecord.m
//  TempusB
//
//  Created by Wenlu Zhang on 18/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusInOutRegRecord.h"

@implementation TempusInOutRegRecord

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.beaconShortId = nil;
        self.userId = nil;
    }
    
    return self;
}


- (BOOL) isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    
    TempusInOutRegRecord *other = (TempusInOutRegRecord *)object;
    
    return self.type == other.type &&
        [self.beaconShortId isEqualToString:other.beaconShortId] &&
        [self.userId isEqualToString:other.userId];
}

@end
