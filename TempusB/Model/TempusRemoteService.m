//
//  TempusRemoteService.m
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kREMOTE_BASE_URL                    @"https://swa201403.servicebus.windows.net/zeroapi"
#define kTIMEOUT_INTERVAL                   60.0

#import "TempusRemoteService.h"
#import "TempusInOutRegRecord.h"
#import "AFNetworking.h"
#import "TempusResult.h"
#import "CocoaLumberjack/CocoaLumberjack.h"


@interface TempusRemoteService () 
@end


@implementation TempusRemoteService

static NSOperationQueue *msTempusRemoteServiceQue = nil;

+ (NSOperationQueue *) tempusRemoteServiceQue {
        static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        msTempusRemoteServiceQue = [[NSOperationQueue alloc] init];
        msTempusRemoteServiceQue.name = @"no.tempus.tempusB.queue.remoteService";
    });
    
    return msTempusRemoteServiceQue;
}

+ (TempusResult *) regInOut:(TempusInOutRegRecord *)entryInfo
                withSuccess: (void (^)(AFHTTPRequestOperation *operation, id responseObj))suc
                    failure: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    jsonDict[@"AnsattNr"] = entryInfo.userId;
    jsonDict[@"InOrOut"] = entryInfo.type == kREG_TYPE_IN ? @"in" : @"out";
    jsonDict[@"Site"] = @"";
    
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&err];
    
    if (err) {
        return [[TempusResult alloc] initWithErr:err];
    }
    
    NSURL *url = [NSURL URLWithString:[kREMOTE_BASE_URL stringByAppendingPathComponent:@"entry"]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    [req setTimeoutInterval:kTIMEOUT_INTERVAL];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:jsonData];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    //op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:suc failure:failure];
    
    [[TempusRemoteService tempusRemoteServiceQue] addOperation:op];
    
    return nil;
}


+ (TempusResult *) employeeListWithSuccess: (void (^)(AFHTTPRequestOperation *op, id repObj))suc
                                   failure: (void (^)(AFHTTPRequestOperation *op, NSError *err)) failure {
    NSURL *url = [NSURL URLWithString:[kREMOTE_BASE_URL stringByAppendingPathComponent:@"ansatt"]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setTimeoutInterval:kTIMEOUT_INTERVAL];
    [req setHTTPMethod:@"GET"];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:suc failure:failure];
    
    [[TempusRemoteService tempusRemoteServiceQue] addOperation:op];
    
    return nil;
}

@end
