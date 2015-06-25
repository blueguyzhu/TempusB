//
//  TempusInOutRegRecord.h
//  TempusB
//
//  Created by Wenlu Zhang on 18/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#define kREG_TYPE_IN        1
#define kREG_TYPE_OUT       2

#import "TempusRegRecord.h"

@interface TempusInOutRegRecord : TempusRegRecord

@property (nonatomic, strong) NSString *beaconShortId;
//@property (nonatomic, strong) NSString *userId;

@end
