//
//  CompanyUserInfoViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "CompanyUserInfoViewController.h"
#import "ConfirmCompanyUserViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSData+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CompanyUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *companyname;
@property (weak, nonatomic) IBOutlet UILabel *usename;
@property (weak, nonatomic) IBOutlet UILabel *emailid;
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UILabel *token;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *deistrict;
@property (weak, nonatomic) IBOutlet UILabel *service;
@property (weak, nonatomic) IBOutlet UIButton *save;

@end

@implementation CompanyUserInfoViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// Do any additional setup after loading the view.
	ConfirmCompanyUserViewController *parent = (ConfirmCompanyUserViewController *)self.parentViewController;
	if (parent.theImage != nil) {
		self.profilepic.image = parent.theImage;
		self.companyname.text = parent.s_companyname;
		self.usename.text = parent.s_username;
		self.emailid.text = parent.s_email;
		self.country.text = parent.s_country;
		self.token.text = parent.s_token;
		self.city.text = parent.s_city;
		self.deistrict.text = parent.s_district;
		self.service.text = parent.s_service;
	} else {
		DLog(@"null");
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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

- (IBAction)save:(id)sender {
	[self BackGroundProcess];
}

- (void)BackGroundProcess {
	if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
		[self showDismissAlertWithTitle:@"Oops !!"
								message:@"Internet Is not avalible"];
		DLog(@"NOT REACHABLE");
		return;
	}
	[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
	DLog(@"IS REACHABILE");
	[SVProgressHUD show];
}

- (void)executeInBackgroundHomeconfig {
	DLog(@"executeInBackground");
	[self sendImageToServer];
}

- (void)sendImageToServer {
	ConfirmCompanyUserViewController *parent = (ConfirmCompanyUserViewController *)self.parentViewController;
	NSString *service = self.service.text;
	service = [service stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	service = [service stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSURL *url = [Server url:@"/techface_api/createcompanyuser?email=%@&password=%@&username=%@&avatar=%s&company_name=%@&service=%@&country=%@&city=%@&district=%@&treatment_quota=%s&token_id=%@", self.emailid.text, parent.s_password, self.usename.text, "", self.companyname.text, service, self.country.text, self.city.text, self.deistrict.text, "10", self.token.text];
	DLog(@"%@", url.absoluteString);
	DLog(@"1");
	/*
	 UIImage *yourImage= self.theImage;
	 NSData *imageData = UIImagePNGRepresentation(yourImage) ;
	 //  [imageData setObject:yourImage forKey:@"avatar"];
	 // [imageData set];
	 //[imageData setValue:yourImage forKey:@"avatar"];
	 
	 NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[imageData length]];
	 
	 // Init the URLRequest
	 NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	 [request setHTTPMethod:@"POST"];
	 [request setURL:url];
	 [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	 [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	 
	 NSString *boundary = @"unique-consistent-string";
	 
	 NSMutableData *body = [NSMutableData data];
	 
	 // add params (all params are strings)
	 [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	 [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"]];
	 [body appendString:[NSString stringWithFormat:@"%@\r\n", @"Some Caption"]];
	 
	 // add image data
	 if (imageData) {
	 [body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	 [body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=imageName.jpg\r\n", @"avatar"]];
	 [body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
	 [body appendData:imageData];
	 [body appendString:[NSString stringWithFormat:@"\r\n"]];
	 DLog(@"call");
	 
	 }
	 
	 [body appendString:[NSString stringWithFormat:@"--%@--\r\n", boundary]];
	 [request setHTTPBody:body];
	 
	 NSURLSession *session = [NSURLSession sharedSession];
	 NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
	 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
	 {
	 DLog(@"Respose : %@", response);
	 DLog(@"Data : %@", data);
	 DLog(@"Error : %@", error);
	 }];
	 [dataTask resume];
	 
	 */
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	NSData *imageData = UIImageJPEGRepresentation(parent.theImage, 0.5);
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:false];
	[request setTimeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"unique-consistent-string";
	// set Content-Type in HTTP header
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	// post body
	DLog(@"2");
	NSMutableData *body = [NSMutableData data];
	// add params (all params are strings)
	[body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
	[body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"]];
	[body appendString:[NSString stringWithFormat:@"%@\r\n", @"Some Caption"]];
	// add image data
	if (imageData) {
		[body appendString:[NSString stringWithFormat:@"--%@\r\n", boundary]];
		[body appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=profilepic.jpg\r\n", @"avatar"]];
		[body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
		[body appendData:imageData];
		[body appendString:[NSString stringWithFormat:@"\r\n"]];
	}
	DLog(@"3");
	[body appendString:[NSString stringWithFormat:@"--%@--\r\n", boundary]];
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	// set the content-length
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	DLog(@"4");
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
									  {
										  DLog(@"Respose : %@", response);
										  DLog(@"Data : %@", data);
										  DLog(@"Error : %@", error);
										  DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
										  // NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  //  DLog(myString);
										  //  NSString *myStr = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
										  NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  NSString *ad = [s objectForKey:@"message"];
										  NSString *homedata = [s objectForKey:@"data"];
										  DLog(@"%@", ad);
										  if ([ad isEqualToString:@"New User Registered"]) {
											  [SVProgressHUD dismiss];
											  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
											  [userDefaults setObject:homedata forKey:@"homedata"];
											  [userDefaults setObject:@"Loggedin" forKey:@"signincheck"];
											  [userDefaults synchronize];
											  [self performSelectorOnMainThread:@selector(executeInMain:) withObject:ad waitUntilDone:true];
										  } else if ([ad isEqualToString:@"User All Ready Registered"]) {
											  [SVProgressHUD dismiss];
											  [ToastView showToastInParentView:self.view withText:@"User All Ready Registered" withDuaration:1.0];
										  }
									  }];
	[dataTask resume];
   
	DLog(@"5");
}

- (void)executeInMain:(NSString *)aString; {
	if ([aString isEqualToString:@"New User Registered"]) {
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		UITabBarController *view = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
		[self presentViewController:view animated:true completion:nil];
	}
}

@end
