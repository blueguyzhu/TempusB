//
//  TempusRLDataParser.m
//  TempusB
//
//  Created by Wenlu Zhang on 16/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "TempusRLDataParser.h"
#import "TempusEmployee.h"

@implementation TempusRLDataParser
+ (NSArray *) R2LParseEmployeeList:(id)rArr {
    NSArray *remoteList = (NSArray *) rArr;
    NSMutableArray *localList = [[NSMutableArray alloc] initWithCapacity:remoteList.count];
    
    for (NSDictionary *rawEmployee in remoteList) {
        TempusEmployee *tempusEmployee = [[TempusEmployee alloc] init];
        tempusEmployee.name = [NSString stringWithString:[rawEmployee objectForKey:@"Navn"]];
        tempusEmployee.identifier = [rawEmployee objectForKey:@"AnsattNr"];
        
        [localList addObject:tempusEmployee];
    }
    
    return localList;
}
@end
