//
//  LocalDataAccessor.h
//  TempusB
//
//  Created by Wenlu Zhang on 17/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TempusEmployee;

@interface LocalDataAccessor : NSObject

+ (instancetype) sharedInstance;

- (TempusEmployee *) localAccount;

- (BOOL) storeLocalAccount: (TempusEmployee *)account;

@end
