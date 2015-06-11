//
//  TempusRegMsg.h
//  TempusB
//
//  Created by Wenlu Zhang on 26/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#ifndef TempusB_TempusRegMsg_h
#define TempusB_TempusRegMsg_h

#import <Foundation/Foundation.h>

@interface TempusRegMsg : NSObject

@property (nonatomic) NSDate *time;
@property (nonatomic) NSString *msg;

@end

#endif
