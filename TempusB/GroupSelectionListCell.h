//
//  GroupSelectionListCell.h
//  TempusB
//
//  Created by Wenlu Zhang on 19/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupSelectionListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *headIcon;
@property (nonatomic, weak) IBOutlet UIImageView *trailIcon;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UISwitch *funSwitch;

@end
