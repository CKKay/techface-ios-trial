//
//  PractitionerFormViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "PractitionerFormViewController.h"
#import "HomeViewController.h"
#import "PractitionerInfoViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSData+Extended.h"
#import "NSDate+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PractitionerFormViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *AddProfilepic;

@end

@implementation PractitionerFormViewController

UIImage *profileimage;

- (void)viewDidLoad {
	[super viewDidLoad];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Do any additional setup after loading the view.
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	[datePicker setDate:[NSDate date]];
	datePicker.datePickerMode = UIDatePickerModeDate;
	[datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
	[self.birth setInputView:datePicker];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)updateTextField:(id)sender {
	UIDatePicker *picker = (UIDatePicker *)self.birth.inputView;
	NSString *theDate = [[NSDateFormatter shortDateFormatter] stringFromDate:picker.date];
	self.birth.text = theDate;
}

bool pract_picselected = false;

#pragma mark - Actions

- (IBAction)AddPractPhoto:(id)sender {
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
		if ([emailTest evaluateWithObject:self.email.text] == true) {
			//Do Something
			if (![NSString isEmpty:self.username.text] && ![NSString isEmpty:self.email.text]  && ![NSString isEmpty:self.password.text] && ![NSString isEmpty:self.conformapassword.text] && ![NSString isEmpty:self.phone.text] && ![NSString isEmpty:self.birth.text] && ![NSString isEmpty:self.city.text] && ![NSString isEmpty:self.district.text] && ![NSString isEmpty:self.country.text] && ![NSString isEmpty:self.profession.text] && pract_picselected) {
				DLog(@"sucessfully");
				/*
				 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
				 
				 PractitionerInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"viewPractitioners"];
				 
				 vc.pract_theImage =  self.profilepic.image;
				 vc.s_pract_username =  self.username.text;
				 vc.s_pract_email =  self.email.text;
				 vc.s_pract_password =  self.password.text;
				 vc.s_pract_phone =  self.phone.text;
				 vc.s_pract_birth =  self.birth.text;
				 vc.s_pract_country =  self.country.text;
				 vc.s_pract_city =  self.city.text;
				 vc.s_pract_district =  self.district.text;
				 vc.s_pract_profession =  self.profession.text;
				 
				 
				 [self presentViewController:vc animated:true completion:nil];
				 
				 
				 [ToastView showToastInParentView:self.view withText:@"Sucessfully" withDuaration:1.0];
				 
				 */
				// Do save directly without confirm
				[self BackGroundProcess];
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
	pract_picselected = true;
}

#pragma mark -

- (void)BackGroundProcess {
	if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
		[self showAlertWithTitle:@"Oops !!"
						 message:@"Internet Is not avalible"
			   cancelButtonTitle:@"Quit App"
				   cancelHandler:^(UIAlertAction * _Nonnull action) {
					   exit(0);
				   }
				   okButtonTitle:@"Retry"
					   okHandler:^(UIAlertAction * _Nonnull action) {
						   [self BackGroundProcess];
					   }];
		DLog(@"NOT REACHABLE");
	} else {
		[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
		profileimage = self.profilepic.image;
		DLog(@"IS REACHABILE");
		[SVProgressHUD show];
	}
}

- (void)executeInBackgroundHomeconfig {
	DLog(@"executeInBackground");
	[self sendImageToServer];
}

- (void)sendImageToServer {
	NSDictionary *myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"homedata"];
	NSString *proffession = self.profession.text;
	proffession = [proffession stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	proffession = [proffession stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSURL *url = [Server url:@"/techface_api/createPractitioner?email=%@&password=%@&username=%@&phone=%@&birth=%@&profession=%@&country=%@&city=%@&district=%@&company_id=%@&first_name=%@&last_name=%@", self.email.text, self.password.text, self.username.text, self.phone.text, self.birth.text, proffession, self.country.text, self.city.text, self.district.text, [myDictionary valueForKeyPath:@"vw_company_id"], self.username.text, self.username.text];
	DLog(@"%@", url.absoluteString);
	DLog(@"1");
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	NSData *imageData = UIImageJPEGRepresentation(profileimage, 0.5);
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:false];
	[request setTimeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"unique-consistent-string";
	// set Content-Type in HTTP header
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
   forHTTPHeaderField:@"Content-Type"];
	// post body
	DLog(@"Building request body");
	NSMutableData *body = [NSMutableData data];
	// add params (all params are strings)
	[body appendStringWithFormat:@"--%@\r\n", boundary];
	[body appendStringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"];
	[body appendStringWithFormat:@"%@\r\n", @"Some Caption"];
	// add image data
	if (imageData) {
		[body appendStringWithFormat:@"--%@\r\n", boundary];
		[body appendStringWithFormat:@"Content-Disposition: form-data; name=%@; filename=practitionarsprofilepic.jpg\r\n", @"practitionarsprofilepic"];
		[body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
		[body appendData:imageData];
		[body appendStringWithFormat:@"\r\n"];
	}
	DLog(@"Set boundary of body");
	[body appendStringWithFormat:@"--%@--\r\n", boundary];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	// set the content-length
	[request setValue:[@(body.length) stringValue] forHTTPHeaderField:@"Content-Length"];
	DLog(@"Content-Length: %lu", (unsigned long)[body length]);
	DLog(@"request : %@", request);
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask;
	dataTask = [session dataTaskWithRequest:request
						  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
				{
					DLog(@"Respose : %@", response);
					DLog(@"Data : %@", data);
					DLog(@"Error : %@", error);
					DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
					DLog(@"Error : %@", [error localizedDescription]);
					// NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					//  DLog(myString);
					//  NSString *myStr = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
					@try {
						NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
						NSString *ad = [s objectForKey:@"message"];
						NSString *homedata = [s objectForKey:@"data"];
						DLog(@"%@", ad);
						if ([ad isEqualToString:@"Practitioner Registered"]) {
							[SVProgressHUD dismiss];
							[self performSelectorOnMainThread:@selector(executeInMain:) withObject:homedata waitUntilDone:true];
						} else if ([ad isEqualToString:@"User All Ready Registered"]) {
							[SVProgressHUD dismiss];
							[self showDismissAlertWithTitle:@"Try again!" message:@"User already registered."];
						}
					} @catch (NSException *theErr) {
						DLog(@"The exception is:\n name: %@\nreason: %@"
							 , [theErr name], [theErr reason]);
					}
				}];
	[dataTask resume];
 
	DLog(@"5");
}

- (void)executeInMain:(NSString *)aString; {
	[self dismissViewControllerAnimated:true completion:^{
		DLog(@"Dismiss completed");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"pushToSingle" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:100] forKey:@"post_id"]];
	}];
}

@end
