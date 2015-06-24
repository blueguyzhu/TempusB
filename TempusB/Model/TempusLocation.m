//
//  TempusLocation.m
//  TempusB
//
//  Created by Wenlu Zhang on 23/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusLocation.h"

@implementation TempusLocation

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.coordinate = CLLocationCoordinate2DMake(NAN, NAN);
    }
    
    return self;
}


- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    
    TempusLocation *other = (TempusLocation *) object;
    
    return self.identifier == other.identifier;
}

@end
