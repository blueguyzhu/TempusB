//
//  NSObject_TempusEmployee.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempusEmployee : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *shortId;

- (instancetype) initFromCocoaObj: (NSDictionary *)dict;
- (NSDictionary *) toCocoaObj;

@end
