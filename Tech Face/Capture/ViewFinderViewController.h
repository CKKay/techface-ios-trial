//
//  ViewFinderViewController.h
//  Tech Face
//
//  Created by John on 2019-6-29.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewFinderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *btnManualCapture;
@property (strong, nonatomic) NSString *calltype;

@property (weak, nonatomic) IBOutlet UILabel *labelLeft;
@property (weak, nonatomic) IBOutlet UILabel *labelHalfLeft;
@property (weak, nonatomic) IBOutlet UILabel *labelFront;
@property (weak, nonatomic) IBOutlet UILabel *labelHalfRight;
@property (weak, nonatomic) IBOutlet UILabel *labelRight;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hLeftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hRightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

@property (nonatomic, assign) BOOL isTesting;

- (void)startCameraSession;
- (void)stopCameraSession;
- (void)stopVideoSession;
- (void)clearImage;

- (void)doCaptureAction;

@end

NS_ASSUME_NONNULL_END
