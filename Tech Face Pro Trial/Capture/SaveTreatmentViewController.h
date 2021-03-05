//
//  SaveTreatmentViewController.h
//  Tech Face
//
//  Created by MedEXO on 18/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ConnectDeviceViewController.h"
#import "ViewFinderViewController.h"

@import UIKit;
#import "TreatmentTypeViewController.h"


@interface SaveTreatmentViewController : UIViewController

@property (nonatomic, assign) BOOL isManualCapture;
@property (weak, nonatomic) ConnectDeviceViewController *connectDeviceVC;
@property (weak, nonatomic) ViewFinderViewController *viewFinderVC;
@property (strong, nonatomic) NSMutableDictionary *arrMultiTreatmentTypes;
- (void) updateMultiTreatment:(NSString *)tid :(NSString *)value;


@end
