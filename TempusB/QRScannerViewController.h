//
//  QRScannerViewController.h
//  TempusB
//
//  Created by Wenlu Zhang on 15/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QRScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) void (^scanComplete) (NSString *);

- (instancetype) initWithCompletion: (void (^) (NSString *)) completion;

@end
