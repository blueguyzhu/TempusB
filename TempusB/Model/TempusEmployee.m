//
//  TempusEmployee.m
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusEmployee.h"

@interface TempusEmployee ()

@end



@implementation TempusEmployee

- (instancetype) initFromCocoaObj:(NSDictionary *)dict {
    self = [super init];
    
    if (self) {
        if (dict[@"name"] && dict[@"id"] && dict[@"shortId"]) {
            self.name = dict[@"name"];
            self.shortId = dict[@"shortId"];
            self.identifier = dict[@"id"];
        }
        else
            self = nil;
    }
    
    return self;
}

- (NSDictionary *) toCocoaObj {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"name"] = self.name ? self.name : @"";
    dict[@"id"] = self.identifier ? self.identifier : @"";
    dict[@"shortId"] = self.shortId ? self.shortId : @"";
    
    return dict;
}

@end
