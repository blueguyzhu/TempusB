//
//  TempusCircularRegion.h
//  TempusB
//
//  Created by Wenlu Zhang on 25/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TempusCircularRegion : CLCircularRegion
@property (nonatomic, strong) NSString *beaconId;
@end
