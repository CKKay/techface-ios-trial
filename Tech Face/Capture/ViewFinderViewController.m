//
//  ViewFinderViewController.m
//  Tech Face
//
//  Created by John on 2019-6-29.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "ViewFinderViewController.h"
#import "CaptureViewController.h"
#import "BDCamera.h"
#import "Server.h"
#import "NSString+Extended.h"
#import "UIImage+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "CameraGridView.h"

@import AssetsLibrary;
@import AVFoundation;
@import AVKit;

@interface ViewFinderViewController () <BDCameraDelegate, AVCapturePhotoCaptureDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scZoom;

@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCapturePhotoOutput *photoOutput;


@property (assign, nonatomic) int currentIndex;
@property (assign, nonatomic) double currentZoom;
@property (assign, nonatomic) int captureVideoPhoto;

@property (nonatomic, assign, getter = isRecorning) BOOL recording;
@property (nonatomic, strong) BDCamera *camera;

@property (weak, nonatomic) UIImageView *faceView;
@property (weak, nonatomic) CameraGridView  *cameraGridView;
@property (assign, nonatomic) BOOL runVideoRecording;
@property (assign,nonatomic) float ISO;
@property (assign ,nonatomic) AVCaptureWhiteBalanceGains deviceWhitBalanceGains;
@property (assign,nonatomic) float ISO_current;
@property (assign ,nonatomic) AVCaptureWhiteBalanceGains deviceWhitBalanceGains_current;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSMutableDictionary *mode1;
@property (strong, nonatomic) NSMutableDictionary *mode2;
@property (strong, nonatomic) NSMutableArray *currentMode;
@property (strong, nonatomic) NSMutableArray *exposureSetting;
@property (strong, nonatomic) NSString *selectCurrentExposure;
@property (weak, nonatomic) IBOutlet UILabel *mode1date;
@property (weak, nonatomic) IBOutlet UILabel *mode2date;
@property (assign,nonatomic) float fadeDuration ;
@property (assign,nonatomic) float fadeOutDuration ;
@property (assign,nonatomic) BOOL continueToTakePhoto;
@property (assign,nonatomic) BOOL runAutoExposure;
@property (assign, nonatomic) long currentSegmentIndex;
@property (assign, nonatomic) BOOL autoRunExposureBtn;


- (IBAction)segmentBtn:(id)sender;

- (IBAction)setExposure:(id)sender;

@end

@implementation ViewFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.leftImageView setTag:0];
    [self.hLeftImageView setTag:1];
    [self.frontImageView setTag:2];
    [self.hRightImageView setTag:3];
    [self.rightImageView setTag:4];
    [self.videoImageView setTag:5];
    
    [self addTapGestureToImageView:self.leftImageView];
    [self addTapGestureToImageView:self.hLeftImageView];
    [self addTapGestureToImageView:self.frontImageView];
    [self addTapGestureToImageView:self.hRightImageView];
    [self addTapGestureToImageView:self.rightImageView];
    [self addTapGestureToImageView:self.videoImageView];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
    self.user_id = [myDictionary valueForKeyPath:@"id"];
    self.clientId = [userDefaults objectForKey:@"selected_client_id"];
    
    NSData *clientsData = [userDefaults dataForKey:@"selected_client"];
    NSDictionary *clientDict;
    if ([[userDefaults objectForKey:@"capture_current"] isEqualToString:@"existing"]) {
        NSInteger clientIndex = [[userDefaults objectForKey:@"selected_client_row"] intValue];
        NSArray *clients = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
        clientDict = clients[clientIndex];
    } else {
        clientDict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
    }
    self.exposureSetting = [clientDict objectForKey:@"device_exposure_setting"];
    
    NSMutableArray *getExposure = [userDefaults objectForKey:@"client_exposure_setting"];
    if([getExposure count] > 0){
        self.exposureSetting =getExposure;
    }
    
    NSMutableArray *client_exposure_setting =[[NSMutableArray alloc] init];
    
    NSLog(@"Mode data : %@", self.exposureSetting);
    
    self.mode1 = [[NSMutableDictionary alloc] init];
    self.mode2 = [[NSMutableDictionary alloc] init];
    self.runAutoExposure = true;
    for(NSArray *obj in self.exposureSetting){
        [client_exposure_setting addObject:obj];
        [self updateMode1AndMode2Param: obj];
    }
    [userDefaults setObject:client_exposure_setting forKey:@"client_exposure_setting"];
    [userDefaults synchronize];
    
    
    //Initial the Segment Control start
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1.3;
    [self.segmentControl.layer addAnimation:animation forKey:nil];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject: [UIFont fontWithName: @"Arial" size:14] forKey:NSFontAttributeName];
    [self.segmentControl setTitleTextAttributes: attributes forState: UIControlStateNormal];
    [self.segmentControl setTitleTextAttributes: @{NSForegroundColorAttributeName: UIColor.whiteColor} forState: UIControlStateSelected];
    
    self.mode1date.layer.masksToBounds = YES;
    self.mode1date.layer.cornerRadius = 5;
    self.mode1date.alpha = 0;
    
    self.mode2date.layer.masksToBounds = YES;
    self.mode2date.layer.cornerRadius = 5;
    self.mode2date.alpha = 0;
    self.fadeDuration=0.6;
    self.fadeOutDuration=0;
    
    self.currentZoom = 1;
    
}



- (void)updateMode1AndMode2Param:(NSArray*)modeArray {
    
    float iso =  [[modeArray valueForKey:@"iso"] floatValue];
    float redgain = [[modeArray valueForKey:@"red_gain"]floatValue];
    float bluegain = [[modeArray valueForKey:@"blue_gain"]floatValue];
    float greengain = [[modeArray valueForKey:@"green_gain"]floatValue];
    NSString *status = [modeArray valueForKey:@"status"];
    NSString *mode = [modeArray valueForKey:@"type"];
    NSString *treatment_date = [modeArray valueForKey:@"treatment_date"];
    
    if([mode isEqualToString:@"MODE_01"]){
        
        [self.mode1 removeAllObjects];
        [self.mode1 setObject:[NSNumber numberWithFloat: iso] forKey:@"iso"];
        [self.mode1 setObject:[NSNumber numberWithFloat: bluegain] forKey:@"blueGain"];
        [self.mode1 setObject:[NSNumber numberWithFloat: greengain] forKey:@"greenGain"];
        [self.mode1 setObject:[NSNumber numberWithFloat: redgain] forKey:@"redGain"];
        [self.mode1 setObject:treatment_date forKey:@"treatment_date"];
        [self.mode1 setObject:status forKey:@"status"];
        if([status isEqualToString:@"Y"]){
            self.runAutoExposure = false;
        }
        
        //self.runAutoExposure
        
        if([treatment_date length] > 10){
            NSRange range = [treatment_date rangeOfComposedCharacterSequencesForRange:(NSRange){2,9}];
            treatment_date = [treatment_date substringWithRange:range];
            
            [self fadeIn:self.mode1date withDuration:self.fadeDuration andWait:0];
            
            self.mode1date.text = treatment_date;
            
        } else {
            [self fadeOut:self.mode1date withDuration:self.fadeOutDuration andWait:0];
            
        }
        
        
    } else {
        
        [self.mode2 removeAllObjects];
        [self.mode2 setObject:[NSNumber numberWithFloat: iso] forKey:@"iso"];
        [self.mode2 setObject:[NSNumber numberWithFloat: bluegain] forKey:@"blueGain"];
        [self.mode2 setObject:[NSNumber numberWithFloat: greengain] forKey:@"greenGain"];
        [self.mode2 setObject:[NSNumber numberWithFloat: redgain] forKey:@"redGain"];
        [self.mode2 setObject:treatment_date forKey:@"treatment_date"];
        [self.mode2 setObject:status forKey:@"status"];
        if([status isEqualToString:@"Y"]){
            self.runAutoExposure = false;
        }
        
        
        if([treatment_date length] > 10){
            NSRange range = [treatment_date rangeOfComposedCharacterSequencesForRange:(NSRange){2,9}];
            treatment_date = [treatment_date substringWithRange:range];
            
            [self fadeIn:self.mode2date withDuration:self.fadeDuration andWait:0];
            self.mode2date.text = treatment_date;
            
        }else {
            [self fadeOut:self.mode2date withDuration:self.fadeOutDuration andWait:0];
            
            
        }
        
    }
    
}


- (void)didReceiveMemoryWarning {
    NSLog(@"View Finder view Controller dealloc Warning");
    if ([self isViewLoaded] && [self.view window] == nil) {
        DLog(@"View Finder view Controller dealloc is deallocing now!");
        
    }
    [super didReceiveMemoryWarning];
    
}



- (CaptureViewController *)parentVC {
    return (CaptureViewController *)self.parentViewController;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Actions

- (void)writeMessageToBluno:(int)message {
    if (![self.parentVC writeMessageToBluno:message]) {
        [SVProgressHUD dismiss];
        [self showDismissAlertWithTitle:@"Device not ready"
                                message:@"Please try again or restart."];
        // if recording, stop recording
        
        if ([self isRecorning]) {
            self.startButton.hidden = false;
            [self stopVideoSession];
            [self startCameraSession];
        }
    }
}

- (IBAction)onZoomChangedAction:(id)sender {
    NSError *error;
    AVCaptureDevice *device = self.captureDevice;
    if ([device lockForConfiguration:&error]) {
        NSString *factor = [[self.scZoom titleForSegmentAtIndex:self.scZoom.selectedSegmentIndex] stringByReplacingOccurrencesOfString:@"X" withString:@""];
        self.currentZoom = factor.doubleValue;
        device.videoZoomFactor = self.currentZoom * 1.25;
        [device unlockForConfiguration];
    }
}

- (IBAction)startManualCaptureAction:(id)sender {
    [self moveToNextPosition];
}

- (IBAction)startCaptureAction:(id)sender {
    if (self.videoImageView.image == nil) {
        [self _startCaptureAction];
    } else {
        [self showAlertWithTitle:@"Do you want to retake?" message:@"Current capture will be discarded."
               cancelButtonTitle:@"No" cancelHandler:nil
                   okButtonTitle:@"Sure" okHandler:^(UIAlertAction * _Nonnull action) {
            
            self.leftImageView.image = nil;
            self.hLeftImageView.image = nil;
            self.frontImageView.image = nil;
            self.hRightImageView.image = nil;
            self.rightImageView.image = nil;
            self.videoImageView.image = nil;
            
            [self _startCaptureAction];
        }];
    }
}

- (void)_startCaptureAction {
    self.startButton.hidden = true;
    [SVProgressHUD show];
    [self moveToNextPosition];
}

- (void)updateManualCaptureButtonImage {
    bool hideManualCapture = !self.isTesting;
    NSString *buttonImage = @"camerabutton.png";
    NSString *faceImage = @"face_left_90.png";
    if (self.leftImageView.image == nil) {
        buttonImage = @"camerabutton.png";
        faceImage = @"face_left_90.png";
    } else if (self.hLeftImageView.image == nil) {
        buttonImage = @"camerabutton.png";
        faceImage = @"face_left_45.png";
    } else if (self.frontImageView.image == nil) {
        buttonImage = @"camerabutton.png";
        faceImage = @"face_front.png";
    } else if (self.hRightImageView.image == nil) {
        buttonImage = @"camerabutton.png";
        faceImage = @"face_right_45.png";
    } else if (self.rightImageView.image == nil) {
        buttonImage = @"camerabutton.png";
        faceImage = @"face_right_90.png";
    } else if (self.videoImageView.image == nil) {
        buttonImage = @"videobutton.png";
        faceImage = @"face_right_90.png";
        if (self.isRecorning) {
            buttonImage = @"videobutton_stop.png";
        }
    } else {
        buttonImage = @"camerabutton.png";
        hideManualCapture = true;
    }
    self.btnManualCapture.hidden = hideManualCapture;
    [self.btnManualCapture setImage:[UIImage imageNamed:buttonImage] forState:(UIControlState)UIControlStateNormal];
    [self.faceView setImage:[UIImage imageNamed:faceImage]];
    
    [self getNumOfPhotoAndDisableSwitch];
}

- (void)moveToNextPosition {
    if (self.leftImageView.image == nil) {
        self.currentIndex = 0;
    } else if (self.hLeftImageView.image == nil) {
        self.currentIndex = 1;
    } else if (self.frontImageView.image == nil) {
        self.currentIndex = 2;
    } else if (self.hRightImageView.image == nil) {
        self.currentIndex = 3;
    } else if (self.rightImageView.image == nil) {
        self.currentIndex = 4;
    } else if (self.videoImageView.image == nil) {
        self.currentIndex = 5;
    } else {
        [self endCapture];
        return;
    }
    
    if (self.currentIndex == 5) {
        if (self.isRecorning) {
            [SVProgressHUD show];
            [self doCaptureAction];
        } else {
            
            self.runVideoRecording = true;
            [self stopCameraSession];
            
            [self startVideoSession];
            
            if(self.runVideoRecording){
                
                [self doCaptureAction];
                if (!self.isTesting) {
                    DLog(@"001 Testing before delay writeMessageToBluno");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self writeMessageToBluno:self.currentIndex];
                    });
                }
                
            }
            
        }
    } else {
        if (self.isTesting) {
            [self doCaptureAction];
        } else {
            [self writeMessageToBluno:self.currentIndex];
        }
    }
}

- (void)endCapture {
    self.currentIndex = 6;
    if (!self.isTesting) {
        self.startButton.hidden = false;
    }
    [self stopVideoSession];
    [self startCameraSession];
    [SVProgressHUD dismiss];
}

- (void)doCaptureAction {
    if (self.currentIndex == 5) {
        if (self.isRecorning) {
            // Stop recording
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stopRecording];
            });
        } else {
            // Start recording
            [self startRecording];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([self isRecorning]) {
                    //
                } else {
                    [self endCapture];
                    [self showDismissAlertWithTitle:@"Unable to record"
                                            message:@"Video recording failed."];
                }
            });
        }
    } else {
        [self capturePhoto];
    }
}

- (void)capturePhoto {
    AVCapturePhotoSettings *settings = [[AVCapturePhotoSettings alloc] init];
    for (AVCaptureConnection *connection in self.photoOutput.connections) {
        BOOL hasConnection = false;
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                hasConnection = true;
                connection.videoOrientation = UIDeviceOrientationPortrait;
                break;
            }
        }
        if (hasConnection) {
            break;
        }
    }
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

#pragma mark - Camera

- (void)stopCameraSession {
    [self.previewLayer removeFromSuperlayer];
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.previewLayer = nil;
    
}

- (void)startCameraSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    if (device) {
        
        if(self.switchBtn.on){
            
            [device lockForConfiguration:nil];
            [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            [device unlockForConfiguration];
            
        } else {
            [device lockForConfiguration:nil];
            [device setExposureMode:AVCaptureExposureModeLocked];
            [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            
            
            if(self.captureVideoPhoto > 0){
                [device setExposureModeCustomWithDuration:CMTimeMake(6,200) ISO:self.ISO completionHandler:nil];
                [device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:(self.deviceWhitBalanceGains) completionHandler:nil];
                [device unlockForConfiguration];
                self.captureVideoPhoto = 0;
            } else {
                self.deviceWhitBalanceGains = device.deviceWhiteBalanceGains;
                [device unlockForConfiguration];
                self.ISO=device.ISO;
            }
        }
        
        
        
        self.captureDevice = device;
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
            [self showDismissAlertWithTitle:@"Unable to start camera"
                                    message:@"Please exit app and retry later."];
            return;
        }
        if ([self.captureSession canAddInput:deviceInput]) {
            [self.captureSession addInput:deviceInput];
            [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
            self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.previewLayer.frame = self.previewView.frame;
            
            CGRect rect = self.previewView.frame;
            NSLog(@"x=%f y=%f w=%f h=%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
            [self.previewView.layer addSublayer:self.previewLayer];
            
            if (!self.faceView) {
                UIImage *bgImage = [UIImage imageNamed:@"face_left_90.png"];
                
                UIImageView *faceview = [[UIImageView alloc] initWithImage:bgImage];
                float bgViewWidth = rect.size.width / 1;
                
                float bgViewHeight = (bgViewWidth / bgImage.size.width) * bgImage.size.height;
                
                [faceview setFrame:CGRectMake((rect.size.width / 2) - (bgViewWidth / 2), (rect.size.height / 2) - (bgViewHeight / 2) - 40, bgViewWidth, bgViewHeight)];
                self.faceView = faceview;
                
                [self.view insertSubview:self.faceView atIndex:1];
            }
            
            if (!self.cameraGridView) {
                CameraGridView  *cameraGridView = [[CameraGridView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
                cameraGridView.opaque = NO;
                cameraGridView.numberOfColumns = 2;
                cameraGridView.numberOfRows = 2;
                self.cameraGridView = cameraGridView;
                [self.view insertSubview:self.cameraGridView atIndex:1];
                cameraGridView=nil;
            }
            
            self.photoOutput = [[AVCapturePhotoOutput alloc] init];
            if ([self.captureSession canAddOutput:self.photoOutput]) {
                [self.captureSession addOutput:self.photoOutput];
                [self.captureSession startRunning];
            }
            
        }
        [self onZoomChangedAction:nil];
        [self updateManualCaptureButtonImage];
        
    }
    

    if(!self.runAutoExposure){
        self.autoRunExposureBtn = true;
        [self.switchBtn setOn:NO animated:NO];
        [self setExposure:self];
        self.autoRunExposureBtn = false;
    } else {
        self.segmentControl.hidden = TRUE;
    }
    
}



#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    if (error) {
        [self showDismissAlertWithTitle:@"Error occurred" message:@"Please retry again."];
        [self endCapture];
        return;
    }
    NSData *data = [photo fileDataRepresentation];
    if (!data) {
        [self showDismissAlertWithTitle:@"No data" message:@"Please retry again."];
        [self endCapture];
        return;
    }
    
    UIImageView *imageView = [self currentImageView];
    NSString *name = [self currentMediaName];
    
    [[[UIImage alloc] initWithData:data] saveInDocumentAsName:name withQuality:1];
    
    imageView.image = [UIImage imageInDocumentWithName:name];
    
    [self updateManualCaptureButtonImage];
    
    data=nil;
    if (!self.isTesting) {
        [self moveToNextPosition];
    }
}

#pragma mark - Recording
- (void)startVideoSession {
    
    
    @try {
        self.camera = [[BDCamera alloc] initWithPreviewView:self.previewView preset:AVCaptureSessionPreset1920x1080];
        
        DLog(@"001 Testing in startVideoSession get camera %@ 003", self.camera);
        self.camera.videoDelegate = self;
        self.camera.zoom = self.currentZoom;
        if(!self.switchBtn.on){
            [self.camera setExposureAndWhitBalance:self.ISO whiteBalance:self.deviceWhitBalanceGains];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            DLog(@"001 Testing in setWhiteBalanceGainession in delay before startCameraCapture 004");
            [self.camera startCameraCapture];
            
        });
        
    } @catch (NSException *exception) {
        self.runVideoRecording = false;
        [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"Techface 要求權限! 請打開 setting->Tech Face->咪高風"]];
    }
}

- (void)stopVideoSession {
    [self.camera stopCameraCapture];
    [self.camera.previewLayer removeFromSuperlayer];
     self.camera = nil;
}

- (NSURL *)getURLForNewVideo {
    NSString *videoPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    NSString *newFilepath = [NSString stringWithFormat:@"%@%@",videoPath, @"t_video.mp4"];
    unlink([newFilepath UTF8String]);
    NSLog(@"File name : %@", newFilepath);
    return [NSURL fileURLWithPath:newFilepath];
}

- (void)startRecording {
    self.recording = YES;
    [self updateManualCaptureButtonImage];
    NSURL *movieURL = [self getURLForNewVideo];
    //  [self.camera switchFPS:120.0f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [self.camera startRecordingWithURL:movieURL];
    });
}

- (void)stopRecording {
    self.recording = NO;
    [self.camera stopRecording];
}

#pragma mark - BDVideoCamera Delegate

- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL error:(NSError *)error
{
    DLog(@"Url : %@", outputFileURL.absoluteString);
    if (self.isRecorning) {
        DLog(@"return");
        return;
    }
    //	self.Videoapprove.hidden = false;
    //	self.Approve_Videothumbnail.image = [self.viewFinderVC thumbnailFromCapturedVideo];
    NSString *urlString = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
    NSString *urlString_tmp = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4.tmp"];
    NSURL *url_tmp = [NSURL fileURLWithPath:urlString_tmp];
    
    self.videoImageView.image = [self thumbnailFromCapturedVideo];
    AVAsset *video = [AVAsset assetWithURL:outputFileURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video presetName:AVAssetExportPreset1280x720];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = url_tmp;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"done processing video!");
        unlink([urlString UTF8String]);
        [[NSFileManager defaultManager] moveItemAtPath:urlString_tmp toPath:urlString error:nil];
        
        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
            self.captureVideoPhoto = 1;
            [self endCapture];
            [self updateManualCaptureButtonImage];
        });
    }];
}

#pragma mark - Image/Photo capture

- (void)addTapGestureToImageView:(UIImageView *)imageView {
    [self addTapGestureToView:imageView action:@selector(imageAction:)];
}

- (void)imageAction:(id)sender {
    UIGestureRecognizer *gesture = (UIGestureRecognizer *)sender;
    UIImageView *imageView = (UIImageView *)gesture.view;
    NSInteger index = imageView.tag;
    if (imageView.image && self.isTesting) {
        NSString *title = @"Do you want to retake this angle?";
        NSString *message = @"Current image will be discarded.";
        if (index == 5) {
            title = @"Do you want to retake this video?";
            message = @"This video will be discarded.";
        }
        [self showAlertWithTitle:title message:message
               cancelButtonTitle:@"No" cancelHandler:nil
                   okButtonTitle:@"Sure" okHandler:^(UIAlertAction * _Nonnull action) {
            imageView.image = nil;
            [self updateManualCaptureButtonImage];
        }];
    }
}

- (UIImageView *)currentImageView {
    if (self.currentIndex == 0) { return self.leftImageView; }
    if (self.currentIndex == 1) { return self.hLeftImageView; }
    if (self.currentIndex == 2) { return self.frontImageView; }
    if (self.currentIndex == 3) { return self.hRightImageView; }
    if (self.currentIndex == 4) { return self.rightImageView; }
    if (self.currentIndex == 5) { return self.videoImageView; }
    return nil;
}

- (NSString *)currentMediaName {
    if (self.currentIndex == 0) { return @"t_left.jpg"; }
    if (self.currentIndex == 1) { return @"t_half_left.jpg"; }
    if (self.currentIndex == 2) { return @"t_front.jpg"; }
    if (self.currentIndex == 3) { return @"t_half_right.jpg"; }
    if (self.currentIndex == 4) { return @"t_right.jpg"; }
    if (self.currentIndex == 5) { return @"t_video.mp4"; }
    return nil;
}

- (void) clearImage {
    
    [self.leftImageView removeFromSuperview];
    [self.hLeftImageView removeFromSuperview];
    [self.frontImageView removeFromSuperview];
    [self.frontImageView removeFromSuperview];
    [self.hRightImageView removeFromSuperview];
    [self.videoImageView removeFromSuperview];
    
    self.leftImageView = nil;
    self.hLeftImageView = nil;
    self.frontImageView = nil;
    self.hRightImageView = nil;
    self.rightImageView = nil;
    self.videoImageView = nil;
    
}


- (void) dealloc
{
    DLog(@"View Finder view Controller dealloc process");
    
}


#pragma mark - Helpers

- (UIImage *)thumbnailFromCapturedVideo {
    NSString *urlString = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
    NSURL *url = [NSURL fileURLWithPath:urlString];
    //	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    return [UIImage assetImageFromURL:url];
}

- (IBAction)setExposure:(id)sender {
    
    if(!self.autoRunExposureBtn){
        BOOL hasTakenPhoto = [self checkIfHaveTakenPhoto];
        
        if(hasTakenPhoto && !self.continueToTakePhoto){
            BOOL switchBtnOn = false;
            if(self.switchBtn.on){
                switchBtnOn = true;
            }else {
                switchBtnOn = false;
            }
            
            [self popUpForAllowingSwtichAutoExposure:switchBtnOn];
            return;
        }else if (self.continueToTakePhoto){
            self.continueToTakePhoto = false;
        }
    }
    
    
    if(self.switchBtn.on){
        self.runAutoExposure = true;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"current" forKey:@"currentMode"];
        [userDefaults synchronize];
        
        [self reloadExposureBrightness:@"auto"];
        
        [UIView transitionWithView:self.segmentControl duration:2.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.segmentControl.hidden = TRUE;
            
        } completion:NULL];
        [self fadeOut:self.mode1date withDuration:self.fadeOutDuration andWait:0];
        [self fadeOut:self.mode2date withDuration:self.fadeOutDuration andWait:0];
        
    } else if(!self.switchBtn.on){
        
        self.runAutoExposure = false;
        
        NSString *runMode1 = [self.mode1 objectForKey:@"status"];
        NSString *runMode2 = [self.mode2 objectForKey:@"status"];
        NSString *treatment_date1 = [self.mode1 objectForKey:@"treatment_date"];
        NSString *treatment_date2 = [self.mode2 objectForKey:@"treatment_date"];
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if([self.selectCurrentExposure isEqualToString:@"Y"]) {
            [self reloadExposureBrightness:@"auto"];
            [self.segmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            self.deviceWhitBalanceGains = self.deviceWhitBalanceGains_current;
            self.ISO=self.ISO_current;
            [userDefaults setObject:@"current" forKey:@"currentMode"];
            self.currentSegmentIndex = 4;
            [self.segmentControl setSelectedSegmentIndex:4];
        } else if ([runMode1 isEqualToString:@"Y"]){
            [self setMode1AndMode2ToCurrentMode:@"MODE_01"];
            [userDefaults setObject:@"MODE_01" forKey:@"currentMode"];
            self.currentSegmentIndex = 0;
            [self.segmentControl setSelectedSegmentIndex:0];
            
        } else if([runMode2 isEqualToString:@"Y"]){
            [self setMode1AndMode2ToCurrentMode:@"MODE_02"];
            [userDefaults setObject:@"MODE_02" forKey:@"currentMode"];
            self.currentSegmentIndex = 2;
            [self.segmentControl setSelectedSegmentIndex:2];
            
        } else {
            [self reloadExposureBrightness:@"auto"];
            [userDefaults setObject:@"current" forKey:@"currentMode"];
            [self.segmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            self.deviceWhitBalanceGains = self.deviceWhitBalanceGains_current;
            self.ISO=self.ISO_current;
            self.currentSegmentIndex = 4;
            [self.segmentControl setSelectedSegmentIndex:4];
        }
        [userDefaults synchronize];
        
        [self reloadExposureBrightness:@"Manual"];
        
        
        [UIView transitionWithView:self.segmentControl duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            self.segmentControl.hidden = FALSE;
            
        } completion:^(BOOL finished){
            
            //treatment_date
            if([NSString isEmpty:treatment_date1]){
                [self fadeOut:self.mode1date withDuration:self.fadeOutDuration andWait:0];
            } else {
                [self fadeIn:self.mode1date withDuration:self.fadeDuration andWait:0];
            }
            if([NSString isEmpty:treatment_date2]){
                [self fadeOut:self.mode2date withDuration:self.fadeOutDuration andWait:0];
            } else {
                [self fadeIn:self.mode2date withDuration:self.fadeDuration andWait:0];
            }
            
            
        }];
        
    }
    
}




- (void)reloadExposureBrightness:(NSString *)mode{
    
    if([mode isEqualToString:@"Manual"]){
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setExposureMode:AVCaptureExposureModeLocked];
        [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        
        [self.captureDevice setExposureModeCustomWithDuration:CMTimeMake(6,200) ISO:self.ISO completionHandler:nil];
        [self.captureDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:(self.deviceWhitBalanceGains) completionHandler:nil];
        
        [self.captureDevice unlockForConfiguration];
    } else if ([mode isEqualToString:@"auto"]){
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        [NSThread sleepForTimeInterval:0.4f];
        
        self.deviceWhitBalanceGains_current = self.captureDevice.deviceWhiteBalanceGains;
        self.ISO_current=self.captureDevice.ISO;
        
        [self.captureDevice unlockForConfiguration];
        
        
    }
}


- (void)setMode1AndMode2ToCurrentMode:(NSString *) mode{
    
    float redGain = 0.0 ;
    float blueGain = 0.0 ;
    float greenGain = 0.0 ;
    float iso = 0.0 ;
    
    if([mode isEqualToString:@"MODE_01"]){
        
        redGain  = [[self.mode1 objectForKey:@"redGain"] floatValue];
        blueGain  =[[self.mode1 objectForKey:@"blueGain"] floatValue];
        greenGain  = [[self.mode1 objectForKey:@"greenGain"] floatValue];
        iso =  [[self.mode1 objectForKey:@"iso"] floatValue];
        
    }else if([mode isEqualToString:@"MODE_02"]){
        
        redGain  = [[self.mode2 objectForKey:@"redGain"] floatValue];
        blueGain  =[[self.mode2 objectForKey:@"blueGain"] floatValue];
        greenGain  = [[self.mode2 objectForKey:@"greenGain"] floatValue];
        iso =  [[self.mode2 objectForKey:@"iso"] floatValue];
        
    }
    
    
    AVCaptureWhiteBalanceGains newBalanceSet = {
        .redGain=redGain,
        .greenGain=greenGain,
        .blueGain=blueGain
    };
    
    self.deviceWhitBalanceGains =newBalanceSet;
    self.ISO=iso;
    
    
}


- (void)executeUpdateExposureInServer:(NSString *)mode {
    
    
    NSString *iso =[[NSNumber numberWithFloat:self.ISO] stringValue];
    NSString *bluegain =[[NSNumber numberWithFloat:self.deviceWhitBalanceGains.blueGain] stringValue];
    NSString *redgain =[[NSNumber numberWithFloat:self.deviceWhitBalanceGains.redGain] stringValue];
    NSString *greengain =[[NSNumber numberWithFloat:self.deviceWhitBalanceGains.greenGain] stringValue];
    
    NSURL *url = [Server url:@"/techface_api/updateExposureSetting?user_id=%@&client_id=%@&mode=%@&iso=%@&redgain=%@&bluegain=%@&greengain=%@",self.user_id,self.clientId, mode,iso,redgain,bluegain,greengain];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setTimeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask;
    dataTask = [session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                {
        DLog(@"Respose 123: %@", response);
        DLog(@"Data 123: %@", data);
        DLog(@"Error 123: %@", error);
        
        
        @try {
            NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *ad = [s objectForKey:@"message"];
            NSArray *exposuredata = [s objectForKey:@"data"];
            
            [SVProgressHUD dismiss];
            if ([ad isEqualToString:@"Update Success"]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:exposuredata forKey:@"client_exposure_setting"];
                [userDefaults synchronize];
                
                [self performSelectorOnMainThread:@selector(executeInMain:) withObject:mode waitUntilDone:true];
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                [self performSelectorOnMainThread:@selector(failResponse:) withObject:httpResponse waitUntilDone:true];
            }
        } @catch (NSException *exception) {
            
            [self performSelectorOnMainThread:@selector(failForException:) withObject:exception waitUntilDone:true];
            
        }
    }];
    [dataTask resume];
   
    
}

-(void) failForException:(NSException *)exception {
    [SVProgressHUD dismiss];
    [self showDismissAlertWithTitle:@"Server Error" message:[NSString stringWithFormat:@"Status : %@", exception.name]];
}


-(void) failResponse:(NSHTTPURLResponse *)httpResponse;{
    [self showDismissAlertWithTitle:@"Server Error Occurred" message:[NSString stringWithFormat:@"Status Code: %ld", httpResponse.statusCode]];
}

- (void)executeInMain:(NSString *)exposureMode; {
    
    int mode;
    bool updateCurrentModeSetting = false;
    if([exposureMode isEqualToString:@"SET_MODE_01"] || [exposureMode isEqualToString:@"SET_MODE_02"] ){
        mode = ([exposureMode isEqualToString:@"SET_MODE_01"]) ? 0 :2;
    } else {
        mode = ([exposureMode isEqualToString:@"MODE_01"]) ? 0 :2;
        updateCurrentModeSetting=true;
        
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *getExposure = [userDefaults objectForKey:@"client_exposure_setting"];
    
    for(NSArray *obj in getExposure){
        [self updateMode1AndMode2Param: obj];
    }
    if(updateCurrentModeSetting){
        [self setMode1AndMode2ToCurrentMode:exposureMode];
    }
    
    self.currentSegmentIndex = mode;
    [self.segmentControl setSelectedSegmentIndex:mode];
    
    [SVProgressHUD dismiss];
    [self reloadExposureBrightness:@"Manual"];
}



- (IBAction)segmentBtn:(id)sender{
    
    NSString *msg ;
    NSString *action;
    NSString *mode ;
    BOOL updateDatabasePopup = true;
    NSString *runMode1 = [self.mode1 objectForKey:@"status"];
    NSString *runMode2 = [self.mode2 objectForKey:@"status"];
    self.selectCurrentExposure = @"N";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    BOOL hasTakenPhoto = [self checkIfHaveTakenPhoto];
    
    if(hasTakenPhoto && !self.continueToTakePhoto){
        [self popUpForAllowingChangeMode:self.segmentControl.selectedSegmentIndex];
        return;
    }else if (self.continueToTakePhoto){
        self.continueToTakePhoto = false;
    }
    
    
    if(self.segmentControl.selectedSegmentIndex==0){
        msg=@"Index 0 pressed";
        action=@"SET";
        mode=@"SET_MODE_01";
     
        if([NSString isEmpty:runMode1]){
            
            self.segmentControl.selectedSegmentIndex = self.currentSegmentIndex;
            [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"Please save the Mode 1 Setting first"]];
            
        } else {
            [self setMode1AndMode2ToCurrentMode:@"MODE_01"];
            [userDefaults setObject:@"MODE_01" forKey:@"currentMode"];
            [userDefaults synchronize];
            
            [self performSelectorInBackground:@selector(executeUpdateExposureInServer:) withObject:mode];
            self.currentSegmentIndex = 0;
            updateDatabasePopup=FALSE;
        }
        
    } else if (self.segmentControl.selectedSegmentIndex==1){
        
        msg=@"Save Exposure data in Mode 1 ?";
        action=@"SAVE";
        mode=@"MODE_01";
        [userDefaults setObject:@"MODE_01" forKey:@"currentMode"];
        [userDefaults synchronize];
        
    } else if (self.segmentControl.selectedSegmentIndex==2){
        msg=@"Index 2 pressed";
        action=@"SET";
        mode=@"SET_MODE_02";
        
        if([NSString isEmpty:runMode2]){
           // [self.segmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            self.segmentControl.selectedSegmentIndex = self.currentSegmentIndex;
            [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"Please save the Mode 2 Setting first"]];
        } else {
            [self setMode1AndMode2ToCurrentMode:@"MODE_02"];
            [userDefaults setObject:@"MODE_02" forKey:@"currentMode"];
            [userDefaults synchronize];
            self.currentSegmentIndex = 2;
            [self performSelectorInBackground:@selector(executeUpdateExposureInServer:) withObject:mode];
            updateDatabasePopup=FALSE;
        }
        
        
    } else if (self.segmentControl.selectedSegmentIndex==3){
        msg=@"Save Exposure data in Mode 2 ?";
        action=@"SAVE";
        mode=@"MODE_02";
        [userDefaults setObject:@"MODE_02" forKey:@"currentMode"];
    
        [userDefaults synchronize];
    } else {
        self.selectCurrentExposure = @"Y";
        
        if( self.ISO_current==0){
            [self reloadExposureBrightness:@"auto"];
        }
        self.currentSegmentIndex = 4;
        self.ISO = self.ISO_current;
        self.deviceWhitBalanceGains=self.deviceWhitBalanceGains_current;
        updateDatabasePopup = FALSE;
        [userDefaults setObject:@"current" forKey:@"currentMode"];
        [userDefaults synchronize];
        [self reloadExposureBrightness:@"Manual"];
    }
    
    
    if(updateDatabasePopup){
        [self popUpForUpdateServer:msg mode:mode action:action];
    }
    
}

- (void)popUpForAllowingChangeMode:(long )segmentindex{
    
    [self showAlertWithTitle:@""
                     message:@"The Photo has been taken ! Continue to change another Mode ?"
           cancelButtonTitle:@"Cancel"
               cancelHandler:^(UIAlertAction * _Nonnull action) {
        
        self.segmentControl.selectedSegmentIndex = self.currentSegmentIndex;
        
    }
               okButtonTitle:@"OK"
                   okHandler:^(UIAlertAction * _Nonnull action) {
        self.continueToTakePhoto = true;
        self.segmentControl.selectedSegmentIndex = segmentindex;
        [self.segmentControl sendActionsForControlEvents:UIControlEventValueChanged];
        
    }];
}


- (void)popUpForAllowingSwtichAutoExposure:(BOOL )switchOn{
    
    [self showAlertWithTitle:@""
                     message:@"The Photo has been taken ! Continue to change another Mode ?"
           cancelButtonTitle:@"Cancel"
               cancelHandler:^(UIAlertAction * _Nonnull action) {
        
      
        
    }
               okButtonTitle:@"OK"
                   okHandler:^(UIAlertAction * _Nonnull action) {
        self.continueToTakePhoto = true;
        if(switchOn){
            [self.switchBtn setOn:YES animated:YES];
            
        }else {
            [self.switchBtn setOn:NO animated:NO];
        }
        [self setExposure:self];
        

        
    }];
}





- (void)popUpForUpdateServer:(NSString *) msg mode:(NSString *) imode action:(NSString *) requireAction{
    
    [self showAlertWithTitle:@""
                     message:msg
           cancelButtonTitle:@"Cancel"
               cancelHandler:^(UIAlertAction * _Nonnull action) {
        self.segmentControl.selectedSegmentIndex = self.currentSegmentIndex;
        
    }
               okButtonTitle:@"OK"
                   okHandler:^(UIAlertAction * _Nonnull action) {
        
        [self performSelectorInBackground:@selector(executeUpdateExposureInServer:) withObject:imode];
        [SVProgressHUD show];
        
        
    }];
    
}


-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration   andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToDissolve.alpha = 0.0;
    [UIView commitAnimations];
}


-(void) fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait

{
    [UIView beginAnimations: @"Fade In" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = 1;
    
    [UIView commitAnimations];
    
}


- (BOOL)checkIfHaveTakenPhoto {
    
    bool hasTakenPhoto = false;
    
    if (self.leftImageView.image != nil) {
        hasTakenPhoto = true;
    } else if (self.hLeftImageView.image != nil) {
        hasTakenPhoto = true;
    } else if (self.frontImageView.image != nil) {
        hasTakenPhoto = true;
    } else if (self.hRightImageView.image != nil) {
        hasTakenPhoto = true;
    } else if (self.rightImageView.image != nil) {
        hasTakenPhoto = true;
    } else if (self.videoImageView.image != nil) {
        hasTakenPhoto = true;
    } else if(self.currentIndex == 5){
        hasTakenPhoto = true;
    }
    
    return hasTakenPhoto;
    
}


- (int)getNumOfPhotoAndDisableSwitch {
    
    int numberOfPhoto = 0;
    
    if (self.leftImageView.image != nil) {
        numberOfPhoto++;
    }
    if (self.hLeftImageView.image != nil) {
        numberOfPhoto++;
    }
    
    if (self.hRightImageView.image != nil) {
        numberOfPhoto++;
    }
    
    if (self.rightImageView.image != nil) {
        numberOfPhoto++;
    }
    
    if (self.frontImageView.image != nil) {
        numberOfPhoto++;
    }
    if (self.videoImageView.image != nil) {
        numberOfPhoto++;
    }
    
   
    if(numberOfPhoto >=1){
        self.switchBtn.enabled = NO;
        self.segmentControl.enabled=NO;
    }else {
        self.switchBtn.enabled = YES;
        self.segmentControl.enabled=YES;
    }
    
    return numberOfPhoto;
    
}


typedef struct {
    float redGain;
    float greenGain;
    float blueGain;
    float iso;
} isoSetting;

@end
