//
//  TempusBeacon.m
//  TempusB
//
//  Created by Wenlu Zhang on 09/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusBeacon.h" 

@implementation TempusBeacon


#pragma mark - methods Overwrite SuperClass NSObject

- (BOOL) isEqual:(id)object {
    if (object == self)
        return YES;
    
    if (object && [object isKindOfClass: [TempusBeacon class]]) {
        TempusBeacon *other = (TempusBeacon *)object;
        return other.major == self.major && other.minor == self.minor; //&& [self.shortId isEqualToString:other.shortId];
    }
    
    return NO;
}


- (NSUInteger) hash {
    return self.major + self.minor;
}


#pragma mark - methods of NSCopying protocol
- (id) copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setMajor:self.major];
        [copy setMinor:self.minor];
        [copy setShortId:[self.shortId copyWithZone:zone]];
    }
    
    return copy;
}

@end
