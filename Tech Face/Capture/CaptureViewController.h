//
//  CaptureViewController.h
//  Tech Face
//
//  Created by MedEXO on 13/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "DFBlunoManager+Extended.h"
#import "ConnectDeviceViewController.h"
#import "ViewFinderViewController.h"

@import UIKit;

@interface CaptureViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *ConfromPicView;
@property (weak, nonatomic) IBOutlet UIView *connectView;
@property (weak, nonatomic) IBOutlet UIView *finderView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *skipButton;
@property (weak, nonatomic) ConnectDeviceViewController *connectDeviceVC;
@property (weak, nonatomic) ViewFinderViewController *viewFinderVC;

- (void)connectBluno;
- (BOOL)writeMessageToBluno:(int)message;
- (void)sendMessageToBluno:(NSString *)message;

@end
