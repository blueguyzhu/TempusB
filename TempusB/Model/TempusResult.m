//
//  TempusResult.m
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusResult.h"

@implementation TempusResult

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self[@"err"] = nil;
        self[@"errMsg"] = nil;
    }
    
    return self;
}


- (instancetype) initWithErr: (NSError *) err {
    self = [super init];
    
    if (self) {
        self[@"err"] = err;
        self[@"errMsg"] = nil;
    }
    
    return self;
}


- (instancetype) initWithErrMsg: (NSString *) errMsg {
    self = [super init];
    
    if (self) {
        self[@"err"] = nil;
        self[@"errMsg"] = errMsg;
    }
    
    return self;
}


- (BOOL) isOK {
    return !self[@"err"] && !self[@"errMsg"];
}


- (void) setErr: (NSError *)err {
    self[@"err"] = err;
}


- (void) setErrMsg: (NSString *)errMsg {
    self[@"errMsg"] = errMsg;
}


- (NSError *) getErr {
    return self[@"err"];
}


- (NSString *) getErrMsg {
    return self[@"errMsg"];
}


@end
