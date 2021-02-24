//
//  ConnectDeviceViewController.h
//  Tech Face
//
//  Created by MedEXO on 08/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

@import UIKit;

@interface ConnectDeviceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

- (void)didDiscoverDevice;
- (void)didConnectedDevice;
- (void)didDisconnectDevice;

@end
