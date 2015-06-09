//
//  TempusRemoteServiceResponseDelegate.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TempusRemoteServiceResponseDelegate <NSObject>

@optional
- (void) didReceiveResponseObject: (id) repObj;

@end
