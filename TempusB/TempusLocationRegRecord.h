//
//  TempusLocationRegRecord.h
//  TempusB
//
//  Created by Wenlu Zhang on 25/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusRegRecord.h"

@class TempusLocation;

@interface TempusLocationRegRecord : TempusRegRecord
@property (nonatomic, strong) TempusLocation *tempusLocation;
@end
