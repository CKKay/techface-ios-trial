//
//  SaveTreatmentViewController.m
//  Tech Face
//
//  Created by MedEXO on 18/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "SaveTreatmentViewController.h"
#import "Server.h"
#import "ToastView.h"
#import "Reachability.h"
#import "NSData+Extended.h"
#import "NSDate+Extended.h"
#import "NSString+Extended.h"
#import "UIImage+Extended.h"
#import "UIImageView+Extended.h"
#import "UIViewController+Extended.h"
#import "ConnectDeviceViewController.h"
#import <BugfenderSDK/BugfenderSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <DownPicker.h>

@import AVKit;

@interface SaveTreatmentViewController ()

// Practitioner section
@property (weak, nonatomic) IBOutlet UIImageView *practitionerImageView;
@property (weak, nonatomic) IBOutlet UILabel *practitionerNameLabel;

// Client section
@property (weak, nonatomic) IBOutlet UIImageView *clientImageView;
@property (weak, nonatomic) IBOutlet UILabel *clientNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientBloodTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientBirthdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientAgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *practitionerNameLabel2;
@property (weak, nonatomic) IBOutlet UILabel *clientPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientAddressLabel;
@property (strong, nonatomic) IBOutlet UITextField *t_remark;

@property (weak, nonatomic) IBOutlet UITextView *t_details;



// Video section
@property (weak, nonatomic) IBOutlet UIImageView *prevVideoImageView;
@property (weak, nonatomic) IBOutlet UIButton *prevVideoPlayButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *prevVideoIndicator;

// Photo - Front section
@property (weak, nonatomic) IBOutlet UIImageView *prevFrontImageView;

// Photo - Half Left section
@property (weak, nonatomic) IBOutlet UIImageView *prevHLeftImageView;

// Photo - Half Right section
@property (weak, nonatomic) IBOutlet UIImageView *prevHRightImageView;

// Photo - Left section
@property (weak, nonatomic) IBOutlet UIImageView *prevLeftImageView;

// Photo - Right section
@property (weak, nonatomic) IBOutlet UIImageView *prevRightImageView;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) NSString *shopId;
@property (strong, nonatomic) NSString *companyId;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *practitionerId;
@property (strong, nonatomic) NSString *treatmentTypeId;
@property (strong, nonatomic) NSString *pract_shop_id;
@property (strong, nonatomic) NSString *user_id;
@property (strong,nonatomic) NSString *datalocation;
@property (strong,nonatomic) NSString *apiBelongto;
@property (strong,nonatomic) NSNumber *totalfilesize;
@property (strong,nonatomic) NSString *uploadDataLimit;
@property (assign) NSInteger countUploadError;

@property (strong, nonatomic) NSString *str_details;
@property (strong, nonatomic) NSString *str_remark;

@property (weak, nonatomic) IBOutlet UILabel *labelHalfLeft;
@property (weak, nonatomic) IBOutlet UILabel *labelFront;
@property (weak, nonatomic) IBOutlet UILabel *labelHalfRight;
@property (weak, nonatomic) IBOutlet UILabel *labelLeft;
@property (weak, nonatomic) IBOutlet UILabel *labelRight;

@property (strong, nonatomic) NSMutableArray *arrTreatmentTypes;
@property (strong, nonatomic) NSMutableArray *arrCategoryTreatmentTypes;
@property (strong, nonatomic) NSMutableArray *arrDownPicker;
@property (strong, nonatomic) DownPicker *downPicker;
@property (strong, nonatomic) NSMutableArray *selectTreatmentArray;
@property (strong, nonatomic) NSString *currentMode;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;

@end

@implementation SaveTreatmentViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setTapToDismissKeyboardForView:self.view];

	//  [self BackGroundProcess];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
   
    self.currentMode=[userDefaults objectForKey:@"currentMode"];
	self.shopId = [myDictionary valueForKeyPath:@"vw_shop_id"];
	self.companyId = [myDictionary valueForKeyPath:@"vw_company_id"];
    self.user_id = [myDictionary valueForKeyPath:@"id"];
	self.clientId = [userDefaults objectForKey:@"selected_client_id"];
    self.pract_shop_id = [userDefaults objectForKey:@"pract_shop_id"];
	self.practitionerId = [userDefaults objectForKey:@"selected_pract_id"];
    self.datalocation = [myDictionary valueForKeyPath:@"datalocation"];
    self.apiBelongto = [myDictionary valueForKeyPath:@"apiBelongto"];
    self.uploadDataLimit = [myDictionary valueForKeyPath:@"upload_data_limit"];
    self.countUploadError = 0;
    self.t_remark.backgroundColor = UIColor.whiteColor;
    self.t_details.backgroundColor=UIColor.whiteColor;
    self.arrMultiTreatmentTypes =[[NSMutableDictionary alloc] init];

    self.t_details.scrollEnabled=false;
    self.t_details.editable=false;
    self.modalInPresentation = true;
  //  [self.t_details setContentOffset:CGPointZero];


	NSData *clientsData = [userDefaults dataForKey:@"selected_client"];
	NSDictionary *clientDict;
	if ([[userDefaults objectForKey:@"capture_current"] isEqualToString:@"existing"]) {
		NSInteger clientIndex = [[userDefaults objectForKey:@"selected_client_row"] intValue];
		NSArray *clients = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
		clientDict = clients[clientIndex];
	} else {
		clientDict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
	}

	NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [clientDict valueForKeyPath:@"photo_url"]];
	self.clientNameLabel.text = [clientDict valueForKeyPath:@"username"];
	[self.clientImageView sd_setImageWithURL:imageUrl
							placeholderImage:[UIImage imageNamed:@"female_avatar"]];
	self.clientGenderLabel.text = [clientDict valueForKeyPath:@"sex"];
	self.clientHeightLabel.text = [clientDict valueForKeyPath:@"height"];
	self.clientWeightLabel.text = [clientDict valueForKeyPath:@"weight"];
	self.clientBloodTypeLabel.text = [clientDict valueForKeyPath:@"blood"];
	self.clientBirthdateLabel.text = [clientDict valueForKeyPath:@"birth"];
	NSString *time = [clientDict valueForKeyPath:@"birth"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *bdate = [dateFormatter dateFromString:time];

    NSDate *now = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:bdate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
	self.clientAgeLabel.text = [NSString stringWithFormat:@"%ld", (long)age];


	self.clientPhoneLabel.text = [clientDict valueForKeyPath:@"phone"];
	self.clientEmailLabel.text = [clientDict valueForKeyPath:@"email"];
	self.clientAddressLabel.text = [clientDict valueForKeyPath:@"address"];

	NSData *practitionersData = [userDefaults dataForKey:@"selected_pract"];
	NSUInteger selectedIndex = [[userDefaults objectForKey:@"selected_pract_row"] intValue];
	NSArray *practitoners = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:practitionersData];

	NSDictionary *itemDict = practitoners[selectedIndex];
	NSURL *pract_imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"avatar"]];

	self.practitionerNameLabel.text = [itemDict valueForKeyPath:@"name"];
    self.practitionerNameLabel2.text = self.practitionerNameLabel.text;
	[self.practitionerImageView sd_setImageWithURL:pract_imageUrl
								  placeholderImage:[UIImage imageNamed:@"female_avatar"]];

    self.labelHalfLeft.text = @"Half Left";
    self.labelFront.text = @"Front";
    self.labelHalfRight.text = @"Half Right";
    self.labelLeft.text = @"Left";
    self.labelRight.text = @"Right";
    
    self.prevLeftImageView.image = [UIImage imageInDocumentWithName:@"t_left.jpg"];
    self.prevHLeftImageView.image = [UIImage imageInDocumentWithName:@"t_half_left.jpg"];
    self.prevFrontImageView.image = [UIImage imageInDocumentWithName:@"t_front.jpg"];
    self.prevHRightImageView.image = [UIImage imageInDocumentWithName:@"t_half_right.jpg"];
    self.prevRightImageView.image = [UIImage imageInDocumentWithName:@"t_right.jpg"];
    
	[self.prevVideoIndicator startAnimating];
	self.prevVideoImageView.image = [self thumbnailFromCapturedVideo];
	DLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    [self performSelectorOnMainThread:@selector(executeInBackgroundGetTreatmentTypes) withObject:nil waitUntilDone:true];
    self.selectTreatmentArray= [[NSMutableArray alloc] init];
    [self updateTreatmentText];
    

    
    
}

- (void)didReceiveMemoryWarning {
    
     DLog(@"SaveTreatment dealloc warning");
    
      if ([self isViewLoaded] && [self.view window] == nil) {
        
        DLog(@"SaveTreatment dealloc warning deallocing now!");
    
      }
    
    [super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
	[super prepareForSegue:segue sender:sender];
}

#pragma mark - Actions


- (IBAction)playVideoAction:(id)sender {
	NSString *getPath = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:getPath]) {
		DLog(@"exist");
		BFLog(@"Play video exist");
	} else {
		DLog(@"not exist");
		BFLog(@"Play video not exist");
	}
	NSURL *videoURL = [NSURL fileURLWithPath:getPath];
	// create an AVPlayer
	AVPlayer *player = [AVPlayer playerWithURL:videoURL];
	// create a player view controller
	AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
	controller.player = player;
	[player play];
	[self presentViewController:controller animated:true completion:nil];
	controller.view.frame = self.view.frame;
	[controller.player play];
    controller=nil;
}

- (IBAction)saveAction:(id)sender {
    
    if ([self.uploadDataLimit isEqualToString:@"Y"]) {
        NSString *message = @"Maximun data upload limit have been reached!";
        [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"Status : %@", message]];
    } else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        [self dismissKeyboard];
        [self BackGroundProcess];
    }
}

#pragma mark - Networking

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
		return;
	}
    self.str_remark = [self.t_remark text];
    self.str_details = [self.t_details text];
	[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
    
    
	DLog(@"IS REACHABILE");
	[SVProgressHUD show];
}

- (void)executeInBackgroundHomeconfig {
 
    if([NSString isEmpty:self.datalocation]){
        [self sendImageToServer];
    } else {
        
        //   if(self.countUploadError > 2){
        //       [self sendImageToServer];
        //   } else {
        
        [self sendImageToAnotherServer];
        //  }
    }
}


- (void)sendImageToServer {
        
        
        NSData *json = [NSJSONSerialization dataWithJSONObject:self.selectTreatmentArray options:0 error:nil];
        NSString *jsonStringMultiTreatment =[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSLog(@"jsonData as string:\n%@",jsonStringMultiTreatment);
    
	
    NSString *isManualCaptureString = self.isManualCapture ? @"1" : @"0";
    NSURL *url = [Server url:@"/techface_api/addClientTreatment?client_id=%@&pract_id=%@&treatment_details=%@&type_of_treatment=%@&treatment_date=%@&company_id=%@&shop_id=%@&treatment_type_id=%@&pract_shop_id=%@&is_manual_capture=%@&user_id=%@&multitreatment=%@&currentMode=%@", self.clientId, self.practitionerId, self.str_remark, self.str_details, [NSDate shortStringFromDate:[NSDate date]], self.companyId, self.shopId, self.treatmentTypeId,self.pract_shop_id, isManualCaptureString,self.user_id,jsonStringMultiTreatment,self.currentMode];
	DLog(@"absolute string %@", url.absoluteString);
	DLog(@"1");
	//  UIImage *img = [[UIImage alloc] initWithData:data];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
	[request setHTTPShouldHandleCookies:false];
	[request setTimeoutInterval:300];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"unique-consistent-string";
	// set Content-Type in HTTP header
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	// post body
	
	NSMutableData *body = [NSMutableData data];
	// add params (all params are strings)
	[body appendStringWithFormat:@"--%@\r\n", boundary];
	[body appendStringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"];
	[body appendStringWithFormat:@"%@\r\n", @"Some Caption"];
	// add photos
	NSArray *namePairs = @[@[@"agreementphoto", @"t_agreement.jpg"],
						   @[@"photoright", @"t_right.jpg"],
						   @[@"photohalfright", @"t_half_right.jpg"],
						   @[@"photofront", @"t_front.jpg"],
						   @[@"photohalfleft", @"t_half_left.jpg"],
						   @[@"photoleft", @"t_left.jpg"]];
    float *filesize = 0;
	for (NSArray *pair in namePairs) {
		NSString *path = [NSString fullPathOfUserDocumentWithName:pair[1]]; // file name
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
      
        
        /*
        CGFloat targetWidth = image.size.width / 2;
        CGFloat targetHeight = image.size.height / 2;
        UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
        [image drawInRect:CGRectMake(0, 0, targetWidth, targetHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        */
        NSData *data = UIImageJPEGRepresentation(image, 1);
        
        filesize+=[data length];
        
        
		DLog(@"%@", path);
		if (data) {
            
			[body appendStringWithFormat:@"--%@\r\n", boundary];
			[body appendStringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@.jpg\r\n", pair[0], pair[0]];
			[body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
			[body appendData:data];
			[body appendString:@"\r\n"];
		} else {
			DLog(@"image %@ is null, skipping", pair[1]);
		}
        
	}
    
 //   DLog(@"data file size %li",(long)filesize);
    
	// add video
	{
		NSArray *pair = @[@"video", @"t_video.mp4"];
		NSString *path = [NSString fullPathOfUserDocumentWithName:pair[1]]; // file name
		NSData *data = [NSData dataWithContentsOfFile:path];
		
        
		if (data) {
           
			[body appendStringWithFormat:@"--%@\r\n", boundary];
			[body appendStringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@.mp4\r\n", pair[0], pair[0]];
			[body appendString:@"Content-Type: video/mp4\r\n\r\n"];
			[body appendData:data];
			[body appendString:@"\r\n"];
		} else {
			DLog(@"video %@ is null, skipping", pair[1]);
		}
        
	}
    
	DLog(@"3");
	[body appendStringWithFormat:@"--%@--\r\n", boundary];
	// setting the body of the post to the reqeust
	DLog(@"Final : %@", [[NSString alloc] initWithData:body encoding:NSASCIIStringEncoding]);
	[request setHTTPBody:body];
	// set the content-length
	[request setValue:[@(body.length) stringValue] forHTTPHeaderField:@"Content-Length"];
	DLog(@"Content-Length: %lu", (unsigned long)[body length]);
	__strong NSURLSession *session = [NSURLSession sharedSession];
	__strong NSURLSessionDataTask *dataTask;
	dataTask = [session dataTaskWithRequest:request
						  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
				{
					DLog(@"Respose 123: %@", response);
					DLog(@"Data 123: %@", data);
					DLog(@"Error 123: %@", error);
					DLog(@"String sent from server 123 %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
					// NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
					//  DLog(myString);
					//  NSString *myStr = [myString stringByReplacingOccurrencesOfString:@" " withString:@""];
					@try {
						NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
						NSString *ad = [s objectForKey:@"message"];
						NSString *homedata = [s objectForKey:@"data"];
						DLog(@"%@", ad);
						[SVProgressHUD dismiss];
						if ([ad isEqualToString:@"Client Treatment Added"]) {
                
                            [self performSelectorOnMainThread:@selector(executeInMain:) withObject:homedata waitUntilDone:true];
                            
						} else {
							NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            
                            [self performSelectorOnMainThread:@selector(failResponse:) withObject:httpResponse waitUntilDone:true];
						}
					} @catch (NSException *exception) {
                        DLog(@"Data 456: %@", data);
						DLog(@"Save Treatment Exception %@", exception);
						//[SVProgressHUD dismiss];
                          [self performSelectorOnMainThread:@selector(failForException:) withObject:exception waitUntilDone:true];
				
					}
				}];
	[dataTask resume];
   
	DLog(@"5");
}

- (void)sendImageToAnotherServer {
    

    NSString *parameter_string =@"company_id=%@&shop_id=%@&client_id=%@";
    NSString *datalocationString = [self.datalocation stringByAppendingString:parameter_string];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:datalocationString,self.companyId,self.pract_shop_id,self.clientId]];
    

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:false];
    [request setTimeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"unique-consistent-string";
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    // post body
 
    NSMutableData *body = [NSMutableData data];
    // add params (all params are strings)
    [body appendStringWithFormat:@"--%@\r\n", boundary];
    [body appendStringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"imageCaption"];
    [body appendStringWithFormat:@"%@\r\n", @"Some Caption"];
    // add photos
    NSArray *namePairs = @[@[@"agreementphoto", @"t_agreement.jpg"],
                           @[@"photoright", @"t_right.jpg"],
                           @[@"photohalfright", @"t_half_right.jpg"],
                           @[@"photofront", @"t_front.jpg"],
                           @[@"photohalfleft", @"t_half_left.jpg"],
                           @[@"photoleft", @"t_left.jpg"]];
    float filesize = 0;
    for (NSArray *pair in namePairs) {
        NSString *path = [NSString fullPathOfUserDocumentWithName:pair[1]]; // file name
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
      
        DLog(@"%@", path);
        if (data) {
            filesize+=[data length];
            [body appendStringWithFormat:@"--%@\r\n", boundary];
            [body appendStringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@.jpg\r\n", pair[0], pair[0]];
            [body appendString:@"Content-Type: image/jpeg\r\n\r\n"];
            [body appendData:data];
            [body appendString:@"\r\n"];
        } else {
            DLog(@"image %@ is null, skipping", pair[1]);
        }
        //data=nil;
    }
    
    // add video
    {
        NSArray *pair = @[@"video", @"t_video.mp4"];
        NSString *path = [NSString fullPathOfUserDocumentWithName:pair[1]]; // file name
        NSData *data = [NSData dataWithContentsOfFile:path];
     
        
        if (data) {
            filesize+=[data length];
            [body appendStringWithFormat:@"--%@\r\n", boundary];
            [body appendStringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@.mp4\r\n", pair[0], pair[0]];
            [body appendString:@"Content-Type: video/mp4\r\n\r\n"];
            [body appendData:data];
            [body appendString:@"\r\n"];
        } else {
            DLog(@"video %@ is null, skipping", pair[1]);
        }
        
       //  data=nil;
    }
    self.totalfilesize= @(filesize);
    
    [body appendStringWithFormat:@"--%@--\r\n", boundary];
    // setting the body of the post to the reqeust
    DLog(@"Final : %@", [[NSString alloc] initWithData:body encoding:NSASCIIStringEncoding]);
    [request setHTTPBody:body];
    // set the content-length
    [request setValue:[@(body.length) stringValue] forHTTPHeaderField:@"Content-Length"];
    DLog(@"Content-Length: %lu", (unsigned long)[body length]);
    __strong NSURLSession *session = [NSURLSession sharedSession];
    __strong NSURLSessionDataTask *dataTask;
    dataTask = [session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                {
     
                    @try {
                        NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSString *status = [s objectForKey:@"status"];
                        NSString *responasedata = [s objectForKey:@"data"];
                        NSString *fileUrl  = [[s objectForKey:@"data"] objectForKey:@"file"];
                       
                        [SVProgressHUD dismiss];
                        if ([status isEqualToString:@"success"]) {
                            [self executeUpdateTreatmentUrl:fileUrl];
                            
                        } else {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            self.countUploadError ++;
                            [self performSelectorOnMainThread:@selector(failResponse:) withObject:httpResponse waitUntilDone:true];
                        }
                    } @catch (NSException *exception) {
                        
                        DLog(@"Save Treatment other server Exception %@", exception);
                         self.countUploadError ++;
                        //[SVProgressHUD dismiss];
                          [self performSelectorOnMainThread:@selector(failForException:) withObject:exception waitUntilDone:true];
                
                    }
                }];
    [dataTask resume];
   
  
 
}

- (void)executeUpdateTreatmentUrl:(NSString *)fileUrl; {
    
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:self.selectTreatmentArray options:0 error:nil];
    NSString *jsonStringMultiTreatment =[[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    NSLog(@"jsonData as string:\n%@",jsonStringMultiTreatment);

    NSString *agreementphoto = [fileUrl valueForKeyPath:@"agreementphoto"];
    NSString *photoright = [fileUrl valueForKeyPath:@"photoright"];
    NSString *photohalfright = [fileUrl valueForKeyPath:@"photohalfright"];
    NSString *photofront = [fileUrl valueForKeyPath:@"photofront"];
    NSString *photohalfleft = [fileUrl valueForKeyPath:@"photohalfleft"];
    NSString *photoleft = [fileUrl valueForKeyPath:@"photoleft"];
    NSString *video = [fileUrl valueForKeyPath:@"video"];
    
    NSString *isManualCaptureString = self.isManualCapture ? @"1" : @"0";
    NSURL *url = [Server url:@"/techface_api/addClientTreatmentURL?client_id=%@&pract_id=%@&treatment_details=%@&type_of_treatment=%@&treatment_date=%@&company_id=%@&shop_id=%@&treatment_type_id=%@&pract_shop_id=%@&is_manual_capture=%@&user_id=%@&agreementphoto=%@&photoright=%@&photohalfright=%@&photofront=%@&photohalfleft=%@&photoleft=%@&video=%@&apibelongto=%@&filesize=%@&multitreatment=%@&currentMode=%@", self.clientId, self.practitionerId, self.str_remark, self.str_details, [NSDate shortStringFromDate:[NSDate date]], self.companyId, self.shopId, self.treatmentTypeId,self.pract_shop_id, isManualCaptureString,self.user_id,agreementphoto,photoright,photohalfright,photofront,photohalfleft,photoleft,video,self.apiBelongto,self.totalfilesize,jsonStringMultiTreatment,self.currentMode];

   
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setTimeoutInterval:300];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    __strong NSURLSession *session = [NSURLSession sharedSession];
    __strong NSURLSessionDataTask *dataTask;
    dataTask = [session dataTaskWithRequest:request
                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                {
                    DLog(@"Respose 123: %@", response);
                    DLog(@"Data 123: %@", data);
                    DLog(@"Error 123: %@", error);
                    DLog(@"String sent from server 123 %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             
                    @try {
                        NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSString *ad = [s objectForKey:@"message"];
                        NSString *homedata = [s objectForKey:@"data"];
                
                        [SVProgressHUD dismiss];
                        if ([ad isEqualToString:@"Client Treatment Added"]) {
                
                            [self performSelectorOnMainThread:@selector(executeInMain:) withObject:homedata waitUntilDone:true];
                            
                        } else {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            
                            [self performSelectorOnMainThread:@selector(failResponse:) withObject:httpResponse waitUntilDone:true];
                        }
                    } @catch (NSException *exception) {
                 
                          [self performSelectorOnMainThread:@selector(failForException:) withObject:exception waitUntilDone:true];
                
                    }
                }];
    [dataTask resume];


}



-(void) failForException:(NSException *)exception {
    [SVProgressHUD dismiss];
     [self showDismissAlertWithTitle:@"Server Error" message:[NSString stringWithFormat:@"Status : %@", exception.name]];
    
}


-(void) failResponse:(NSHTTPURLResponse *)httpResponse;{
    [self showDismissAlertWithTitle:@"Server Error Occurred" message:[NSString stringWithFormat:@"Status Code: %ld", httpResponse.statusCode]];
    
}

- (void)executeInMain:(NSString *)aString; {

    
    [UIImage imageRemoveFromDocumentWithName:@"t_left.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_half_left.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_front.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_half_right.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_right.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_video.mp4"];
    

    [self.prevLeftImageView removeFromSuperview];
    [self.prevHLeftImageView removeFromSuperview];
    [self.prevFrontImageView removeFromSuperview];
    [self.prevHRightImageView removeFromSuperview];
    [self.prevRightImageView removeFromSuperview];
    [self.prevVideoImageView removeFromSuperview];

    self.prevLeftImageView = nil;
    self.prevHLeftImageView = nil;
    self.prevFrontImageView = nil;
    self.prevHRightImageView = nil;
    self.prevRightImageView = nil;
    self.prevVideoImageView=nil;
    
    //  [self dismissViewControllerAnimated:YES completion:nil];
  //  [self.viewFinderVC stopVideoSession];
 
   // [self.viewFinderVC stopCameraSession];
  //  [self.connectDeviceVC didDisconnectDevice];
 //   [self.viewFinderVC clearImage];
       
   //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
  
     //capturenav
     //  ConnectDeviceViewController *cd =[self.storyboard //instantiateViewControllerWithIdentifier:@"cd"];
     // [self.navigationController pushViewController:cd animated:YES];
    
    
    UIViewController *vc = self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:true completion:nil];
    
    
    
    //remove by kay because need to dismiss the fartest ancenster view  start
   // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  //    UITabBarController *view = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    
	//[self presentViewController:view animated:true completion:nil];
     //remove by kay because need to dismiss the fartest ancenster view  End

	DLog(@"sucessfully done");
}

- (void)executeInBackgroundGetTreatmentTypes {
    [SVProgressHUD show];
    NSURL *url = [Server url:@"/techface_api/getTreatmentTypes?company_id=%@", self.companyId];
    DLog(@"%@", url.absoluteString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          [SVProgressHUD dismiss];
                                          NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                
        
                                          [self performSelectorOnMainThread:@selector(executeInMainGetTreatmentTypes:) withObject:s waitUntilDone:true];
                                      }];
    [dataTask resume];

}

- (void)executeInMainGetTreatmentTypes:(NSDictionary *)s; {
    self.arrTreatmentTypes = [s objectForKey:@"treatment_types"];
    
    NSDictionary *categoryTreatmentTypes = [s objectForKey:@"category"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:categoryTreatmentTypes forKey:@"categoryTreatmentType"];
    
    if( !self.arrTreatmentTypes || [self.arrTreatmentTypes count] ==0){
       [self showDismissAlertWithTitle:@"Message" message:[NSString stringWithFormat:@"status : %s", "No Treatment Type"]];
    } else {
        /* remove by kay at 20201203 because multi-treatment selection
        self.arrDownPicker = [[NSMutableArray alloc] init];
        for (NSObject *obj in self.arrTreatmentTypes) {
            [self.arrDownPicker addObject:[obj valueForKeyPath:@"name"]];
        }
        self.downPicker = [[DownPicker alloc] initWithTextField:self.t_details withData:self.arrDownPicker];
        [self.downPicker addTarget:self action:@selector(dp_Selected:) forControlEvents:UIControlEventValueChanged];
        [self.downPicker setValueAtIndex:0];*/
    }
}

-(void)dp_Selected:(id)dp {
    NSInteger selectedValue = [self.downPicker selectedIndex];
    self.treatmentTypeId = [self.arrTreatmentTypes[selectedValue] valueForKeyPath:@"id"];
}



#pragma mark - Helpers

- (nullable UIImage *)thumbnailFromCapturedVideo {
	NSString *urlString = [NSString fullPathOfUserDocumentWithName:@"t_video.mp4"];
	NSURL *url = [NSURL fileURLWithPath:urlString];
	UIImage *image = [UIImage assetImageFromURL:url];
	[self.prevVideoIndicator stopAnimating];
	self.prevVideoPlayButton.hidden = false;
	return image;
}

- (void) dealloc
{

    DLog(@"SaveTreatment dealloc process");

}


- (void) updateMultiTreatment:(NSString *)tid :(NSString *)value
{
    [self.arrMultiTreatmentTypes setObject:value forKey:tid];
}


- (void)addItemViewController:(TreatmentTypeViewController *)controller didFinishEnteringItem:(NSString *)item
{
    
    NSLog(@"This was returned from TreatmentTypeView %@", item);
}


#pragma mark - Navigation

- (IBAction)unwindToTreatmentView:(UIStoryboardSegue *)segue {
    
    [self updateTreatmentText];
}


- (void) updateTreatmentText
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSObject *getMultiTreatment = [userDefaults objectForKey:@"selectedtreatment"];
    [self.selectTreatmentArray removeAllObjects];
    for(NSData *obj in getMultiTreatment){
        
        NSError *error;
        NSMutableDictionary *getDataCheck = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableDictionary class] fromData:obj error:&error];
        
        NSMutableString *treatmentName=[[NSMutableString alloc] init];
   
        for(NSString *key in getDataCheck){
            NSLog(@"get value %@",key);
            NSLog(@"get value %@",[getDataCheck objectForKey:key]);
        
            NSString *name = [getDataCheck objectForKey:key];
            [treatmentName appendString:[NSString stringWithFormat:@"%@\n",name]];
            self.t_details.text = name;
            self.treatmentTypeId = key;
          
            [self.selectTreatmentArray addObject:key];
        
            
        }
        
        self.str_details = treatmentName;
        self.t_details.text =treatmentName;
      
        
        NSLog(@"get treatment id value %@",self.treatmentTypeId);
        
    }
    
    
    if(getMultiTreatment==nil){
        self.str_details = nil;
        self.t_details.text =nil;
        self.treatmentTypeId = nil;
        [self.selectTreatmentArray removeAllObjects];
        
    }
    
    NSLog(@"get treatment string value %@",self.selectTreatmentArray);
    
}


@end
