//
//  CreateClientViewController.m
//  Tech Face
//
//  Created by MedEXO on 07/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "CreateClientViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSData+Extended.h"
#import "NSDate+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <DownPicker.h>


@interface CreateClientViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *clientname;
@property (weak, nonatomic) IBOutlet UITextField *member_no;
@property (weak, nonatomic) IBOutlet UIImageView *cleintprofilepic;
@property (weak, nonatomic) IBOutlet UIButton *AddClientPic;
@property (weak, nonatomic) IBOutlet UIImageView *selected_pract_pic;
@property (weak, nonatomic) IBOutlet UILabel *selected_pract_name;
@property (weak, nonatomic) IBOutlet UIButton *choosePractitioners;

@property (weak, nonatomic) IBOutlet UITextField *selected_shop;
@property (weak, nonatomic) IBOutlet UILabel *shop_label;


@property (strong, nonatomic) NSMutableArray *arrShopArray;
@property (strong, nonatomic) NSMutableArray *arrIndexShopArray;
@property (strong, nonatomic) NSMutableArray *arrDownPicker;
@property (strong, nonatomic) DownPicker *downPicker;
@property (strong, nonatomic) NSString *pract_shop_id;

@end

@implementation CreateClientViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Do any additional setup after loading the view.
	[self addTapGestureToView:self.cleintprofilepic action:@selector(changeClientAvatar)];
    
    self.clientname.backgroundColor = UIColor.whiteColor;
    self.member_no.backgroundColor = UIColor.whiteColor;
    self.selected_shop.backgroundColor = UIColor.whiteColor;
}

- (void)changeClientAvatar {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = true;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:picker animated:true completion:nil];
}

- (IBAction)Back:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

static BOOL cleint_picselected = false;
static BOOL pract_picselected = false;

- (IBAction)AddCleintPic:(id)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = true;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	[self presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// output image
	UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
	self.cleintprofilepic.image = chosenImage;
	[picker dismissViewControllerAnimated:true completion:nil];
	cleint_picselected = true;
	self.AddClientPic.hidden = true;
}

- (IBAction)save:(id)sender {
    if (![NSString isEmpty:self.clientname.text] && ![NSString isEmpty:self.member_no.text] && ![NSString isEmpty:self.selected_shop.text]  && pract_picselected) {
        [self BackGroundProcess];
    } else {
        [ToastView showToastInParentView:self.view withText:@"All required fields Require" withDuaration:1.0];
        DLog(@"Not sucessfully");
    }
}

- (IBAction)ChoosePractitioner:(id)sender {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:@"new_client" forKey:@"capture_current"];
	[userDefaults synchronize];
}

UIImage *client_profileimage;
NSString *input_client_name;
NSString *input_member_no;
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
        input_client_name = self.clientname.text;
        input_member_no = self.member_no.text;
		[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
		client_profileimage = self.cleintprofilepic.image;
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

    NSURL *url = [Server url:@"/techface_api/registerClient?username=%@&member_no=%@&user_id=%@&pract_shop_id=%@", input_client_name, input_member_no, [myDictionary valueForKeyPath:@"vw_user_id"],self.pract_shop_id];
	DLog(@"%@", url.absoluteString);
	DLog(@"1");
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
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
						NSDictionary *homedata = [s objectForKey:@"data"];
						DLog(@"%@", ad);
						if ([ad isEqualToString:@"New Client Register"]) {
							[SVProgressHUD dismiss];
							[self performSelectorOnMainThread:@selector(executeInMain:) withObject:homedata waitUntilDone:true];
						} else if ([ad isEqualToString:@"Client All Ready Registered"]) {
							[SVProgressHUD dismiss];
							[self showDismissAlertWithTitle:@"Try again!" message:@"Client already registered."];
						} else {
                            
                            [self performSelectorOnMainThread:@selector(failCreateClient:) withObject:ad waitUntilDone:true];
                            
                        }
                        
                        
					} @catch (NSException *theErr) {
						DLog(@"The exception is:\n name: %@\nreason: %@"
							 , [theErr name], [theErr reason]);
					}
				}];
	[dataTask resume];
  
	DLog(@"5");
}


- (void)failCreateClient:(NSString *) msg {
    [SVProgressHUD dismiss];
    NSString *errmsg = msg;
    
    if([NSString isEmpty:msg]){
        errmsg =@"Server Error Occurred";
    }

    
    [self showDismissAlertWithTitle:@"Try again!" message:errmsg];
    
}


- (void)executeInMain:(NSDictionary *)aString; {
	[ToastView showToastInParentView:self.view withText:@"Sucessfully" withDuaration:1.0];
	DLog(@"%@", aString);
	DLog(@"selected client : %@", [aString valueForKeyPath:@"vw_user_id"]);
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[aString valueForKeyPath:@"id"] forKey:@"selected_client_id"];
    [userDefaults setObject:self.pract_shop_id forKey:@"pract_shop_id"];
	[userDefaults synchronize];
	NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:aString];
	[userDefaults setObject:0 forKey:@"selected_client_row"];
	[userDefaults setObject:myData forKey:@"selected_client"];
	[userDefaults synchronize];
	/*
	 DLog(@"sucessfully");
	 
	 [ToastView showToastInParentView:self.view withText:@"Sucessfully" withDuaration:1.0];
	 
	 [self.selected_pract_pic.image saveAsName:@"Capture_Pract_Pic.jpg" withQuality:70];
	 
	 [self.cleintprofilepic.image saveAsName:@"Capture_Client_Pic.jpg" withQuality:70];
	 
	 
	 NSMutableArray *array = [[NSMutableArray alloc] init]; //alloc
	 
	 [array addObject:@"Capture_Pract_Pic.jpg"];
	 [array addObject:@"Capture_Client_Pic.jpg"];
	 [array addObject:self.clientname.text];
	 [array addObject:self.birth.text];
	 [array addObject:self.sex.text];
	 [array addObject:self.height.text];
	 [array addObject:self.weight.text];
	 [array addObject:self.blood.text];
	 [array addObject:self.phone.text];
	 [array addObject:self.email.text];
	 [array addObject:self.address.text];
	 
	 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	 [userDefaults setObject:array forKey:@"Capture_Create_client"];
	 [userDefaults synchronize];
	 
	 
	 DLog(@"%@", [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:@"Capture_Create_client"]);
	 
	 */
	//  [self dismissViewControllerAnimated:true completion:nil];
	[self performSegueWithIdentifier:@"Start Capture" sender:nil];
//	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//	AgreementViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"agreement"];
//	[self presentViewController:vc animated:true completion:nil];
	//  [ToastView showToastInParentView:self.view withText:@"Sucessfully" withDuaration:1.0];
}
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSingle:) name:@"selectpract" object:nil];
}

- (void)pushToSingle:(NSNotification *)notis {
	NSDictionary *dict = notis.userInfo;
	int post_id = [[dict objectForKey:@"practid"] intValue];
	if (post_id == 110) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSData *data = [userDefaults dataForKey:@"selected_pract"];
		NSInteger index = [[userDefaults objectForKey:@"selected_pract_row"] intValue];
		NSArray *array = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
		NSDictionary *myDictionary = array[index];
		DLog(@"Array : %@", array);
		DLog(@"Selectedrow : %ld", (long)index);
		self.selected_pract_pic.hidden = false;
		self.selected_pract_name.hidden = false;
		self.choosePractitioners.hidden = true;
        self.arrShopArray = [myDictionary  objectForKey:@"userassignedshop"];
        self.arrDownPicker=[[NSMutableArray alloc] init];
        self.arrIndexShopArray=[[NSMutableArray alloc] init];
        
        for(NSMutableDictionary *obj in self.arrShopArray){
           // [self.arrDownPicker addObject:[obj valueForKeyPath:@"shop_id"]];
            DLog(@"shop picker : %@" , [[obj objectForKey:@"shop"] objectForKey:@"id"]);
            [self.arrDownPicker addObject:[[obj objectForKey:@"shop"] objectForKey:@"shop_name"]];
            
            [self.arrIndexShopArray addObject:[[obj objectForKey:@"shop"] objectForKey:@"id"]];
            
            
        }
        self.downPicker =[[DownPicker alloc] initWithTextField:self.selected_shop withData:self.arrDownPicker];
        [self.downPicker addTarget:self action:@selector(shop_Selected:) forControlEvents:UIControlEventValueChanged];
        
		NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [myDictionary valueForKeyPath:@"avatar"]];
		// DLog(@"Tableview %@", imageUrl);
		[self.selected_pract_pic sd_setImageWithURL:imageUrl
								   placeholderImage:[UIImage imageNamed:@"female_avatar"]];
		self.selected_pract_name.text = [myDictionary valueForKeyPath:@"name"];
		pract_picselected = true;
        self.selected_shop.hidden=NO;
        self.shop_label.hidden=NO;
	}
}

-(void)shop_Selected:(id) dp{
   
    NSInteger selectedValue = [self.downPicker selectedIndex];
    self.pract_shop_id =[self.arrIndexShopArray objectAtIndex:selectedValue];
    DLog(@"get index shop array %@", [self.arrIndexShopArray objectAtIndex:selectedValue]);
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
