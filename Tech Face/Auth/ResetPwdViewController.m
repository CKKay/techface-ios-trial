//
//  ResetPwdViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ResetPwdViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation ResetPwdViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Turn navigation bar to transparent
	[self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
	self.navigationBar.shadowImage = [[UIImage alloc] init];
	self.navigationBar.translucent = true;
	self.navigationBar.backgroundColor = UIColor.clearColor;
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.emailTextField) {
		textField.text = [textField.text trim];
	}
	return true;
}

#pragma mark - Actions

- (IBAction)submitAction:(id)sender {
	NSString *email = [self.emailTextField.text trim];
	self.emailTextField.text = email;
	if ([NSString isEmpty:email]) {
		[ToastView showToastInParentView:self.view withText:@"All required fields Require" withDuaration:1.0];
		return;
	}

	if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
		[self showDismissAlertWithTitle:@"Oops !!"
								message:@"Internet Is not avalible"];
		return;
	}

	[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig:) withObject:email];
	[SVProgressHUD show];
}

- (void)executeInBackgroundHomeconfig:(NSString *)email {
	DLog(@"executeInBackground");
	[self ForgotCallWithEmail:email];
}

- (void)ForgotCallWithEmail:(NSString *)email {
	NSURL *url = [Server url:@"/techface_api/forget_password?email=%@", email];
	DLog(@"%@", url.absoluteString);
	// Init the URLRequest
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"POST"];
	[request setURL:url];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	//[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
									  {
										  //DLog(@"Respose : %@", response);
										  //DLog(@"Data : %@", data);
										  //DLog(@"Error : %@", error);
										  DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
										  NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  NSString *ad = [s objectForKey:@"message"];
										  DLog(@"%@", ad);
										  if ([ad isEqualToString:@"Please check your email"]) {
											  [SVProgressHUD dismiss];
											  [ToastView showToastInParentView:self.view withText:ad withDuaration:1.0];
											  [self performSelectorOnMainThread:@selector(executeInMain:) withObject:ad waitUntilDone:true];
										  } else {
											  [SVProgressHUD dismiss];
											  [ToastView showToastInParentView:self.view withText:ad withDuaration:1.0];
										  }
									  }];
	[dataTask resume];
   
}

- (void)executeInMain:(NSString *)aString; {
	if ([aString isEqualToString:@"Please check your email"]) {
		[self dismissViewControllerAnimated:true completion:nil];
	}
}

@end
