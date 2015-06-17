//
//  LightLocalStorageManager.h
//  TempusB
//
//  Created by Wenlu Zhang on 16/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LightLocalStorageManager : NSObject

+ (NSDictionary *) readUserAccount;
+ (BOOL) writeUserAccount: (NSDictionary *)account;

@end
