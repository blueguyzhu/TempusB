//
//  NSObject+PeripheralDeviceManager.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TempusEmployee;

@interface PeripheralDeviceManager : NSObject 

+ (PeripheralDeviceManager *) sharedManager;

- (NSString *) shortIdByMajor: (NSNumber *)major andMinor: (NSNumber *)minor;
- (TempusEmployee *) employeeWithShortId: (NSString *)shortId;
@end
