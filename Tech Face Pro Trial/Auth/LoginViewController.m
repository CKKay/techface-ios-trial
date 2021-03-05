//
//  LoginViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;

@end

@implementation LoginViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	 self.modalInPresentation =YES;
	[SVProgressHUD show];
	[SVProgressHUD dismiss];

#ifdef SERVER_HEROKU
	// Development only
	self.emailTextField.text = @"";
	self.pwdTextField.text = @"";
#else
	self.emailTextField.text = @"";
	self.pwdTextField.text = @"";
#endif
    self.emailTextField.backgroundColor = UIColor.whiteColor;
    self.pwdTextField.backgroundColor = UIColor.whiteColor;
     
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if ([[[defaults dictionaryRepresentation] allKeys] containsObject:@"signincheck"]) {
		NSString *savedValue = [defaults objectForKey:@"signincheck"];
        NSString *logout = [defaults objectForKey:@"logout"];
        
		if ([savedValue isEqualToString:@"Loggedin"] && [logout isEqualToString:@"N"]  ) {
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			UITabBarController *view = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
			[self presentViewController:view animated:true completion:nil];
		}
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigations

- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue {
	// Do nothing
}

- (IBAction)registerUser:(id)sender {
    NSString *data;
    NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSURL *url = [Server websiteurl:@"/custregister?duid=%@",uniqueIdentifier];
    UIApplication *application = [UIApplication sharedApplication];
    
    [application openURL:url options:@{} completionHandler:^(BOOL success){
        if(success){
            
        }
        
    }];
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

- (IBAction)signInAction:(id)sender {
	NSString *email = [self.emailTextField.text trim];
	self.emailTextField.text = email;
	NSString *pwd = [self.pwdTextField.text trim];
	if ([NSString isEmpty:email] || [NSString isEmpty:pwd]) {
		[ToastView showToastInParentView:self.view withText:@"All required fields Require" withDuaration:1.0];
		return;
	}

	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
		[self showDismissAlertWithTitle:@"Oops !!"
								message:@"Internet Is not avalible"];
		return;
	}

	[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig:) withObject:@[email, pwd]];
	DLog(@"IS REACHABILE");
	[SVProgressHUD show];
}

- (void)executeInBackgroundHomeconfig:(NSArray *)args {
	DLog(@"executeInBackground");
	NSString *email = args[0];
	NSString *pwd = args[1];
	[self LoginCallWithEmail:email password:pwd];
}

- (void)LoginCallWithEmail:(NSString *)email password:(NSString *)password {
	NSURL *url = [Server url:@"/techface_api/login?email=%@&password=%@&trial=Y", email, password];
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
										  DLog(@"Respose : %@", response);
										  DLog(@"Data : %@", data);
										  DLog(@"Error : %@", error);
										  DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
										  NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  NSString *ad = [s objectForKey:@"message"];
										  NSDictionary *homedata = [s objectForKey:@"data"];
                                          NSString *upload_data_limit = [homedata valueForKeyPath:@"upload_data_limit"];
                                      
										  // DLog(@"%@", ad);
										  DLog(@"%@", homedata);
										  if ([ad isEqualToString:@"Login Successfully"]) {
											  [SVProgressHUD dismiss];
											  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
											  [userDefaults setObject:homedata forKey:@"homedata"];
											  [userDefaults setObject:@"Loggedin" forKey:@"signincheck"];
                                              [userDefaults setObject:@"N" forKey:@"logout"];
                                              [userDefaults setObject:upload_data_limit forKey:@"upload_data_limit"];
											  [userDefaults synchronize];
											  [self performSelectorOnMainThread:@selector(executeInMain:) withObject:ad waitUntilDone:true];
										  } else {
											  [SVProgressHUD dismiss];
                                              [self performSelectorOnMainThread:@selector(executeInMain:) withObject:ad waitUntilDone:true];
										  }
									  }];
	[dataTask resume];
   
}

- (void)executeInMain:(NSString *)aString; {
	if ([aString isEqualToString:@"Login Successfully"]) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		UITabBarController *view = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
		[self presentViewController:view animated:true completion:nil];
    }else {
        
        [self showDismissAlertWithTitle:@"Login fail !!" message:aString];
    }
}

@end
