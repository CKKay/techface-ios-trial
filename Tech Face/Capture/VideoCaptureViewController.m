//
//  VideoCaptureViewController.m
//  Tech Face
//
//  Created by MedEXO on 13/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "VideoCaptureViewController.h"
#import "BDCamera.h"
#import "BDVideoCameraView.h"
#import "Server.h"
#import "NSString+Extended.h"

@import AssetsLibrary;
@import AVFoundation;
@import AVKit;

@interface VideoCaptureViewController ()<BDVideoCameraViewDelegate>

@property (nonatomic, strong) BDCamera *camera;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet BDVideoCameraView *videoCameraView;

@end

@implementation VideoCaptureViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.videoCameraView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    
    NSLog(@"Video Capture Viuew Controller dealloc Warning");
	
    
      if ([self isViewLoaded] && [self.view window] == nil) {
  
    
      }
    [super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
	//   NSString* path = [NSString fullPathOfUserDocumentWithName:@"1.mov" ];
	//    NSURL *movieURL = [NSURL fileURLWithPath:path];
	//  DLog(@"%@", movieURL);
	//   [self.camera startRecordingWithURL:movieURL];
	if (self.videoCameraView.isRecorning == false) {
		[self.videoCameraView startRecording];
		[self.start setImage:[UIImage imageNamed:@"videobutton"] forState:UIControlStateNormal];
	} else {
		[self.videoCameraView stopRecording];
		[self.start setImage:[UIImage imageNamed:@"camerabutton"] forState:UIControlStateNormal];
	}
	// camerabutton
}

#pragma mark - BDVideoCameraViewDelegate -
- (void)finishRecordningVideoForURL:(NSURL *)url {
	DLog(@"%@", url.absoluteString);
	[self showSuccessAlert];
}

- (void)showSuccessAlert {
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your video saved to your library" delegate:nil cancelButtonTitle:@"Good job" otherButtonTitles:nil];
//	[alert show];
	NSString *getPath = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:getPath]) {
		DLog(@"exist");
	} else {
		DLog(@"not exist");
	}
	NSURL *videoURL = [NSURL fileURLWithPath:getPath];
	// create an AVPlayer
	AVPlayer *player = [AVPlayer playerWithURL:videoURL];
	// create a player view controller
	AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
	controller.player = player;
	[player play];
	[self presentViewController:controller animated:true completion:nil];
	controller.view.frame = self.view.frame;
	[controller.player play];
}


- (void) dealloc
{
 DLog(@"Video Capture Viuew Controller dealloc process");

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
