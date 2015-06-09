//
//  TempusRemoteService.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TempusRemoteServiceResponseDelegate.h"

@class RemoteRegEntry;
@class TempusResult;
@class AFHTTPRequestOperation;


@interface TempusRemoteService : NSObject

//+ (TempusResult *) regInOut: (RemoteRegEntry *)entryInfo withResponseObjReceiver: (id<TempusRemoteServiceResponseDelegate>) receiver;

+ (TempusResult *) regInOut:(RemoteRegEntry *)entryInfo
                withSuccess: (void (^)(AFHTTPRequestOperation *operation, id responseObj))suc
                    failure: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
