//
//  QRScannerViewController.m
//  TempusB
//
//  Created by Wenlu Zhang on 15/06/15.
//  Copyright (c) 2015 Tempus AS. All rights reserved.
//

#import "QRScannerViewController.h"
#import "CocoaLumberjack/CocoaLumberjack.h"

@interface QRScannerViewController ()
@property (nonatomic, strong) AVCaptureSession *capSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIView *previewView;
@end

@implementation QRScannerViewController

- (instancetype) initWithCacelBtnEnable: (BOOL)enable complete: (void (^) (NSString *)) completion {
    if (!enable)
        return [self initWithCompletion:completion];
    
    self = [super init];
    
    if (self) {
        self.cancelBtn = [[UIButton alloc] init];
        [self.cancelBtn setTitle:NSLocalizedString(@"CANCEL", "cancel") forState:UIControlStateNormal];
        self.previewView = [[UIView alloc] initWithFrame:CGRectZero];
        self.scanComplete = completion;
    }
    
    return self;
}


- (instancetype) initWithCompletion: (void (^) (NSString *)) completion {
    self = [super init];
    
    if (self) {
        self.previewView = [[UIView alloc] initWithFrame:CGRectZero];
        self.scanComplete = completion;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    [self.navigationController setNavigationBarHidden:NO];
    [self.previewView setBackgroundColor:[UIColor redColor]];
    
    if (!self.cancelBtn) {
        [self.view addSubview:self.previewView];
        [self.previewView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:4];
        [constraints addObject: [NSLayoutConstraint constraintWithItem:self.previewView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0f
                                                              constant:0.0f]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.previewView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0f
                                                             constant:0.0f]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.previewView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0f
                                                             constant:0.0f]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.previewView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.view
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0f
                                                             constant:0.0f]];
        
        [self.view addConstraints:constraints];
    }
    else {
        [self.view addSubview:self.previewView];
        [self.view addSubview:self.cancelBtn];
        //set up constraints for btn and previewView
        //........
    }
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setUpCamera];
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void) viewDidDisappear:(BOOL)animated {
    [self releaseAVResource];
    [super viewDidDisappear:animated];
}


- (void) dealloc {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (BOOL) shouldAutorotate {
    return NO;
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate methods
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (!metadataObjects || [metadataObjects count] <= 0)
        return;
    
    AVMetadataMachineReadableCodeObject *readableCodeObj = [metadataObjects objectAtIndex:0];
    
    if (![[readableCodeObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        return;
    
    NSString *shortId = [readableCodeObj stringValue];
    [self.capSession stopRunning];
    
    self.scanComplete (shortId);
}



#pragma mark - private methods
- (BOOL) setUpCamera {
    //obtain AV device and input from the device
    NSError *err = nil;
    AVCaptureDevice *capDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:capDevice error:&err];
    
    if (!deviceInput) {
        DDLogError(@"%@", [err localizedDescription]);
        return NO;
    }
    
    //create a capture session and set up input and output to the session
    self.capSession = [[AVCaptureSession alloc] init];
    [self.capSession addInput:deviceInput];
    AVCaptureMetadataOutput *capMetadatOut = [[AVCaptureMetadataOutput alloc] init];
    [self.capSession addOutput:capMetadatOut];
    
    //set delegate and metadata types for the captured output
    dispatch_queue_t dispatchQue;
    dispatchQue = dispatch_queue_create("no.tempus.avcapture.metadataProcessor", NULL);
    [capMetadatOut setMetadataObjectsDelegate:self queue:dispatchQue];
    [capMetadatOut setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    
    //init video preview layer, set up its frame and add it to the previewView
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.capSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.previewView.frame];
    [self.previewView.layer addSublayer:self.videoPreviewLayer];
    
   
    [self.capSession startRunning];
    
    
    return YES;
}


- (void) releaseAVResource {
    if ([self.capSession isRunning])
        [self.capSession stopRunning];
    self.capSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
}

@end
