//
//  ConnectDeviceViewController.m
//  Tech Face
//
//  Created by MedEXO on 08/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ConnectDeviceViewController.h"
#import "CaptureViewController.h"

@import UIKit;

@interface ConnectDeviceViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation ConnectDeviceViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.statusLabel.text = @"Disconnected";
	[self.indicatorView stopAnimating];
}

- (void)didReceiveMemoryWarning {
          NSLog(@"Capture View controller dealloc Warning");

      if ([self isViewLoaded] && [self.view window] == nil) {
        //  self.parentVC.viewFinderVC=nil;
         // self.view = nil;
    
      }
     [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CaptureViewController *)parentVC {
	return (CaptureViewController *)self.parentViewController;
}

- (IBAction)connectAction:(id)sender {
	self.connectButton.enabled = false;
	self.indicatorView.hidden = false;
	[self.indicatorView startAnimating];
	self.statusLabel.text = @"Searching...";
    self.parentVC.viewFinderVC.isTesting = false;
    self.parentVC.viewFinderVC.labelLeft.text = @"Left";
    self.parentVC.viewFinderVC.labelHalfLeft.text = @"Half Left";
    self.parentVC.viewFinderVC.labelFront.text = @"Front";
    self.parentVC.viewFinderVC.labelHalfRight.text = @"Half Right";
    self.parentVC.viewFinderVC.labelRight.text = @"Right";
    self.parentVC.viewFinderVC.btnManualCapture.hidden = true;
    self.parentVC.viewFinderVC.startButton.hidden = false;
	[self.parentVC connectBluno];
}

- (IBAction)connectWithoutEquipmentAction:(id)sender {
    self.parentVC.connectView.hidden = true;
    self.parentVC.finderView.hidden = false;
    self.parentVC.viewFinderVC.isTesting = true;
    self.parentVC.viewFinderVC.labelLeft.text = @"Left";
    self.parentVC.viewFinderVC.labelHalfLeft.text = @"Half Left";
    self.parentVC.viewFinderVC.labelFront.text = @"Front";
    self.parentVC.viewFinderVC.labelHalfRight.text = @"Half Right";
    self.parentVC.viewFinderVC.labelRight.text = @"Right";
    self.parentVC.viewFinderVC.startButton.hidden = true;
    [self.parentVC.viewFinderVC startCameraSession];
    self.parentVC.skipButton.enabled = true;
}

-(void)didDiscoverDevice {
	self.statusLabel.text = @"Connecting...";
}

-(void)didConnectedDevice {
	self.statusLabel.text = @"Connected to Equipment";
	[self.indicatorView stopAnimating];
    self.parentVC.skipButton.enabled = true;
}

-(void)didDisconnectDevice {
	self.statusLabel.text = @"Disconnected";
	self.connectButton.enabled = true;
    self.parentVC.skipButton.enabled = false;
}

- (void) dealloc
{
 NSLog(@"Capture View controller dealloc process");

}


@end
