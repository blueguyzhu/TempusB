//
//  DBManager.m
//  TempusB
//
//  Created by Wenlu Zhang on 26/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <sqlite3.h>
#import "DBManager.h"

@interface DBManager ()

@property (nonatomic, strong) NSString *dbFileName;
@property (nonatomic, strong) NSString *docDir;
@property (nonatomic, strong) NSError *err;

@end


@implementation DBManager

- (instancetype) initWithDBFileName: (NSString *) dbFileName {
    self = [super init];
    
    if (self) {
        NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        self.docDir = pathArr[0];
        self.dbFileName = dbFileName;
        
        if (![self copyDBIntoDocDir])
            self = nil;
    }
    
    return self;
}



#pragma mark - private methods
- (BOOL) copyDBIntoDocDir {
    NSString *dbPath = [self.docDir stringByAppendingString:self.dbFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
        return YES;
    
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:self.dbFileName];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dbPath error:&error];
    
    if (error != nil) {
    }
    
    return YES;
}

@end