//
//  NSObject_TempusBeacon.h
//  TempusB
//
//  Created by Wenlu Zhang on 09/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempusBeacon : NSObject <NSCopying>

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *shortId;
@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;

@end
