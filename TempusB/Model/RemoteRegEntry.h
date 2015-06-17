//
//  RemoteRegEntry.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface RemoteRegEntry : NSObject

typedef enum {
    IN = 0,
    OUT = 1
} RemoteRegType;

@property (nonatomic, strong) NSString *employeeId;
@property (nonatomic, assign) RemoteRegType regType;

@end
