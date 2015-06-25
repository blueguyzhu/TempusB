//
//  LightLocalStorageManager.m
//  TempusB
//
//  Created by Wenlu Zhang on 16/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#define kUSER_ACCOUNT           @"user"
#define kMONITORED_LOCATIONS    @"locations"

#import "LightLocalStorageManager.h"
#import "CocoaLumberjack/CocoaLumberjack.h"

@implementation LightLocalStorageManager


+ (NSDictionary *) readUserAccount {
    NSString *localPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                           stringByAppendingPathComponent:kUSER_ACCOUNT] stringByAppendingPathExtension:@"plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localPath])
        return nil;
    
    NSData *plistData = [NSData dataWithContentsOfFile:localPath];
    NSPropertyListFormat format;
    NSError *err = nil;
    NSDictionary *dict =
        (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistData
                                                                  options:NSPropertyListImmutable
                                                                   format:&format
                                                                    error:&err];
    
    return dict;
}


+ (BOOL) writeUserAccount: (NSDictionary *)account {
    NSString *errStr = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:account
                                               format:NSPropertyListBinaryFormat_v1_0
                                     errorDescription:&errStr];
    
    if (errStr) {
        DDLogError(@"%@", errStr);
        return NO;
    }
    
    //ugly string building method
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [[path stringByAppendingPathComponent:kUSER_ACCOUNT] stringByAppendingPathExtension:@"plist"];
    
    NSError *err = nil;
    BOOL suc = [plistData writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (err) {
        DDLogError(@"%@", [err localizedDescription]);
    }
    
    return suc;
}


+ (NSArray *) readMonitoredLocations {
    NSString *path = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                       stringByAppendingPathComponent:kMONITORED_LOCATIONS] stringByAppendingPathExtension:@"plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return nil;
    
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSPropertyListFormat format;
    NSError *err = nil;
    NSArray *arr = (NSArray *) [NSPropertyListSerialization propertyListWithData:plistData
                                                             options:NSPropertyListImmutable
                                                              format:&format
                                                               error:&err];
    
    return arr;
}


+ (BOOL) writeMonitoredLocations:(NSArray *)locations {
    NSString *errStr = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:locations
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                         errorDescription:&errStr];
    
    if (errStr) {
        DDLogError(@"%@", errStr);
        return NO;
    }
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [[path stringByAppendingPathComponent:kMONITORED_LOCATIONS] stringByAppendingPathExtension:@"plist"];
    
    NSError *err = nil;
    BOOL suc = [plistData writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (err)
        DDLogError(@"%@", [err description]);
    
    return suc;
}

@end
