//
//  CompanyUserFormViewController.m
//  Tech Face
//
//  Created by MedEXO on 20/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "CompanyUserFormViewController.h"
#import "Reachability.h"
#import "ToastView.h"
#import "Server.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define registerurl @"https://raw.githubusercontent.com/topbestapps/yorise/master/ipsv2.5"

@interface CompanyUserFormViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *Addprofilepic;

@end

@implementation CompanyUserFormViewController

bool picselected = false;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)pickAvatarAction:(id)sender {
	/*
	 
	 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	 picker.delegate = self;
	 picker.allowsEditing = true;
	 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	 [self presentViewController:picker animated:true completion:nil];
	 
	 */
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = true;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:picker animated:true completion:nil];
}

- (IBAction)nextAction:(id)sender {
	if ([self.password.text isEqual:self.conformapassword.text]) {
		NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
		NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
		//Valid email address
		if ([emailTest evaluateWithObject:self.com_email.text] == true) {
			if (![NSString isEmpty:self.Companyname.text] && ![NSString isEmpty:self.Username.text] && ![NSString isEmpty:self.com_email.text] && ![NSString isEmpty:self.Username.text] && ![NSString isEmpty:self.token.text] && ![NSString isEmpty:self.country.text] && ![NSString isEmpty:self.city.text] && ![NSString isEmpty:self.district.text] && ![NSString isEmpty:self.service.text] && ![NSString isEmpty:self.password.text] && ![NSString isEmpty:self.conformapassword.text] && picselected) {
				DLog(@"sucessfully");
				[self.parentViewController performSegueWithIdentifier:@"Show Confirm" sender:self];
			} else {
				[ToastView showToastInParentView:self.view withText:@"All required fields Require" withDuaration:1.0];
				DLog(@"Not sucessfully");
			}
		} else {
			DLog(@"email not in proper format");
			[ToastView showToastInParentView:self.view withText:@"Email not in proper format" withDuaration:1.0];
		}
	} else {
		[ToastView showToastInParentView:self.view withText:@"Password Not Match" withDuaration:1.0];
		DLog(@"Password not match try again");
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// output image
	UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
	self.profilepic.image = chosenImage;
	[picker dismissViewControllerAnimated:true completion:nil];
	picselected = true;
}

#pragma mark -

- (void)BackGroundProces {
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
		[self showDismissAlertWithTitle:@"Oops !!"
								message:@"Internet Is not avalible"];
	} else {
		[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
		DLog(@"IS REACHABILE");
		[SVProgressHUD show];
	}
}

- (void)executeInBackgroundHomeconfig {
	DLog(@"executeInBackground");
	[self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:false];
}

- (void)executeInMain {
	[SVProgressHUD dismiss];
}

@end
