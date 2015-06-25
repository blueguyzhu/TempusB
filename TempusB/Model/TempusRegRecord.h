//
//  TempusRegRecord.h
//  TempusB
//
//  Created by Wenlu Zhang on 18/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempusRegRecord : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, strong) NSString *userId;

@end
