//
//  DropdownListViewController.h
//  TempusB
//
//  Created by Wenlu Zhang on 11/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropdownListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (void) registerListIcons: (NSArray *) iconNames;
- (void) registerListTitles: (NSArray *) titles;

- (void) registerRowSelectAction: (SEL)action ofTarget: (id)target;
- (void) registerRowSelectAction:(SEL)action ofTarget:(id)target atRow: (NSUInteger)row;

@end
