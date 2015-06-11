//
//  TempusResult.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

@import Foundation;

@interface TempusResult : NSMutableDictionary

- (instancetype) init;
- (instancetype) initWithErr: (NSError *) err;
- (instancetype) initWithErrMsg: (NSString *) errMsg;

- (BOOL) isOK;
- (void) setErr: (NSError *)err;
- (void) setErrMsg: (NSString *)errMsg;
- (NSError *) getErr;
- (NSString *) getErrMsg;
//- (NSString *) errDescription;

@end