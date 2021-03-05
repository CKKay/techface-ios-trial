//
//  ConfirmAgreementViewController.m
//  Tech Face
//
//  Created by John on 2019-6-29.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "ConfirmAgreementViewController.h"
#import "UIViewController+Extended.h"

@interface ConfirmAgreementViewController ()

@property (weak, nonatomic) IBOutlet UIButton *checkbox;

@property (assign, nonatomic) bool userAgreed;

@end

@implementation ConfirmAgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.userAgreed = false;
}

- (void)didReceiveMemoryWarning {
    
    NSLog(@"Capture Agreement dealloc Warning");
    [super didReceiveMemoryWarning];
   
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

- (IBAction)checkboxAction:(id)sender {
	self.userAgreed = !self.userAgreed;
}

- (void)setUserAgreed:(bool)userAgreed {
	_userAgreed = userAgreed;
	NSString *name = userAgreed ? @"checked_checkbox" : @"unchecked_checkbox";
	[self.checkbox setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
}

- (IBAction)nextAction:(id)sender {
	if (!self.userAgreed) {
		[self showDismissAlertWithTitle:@"Missing agreement"
								message:@"Client must agree with the terms and conditions."];
		return;
	}
    self.userAgreed = false;
	[self.parentViewController performSegueWithIdentifier:@"Start Capture" sender:self];
}

- (void)reset {
	self.userAgreed = false;
	self.imageView.image = nil;
}

- (void) dealloc
{

    //DLog(@"Capture Agreement dealloc");
    NSLog(@"Capture Agreement dealloc process");

}


@end
