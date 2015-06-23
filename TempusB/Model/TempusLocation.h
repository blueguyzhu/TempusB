//
//  TempusLocation.h
//  TempusB
//
//  Created by Wenlu Zhang on 23/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TempusLocation : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
