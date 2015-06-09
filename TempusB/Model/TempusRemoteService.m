//
//  TempusRemoteService.m
//  TempusB
//
//  Created by Wenlu Zhang on 02/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kREMOTE_BASE_URL                    @"https://swa201403.servicebus.windows.net/zeroapi/"
#define kTIMEOUT_INTERVAL                   60.0

#import "TempusRemoteService.h"
#import "RemoteRegEntry.h"
#import "AFNetworking.h"
#import "TempusResult.h"


@interface TempusRemoteService () 

@end


@implementation TempusRemoteService

+ (TempusResult *) regInOut:(RemoteRegEntry *)entryInfo
                withSuccess: (void (^)(AFHTTPRequestOperation *operation, id responseObj))suc
                    failure: (void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    jsonDict[@"AnsattNr"] = entryInfo.employeeId;
    jsonDict[@"InOrOut"] = entryInfo.regType == IN ? @"in" : @"out";
    jsonDict[@"Site"] = @"";
    
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&err];
    
    if (err) {
        return [[TempusResult alloc] initWithErr:err];
    }
    
    NSURL *url = [NSURL URLWithString:[kREMOTE_BASE_URL stringByAppendingString:@"entry"]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    [req setTimeoutInterval:kTIMEOUT_INTERVAL];
    [req setValue:@"application/json" forKey:@"Content-TypContent-Typee"];
    [req setHTTPBody:jsonData];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:suc failure:failure];
    
    [[NSOperationQueue mainQueue] addOperation:op];
    
    return [[TempusResult alloc] init];
}

@end
