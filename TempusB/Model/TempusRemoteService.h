//
//  TempusRemoteService.h
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TempusRemoteServiceResponseDelegate.h"

@class TempusInOutRegRecord;
@class TempusResult;
@class AFHTTPRequestOperation;


@interface TempusRemoteService : NSObject

//+ (TempusResult *) regInOut: (RemoteRegEntry *)entryInfo withResponseObjReceiver: (id<TempusRemoteServiceResponseDelegate>) receiver;

+ (TempusResult *) regInOut:(TempusInOutRegRecord *)entryInfo
                withSuccess: (void (^)(AFHTTPRequestOperation *operation, id responseObj))suc
                    failure: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (TempusResult *) employeeListWithSuccess: (void (^)(AFHTTPRequestOperation *op, id repObj))suc
                                   failure: (void (^)(AFHTTPRequestOperation *op, NSError *err)) failure;

+ (TempusResult *) preconfLocationsWithSuccess: (void (^)(AFHTTPRequestOperation *op, id repObj))suc
                                       failure: (void (^)(AFHTTPRequestOperation *op, NSError *err)) failure;

@end
