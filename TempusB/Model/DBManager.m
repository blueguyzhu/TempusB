//
//  DBManager.m
//  TempusB
//
//  Created by Wenlu Zhang on 26/05/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//
#define kDB_FILE_NAME               @"TempusB.db"
#define kDEVICE_TABLE_NAME          @"devices"

#import <sqlite3.h>
#import "DBManager.h"
#import <CocoaLumberjack.h>
#import "Header.h"
#import "TempusBeacon.h"
#import "TempusRegMsg.h"
#import "TempusRegRecord.h"
#import "TempusInOutRegRecord.h"
#import "TempusDBMsgTable.h"
#import "TempusDBRegTable.h"

@interface DBManager ()

@property (nonatomic, strong) NSString *dbFileName;
@property (nonatomic, strong) NSString *docDir;
@property (nonatomic, strong) NSError *err;
@property (nonatomic, strong) NSLock *lock;

@end


@implementation DBManager

static sqlite3* msDb = nil;
static int msDbOpenCount = 0;

#pragma mark - static methods
+(instancetype) sharedInstance {
    static DBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithDBFileName:kDB_FILE_NAME];
    });
    
    return sharedInstance;
}



#pragma mark - public instance methods
- (NSMutableArray *) beaconDeviceList {
    
    NSString *query = [@"SELECT shortId, major, minor FROM " stringByAppendingString:kDEVICE_TABLE_NAME];;
    sqlite3_stmt *statement = nil;
    NSMutableArray  *deviceList = nil;
    
    [self retainDb];
    
    int result = sqlite3_prepare_v2(msDb, [query UTF8String], -1, &statement, nil);
    if (SQLITE_OK != result) {
        DDLogError(@"Get beacon device list from DB error.");
        DDLogError(@"Error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
    } else {
        deviceList = [[NSMutableArray alloc] initWithCapacity:sqlite3_column_count(statement)];
        while (SQLITE_ROW == sqlite3_step(statement)) {
            TempusBeacon *tempusBeacon = [[TempusBeacon alloc] init];
            tempusBeacon.shortId = [NSString stringWithFormat:@"%s", sqlite3_column_text(statement, 0)];
            tempusBeacon.major = sqlite3_column_int(statement, 1);
            tempusBeacon.minor = sqlite3_column_int(statement, 2);
            tempusBeacon.identifier = tempusBeacon.shortId;
            tempusBeacon.domain = kUUID_STR;
            
            [deviceList addObject:tempusBeacon];
        }
    }
    
    sqlite3_finalize(statement);
    
    [self releaseDb];
    
    return deviceList;
}


-  (BOOL) storeRegMsg:(TempusRegMsg *)msg {
    NSString *query = [NSString stringWithFormat: @"INSERT INTO %@ (%@, %@) VALUES(?, ?)",
                       kTEMPUS_MSG_TABLE_NAME, kTEMPUS_MSG_TABLE_COLUMN_DATE, kTEMPUS_MSG_TABLE_COLUMN_CONTENT];
    sqlite3_stmt *statement = nil;
    
    [self retainDb];
    
    int result = sqlite3_prepare_v2(msDb, [query UTF8String], -1, &statement, nil);
    if (SQLITE_OK != result) {
        DDLogError(@"Error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
        
        if (statement)
            sqlite3_finalize(statement);
        
        [self releaseDb];
        
        return NO;
    }
    
    sqlite3_bind_int64(statement, 1, floor([msg.time timeIntervalSince1970] * 1000.));
    sqlite3_bind_text(statement, 2, [msg.msg UTF8String], (int)[msg.msg length], nil);
    
    result = sqlite3_step(statement);
    if (SQLITE_DONE != result) {
        DDLogError(@"Sqlite error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
    }
    
    sqlite3_finalize(statement);
    [self releaseDb];
    
    return SQLITE_DONE == result;
}


- (NSArray *) regMsgsWithLimit:(NSInteger)limit {
    NSString *query = [NSString stringWithFormat:@"SELECT %@, %@ FROM %@ ORDER BY _id DESC LIMIT ?",
                       kTEMPUS_MSG_TABLE_COLUMN_DATE, kTEMPUS_MSG_TABLE_COLUMN_CONTENT, kTEMPUS_MSG_TABLE_NAME];
    sqlite3_stmt *statement = nil;
    
    [self retainDb];
    
    int result = sqlite3_prepare(msDb, [query UTF8String], -1, &statement, nil);
    if (SQLITE_OK != result) {
        DDLogError(@"Sqlite error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
        if (statement)
            sqlite3_finalize(statement);
        [self releaseDb];
        
        return nil;
    }
    
    sqlite3_bind_int64(statement, 1, limit);
    
    NSMutableArray *msgs = [[NSMutableArray alloc] init];
    while (SQLITE_ROW == sqlite3_step(statement)) {
        TempusRegMsg *regMsg = [[TempusRegMsg alloc] init];
        regMsg.time = [[NSDate alloc] initWithTimeIntervalSince1970:sqlite3_column_int64(statement, 0) / 1000. ];
        regMsg.msg = [NSString stringWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
        
        [msgs addObject:regMsg];
    }
    
    sqlite3_finalize(statement);
    [self releaseDb];
    
    return msgs;
}


- (BOOL) storeInOutRegRecord:(TempusRegRecord *)record {
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@) VALUES (?, ?, ?, ?)", kTEMPUS_REG_TABLE_NAME,
                       kTEMPUS_REG_TABLE_COLUMN_DATE, kTEMPUS_REG_TABLE_COLUMN_TYPE, kTEMPUS_REG_TABLE_COLUMN_BEACON,
                       kTEMPUS_REG_TABLE_COLUMN_USER];
    sqlite3_stmt *stmt = nil;
    
    [self retainDb];
    int result = sqlite3_prepare(msDb, [query UTF8String], -1, &stmt, nil);
    if (SQLITE_OK != result) {
        DDLogError(@"Sqlite error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
        if (stmt)
            sqlite3_finalize(stmt);
        [self releaseDb];
        
        return false;
    }
    
    TempusInOutRegRecord *recd = (TempusInOutRegRecord *) record;
    
    sqlite3_bind_int64(stmt, 1, floor([recd.date timeIntervalSince1970] * 1000.f));
    sqlite3_bind_int64(stmt, 2, recd.type);
    sqlite3_bind_text(stmt, 3, [recd.beaconShortId UTF8String], (int)recd.beaconShortId.length, nil);
    sqlite3_bind_text(stmt, 4, [recd.userId UTF8String], (int)recd.userId.length, nil);
    
    result = sqlite3_step(stmt);
    if (SQLITE_DONE != result) {
        DDLogError(@"Sqlite error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
    }
    
    sqlite3_finalize(stmt);
    [self releaseDb];
    
    return SQLITE_DONE == result;
}


- (NSArray *) lastRegRecordsWithLimit:(NSInteger)limit {
    NSString *query = [NSString stringWithFormat:@"SELECT %@, %@, %@, %@ FROM %@ ORDER BY _id DESC LIMIT ?",
                       kTEMPUS_REG_TABLE_COLUMN_DATE, kTEMPUS_REG_TABLE_COLUMN_TYPE, kTEMPUS_REG_TABLE_COLUMN_BEACON,
                       kTEMPUS_REG_TABLE_COLUMN_USER, kTEMPUS_REG_TABLE_NAME];
    sqlite3_stmt *stmt = nil;
    
    [self retainDb];
    int result = sqlite3_prepare(msDb, [query UTF8String], -1, &stmt, nil);
    if (SQLITE_OK != result) {
        DDLogError(@"Sqlite error code: %d", result);
        DDLogError(@"%s", sqlite3_errmsg(msDb));
        if (stmt)
            sqlite3_finalize(stmt);
        [self releaseDb];
        
        return false;
    }
    
    sqlite3_bind_int64(stmt, 1, limit);
    
    NSMutableArray *regRecords = [[NSMutableArray alloc] init];
    while (SQLITE_ROW == sqlite3_step(stmt)) {
        TempusInOutRegRecord *regRecord = [[TempusInOutRegRecord alloc] init];
        regRecord.date = [[NSDate alloc] initWithTimeIntervalSince1970:sqlite3_column_int64(stmt, 0) / 1000. ];
        regRecord.type = sqlite3_column_int64(stmt, 1);
        regRecord.beaconShortId = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
        regRecord.userId = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
        
        [regRecords addObject:regRecord];
    }
    
    sqlite3_finalize(stmt);
    [self releaseDb];
    
    return regRecords;
}



#pragma mark - private methods
- (instancetype) initWithDBFileName: (NSString *) dbFileName {
    self = [super init];
    
    if (self) {
        NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        self.docDir = pathArr[0];
        self.dbFileName = dbFileName;
        
        //copy db from souce package to bundle
        //if not success
        if (![self copyDBIntoDocDir])
            self = nil;
        else { //success, open db
            NSString *dbPath = [self.docDir stringByAppendingPathComponent:self.dbFileName];
            int result = sqlite3_open([dbPath UTF8String], &msDb);
            if (SQLITE_OK != result) { //open db failed,
                DDLogError(@"Cannot open database!");
                DDLogError(@"Error code: %d.", result);
                if (msDb) {
                    DDLogError(@"%s", sqlite3_errmsg(msDb));
                    sqlite3_close(msDb);
                }
                self = nil;
            } else { //open db successfully
                msDbOpenCount = 0;
                self.lock = [[NSLock alloc] init];
            }
        }
    }
    
    return self;
}


- (BOOL) copyDBIntoDocDir {
    NSString *dbPath = [self.docDir stringByAppendingPathComponent:self.dbFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath])
        return YES;
    
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.dbFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:srcPath]) {
        DDLogError(@"Cannot find DB file in source package %@", srcPath);
        return NO;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dbPath error:&error];
    
    if (error != nil) {
        DDLogError(@"%@", error.localizedDescription);
        DDLogError(@"%@", error.localizedFailureReason);
        return NO;
    }
    
    return YES;
}


- (void) retainDb {
    [self.lock lock];
    
    ++msDbOpenCount;
    
    [self.lock unlock];
}


- (void) releaseDb {
    [self.lock lock];
    
    if (msDbOpenCount <= 0) {
        DDLogError(@"DB retain and release error!");
    }else
        --msDbOpenCount;
    
    [self.lock unlock];
}

@end