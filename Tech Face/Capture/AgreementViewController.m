//
//  AgrementViewController.m
//  Tech Face
//
//  Created by MedEXO on 12/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "Server.h"
#import "AgreementViewController.h"
#import "ConfirmAgreementViewController.h"
#import "UIImage+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

@import AVFoundation;

@interface AgreementViewController () <AVCapturePhotoCaptureDelegate>

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIView *confirmView;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCapturePhotoOutput *photoOutput;

@property (weak, nonatomic) ConfirmAgreementViewController *confirmVC;

@end

@implementation AgreementViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self hideAllViews];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    [self checkCreditRemain];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {

   NSLog(@"Capture Agreement dealloc Warning");


     if ([self isViewLoaded] && [self.view window] == nil) {
         /*
        [self.captureSession stopRunning];
         
        [self.cameraView removeFromSuperview];
        [self.confirmView removeFromSuperview];
        [self.previewView removeFromSuperview];

        self.cameraView = nil;
        self.captureSession=nil;
        self.confirmView = nil;
        self.previewView = nil;
        self.previewLayer=nil;
        self.photoOutput=nil;
        self.view = nil;*/
     }
    [super didReceiveMemoryWarning];
    
   
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Embed Confirm"]) {
		self.confirmVC = segue.destinationViewController;
	}
	if ([segue.identifier isEqualToString:@"Start Capture"]) {
		[self hideAllViews];
	}
}
#pragma mark - Actions

- (IBAction)dismissAction:(id)sender {
	if (self.confirmView.hidden) {
		[self doDismiss];
		return;
	}
	[self showAlertWithTitle:@"Discard?" message:@"Discard current progress and back to client selection screen." cancelButtonTitle:@"Later" cancelHandler:nil destructiveTitle:@"Discard" destructiveHandler:^(UIAlertAction * _Nonnull action) {
		[self doDismiss];
	}];
}

- (void)doDismiss {
	self.trashButton.enabled = false;
    UIViewController *vc = self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
	[vc dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)captureAction:(id)sender {
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

- (IBAction)skipAction:(id)sender {
    [self showAlertWithTitle:@"Confirm?" message:@"Are you agree to skip for taking agreement?" cancelButtonTitle:@"No" cancelHandler:nil destructiveTitle:@"Yes" destructiveHandler:^(UIAlertAction * _Nonnull action) {
        [self doSkipAction];
    }];
}

- (IBAction)discardAction:(id)sender {
	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:nil
								message:@"This image will be discarded."
								preferredStyle:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:@"Keep it"
											  style:UIAlertActionStyleCancel
											handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Discard"
											  style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction * _Nonnull action) {
												[self doDiscardAction];
											}]];
	if (alert.popoverPresentationController) { // For iPad
		UIBarButtonItem *view = (UIBarButtonItem *)sender;
		alert.popoverPresentationController.barButtonItem = view;
	}
	[self presentViewController:alert animated:true completion:nil];
}

- (void)doSkipAction {
    [[UIImage imageNamed:@"no_agreement.jpg"] saveInDocumentAsName:@"t_agreement.jpg" withQuality:0.5];
    [self performSegueWithIdentifier:@"Start Capture" sender:self];
}

- (void)doDiscardAction {
	[self showCameraView];
}

#pragma mark - Camera

- (void)startCameraSession {
	self.cameraView.hidden = false;
	self.captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (device) {
        /*
            [device lockForConfiguration:nil];
            [device setExposureMode:AVCaptureExposureModeLocked];
            [device unlockForConfiguration];*/
        [device lockForConfiguration:nil];
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        
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
			self.photoOutput = [[AVCapturePhotoOutput alloc] init];
			if ([self.captureSession canAddOutput:self.photoOutput]) {
				[self.captureSession addOutput:self.photoOutput];
				[self.captureSession startRunning];
			}
		}
	}
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
	if (error) {
		[self showDismissAlertWithTitle:@"Error occurred" message:@"Please retry again."];
		return;
	}
	NSData *data = [photo fileDataRepresentation];
	if (!data) {
		[self showDismissAlertWithTitle:@"No data" message:@"Please retry again."];
		return;
	}
	NSString *name = @"t_agreement.jpg";
	[[[UIImage alloc] initWithData:data] saveInDocumentAsName:name withQuality:0.7];
	[self showConfirmViewWithImage:[UIImage imageInDocumentWithName:name]];
    data=nil;
}

#pragma mark - Helpers

- (void)hideAllViews {
	self.cameraView.hidden = true;
	self.confirmView.hidden = true;
	self.trashButton.enabled = false;
}

- (void)showCameraView {
	self.cameraView.hidden = false;
	self.confirmView.hidden = true;
	self.trashButton.enabled = false;
	[self.confirmVC reset];
}

- (void)showConfirmViewWithImage:(UIImage *)image {
	self.confirmVC.imageView.image = image;
	self.cameraView.hidden = true;
	self.confirmView.hidden = false;
	self.trashButton.enabled = true;
}

- (void)checkCreditRemain {
    [self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
}

- (void)executeInBackgroundHomeconfig {
    [SVProgressHUD show];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *practitionerId = [userDefaults objectForKey:@"selected_pract_id"];
    NSURL *url = [Server url:@"/techface_api/checkHasCredit?pract_id=%@", practitionerId];
    DLog(@"%@", url.absoluteString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          [SVProgressHUD dismiss];
                                          NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                          [self performSelectorOnMainThread:@selector(executeInMain:) withObject:s waitUntilDone:true];
                                      }];
    [dataTask resume];
   
}

- (void)executeInMain:(NSDictionary *)s; {
    NSNumber *hasCredit = [s objectForKey:@"hasCredit"];
    NSString *msg = [s objectForKey:@"message"];
    if ([hasCredit intValue] > 0) {
        [self startCameraSession];
    } else {
        [self showDismissAlertWithTitle:nil message:msg];
        [self hideAllViews];
    }
}

- (void) dealloc
{
    //[observer unregisterObject:self];
   //  [observer unregisterObject:self];
    DLog(@"Capture Agreement dealloc process");
//    [super dealloc]; //(provided by the compiler)
}


@end
