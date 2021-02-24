//
//  SelectPractitionerViewController.m
//  Tech Face
//
//  Created by MedEXO on 07/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "SelectPractitionerViewController.h"
//#import "AgreementViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <DownPicker.h>
#import "UIImage+Extended.h"
#import "UIImageView+Extended.h"

@interface SelectPractitionerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *companyUserId;
@property (strong, nonatomic) NSString *companyId;
@property (strong,nonatomic) NSString *tf_token;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *filteredItems;

@property (strong, nonatomic) NSString *searchText;

@property (strong, nonatomic) NSDictionary *com_details_c;
@property (strong, nonatomic) NSDictionary *com_user_details_c;
@property (strong, nonatomic) NSDictionary *company_states_c;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *selected_shop;

@property (strong, nonatomic) NSMutableArray *arrShopArray;
@property (strong, nonatomic) NSMutableArray *arrIndexShopArray;
@property (strong, nonatomic) NSMutableArray *arrDownPicker;
@property (strong, nonatomic) DownPicker *downPicker;
@property (strong, nonatomic) NSString *pract_shop_id;
@property (weak, nonatomic) IBOutlet UIButton *gocapture;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;


@end

@implementation SelectPractitionerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Setup tableview to use auto height
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:100];
	// Do any additional setup after loading the view.
	//  tableData = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", nil];
	// Initialize thumbnails
	//  thumbnails = [NSArray arrayWithObjects:@"female_avatar", @"d_2", @"d_3", @"d_4", nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *homeData = [userDefaults dictionaryForKey:@"homedata"];
    [userDefaults removeObjectForKey:@"client_exposure_setting"];
	self.companyUserId = [homeData valueForKeyPath:@"vw_user_id"];
	self.companyId = [homeData valueForKeyPath:@"vw_company_id"];
    self.tf_token = [homeData valueForKeyPath:@"tf_token"];
    
    [UIImage imageRemoveFromDocumentWithName:@"t_left.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_half_left.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_front.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_half_right.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_right.jpg"];
    [UIImage imageRemoveFromDocumentWithName:@"t_video.mp4"];
    
    
    self.modalInPresentation ="YES";
    self.selected_shop.backgroundColor = UIColor.whiteColor;
    
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self BackGroundProcess];
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    @try {
        NSString *pract_id = [[userDefaults valueForKeyPath:@"selected_pract_id"] stringValue];
        if (![pract_id isEqualToString:@"0"]) {
            if ([[userDefaults objectForKey:@"capture_current"] isEqualToString:@"existing"]) {
                //selected_pract , userassignedshop  shop  --- id,  shop_name
                NSData *data = [userDefaults dataForKey:@"selected_pract"];
                NSInteger index = [[userDefaults objectForKey:@"selected_pract_row"] intValue];
                NSArray *array = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSDictionary *myDictionary = array[index];
                
                self.arrDownPicker=[[NSMutableArray alloc] init];
                self.arrIndexShopArray=[[NSMutableArray alloc] init];
                self.arrShopArray = [myDictionary objectForKey:@"userassignedshop"];
                
                [self createShopOption: self.arrShopArray ];
                [self displaySelectShopOption];
                
                
          
               // [self performSegueWithIdentifier:@"unwindOnPracitionerSelected" sender:self];
            } else {
                [self dismissViewControllerAnimated:true completion:^{
                    DLog(@"Dismiss completed");
                    NSDictionary *pract_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:110]
                                                                           forKey:@"practid"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectpract"
                                                                        object:nil
                                                                      userInfo:pract_dict];
                }];
            }
        }
    } @catch (NSException *e) {
        NSLog(@"Exception: %@", e);
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}


- (void)didReceiveMemoryWarning {
	
    if ([self isViewLoaded] && [self.view window] == nil) {
        
        self.arrShopArray=nil;
        self.arrIndexShopArray=nil;
        self.arrDownPicker=nil;
        self.downPicker=nil;
        self.view = nil;
    
      }
    [super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)Back:(id)sender {
  
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"0" forKey:@"selected_pract_id"];
    
	[self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([NSString isEmpty:self.searchText]) {
		return [self.items count];
	}
	return [self.filteredItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	// Configure the cell...
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	// Display item in the table cell
	UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
	UILabel *nameLabel = (UILabel *)[cell viewWithTag:11];
	NSArray *array = [NSString isEmpty:self.searchText] ? self.items : self.filteredItems;
	NSDictionary *itemDict = array[indexPath.row];
	NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"avatar"]];
	[imageView sd_setImageWithURL:imageUrl
				 placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];
	nameLabel.text = [itemDict valueForKeyPath:@"name"];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	/*
	if (![NSString isEmpty:self.searchText]) {
		DLog(@"Filtered list");
		DLog(@"selected item : %@", [self.filteredItemsDict valueForKeyPath:@"vw_user_id"][indexPath.row]);
		[userDefaults setObject:[self.filteredItemsDict valueForKeyPath:@"vw_user_id"][indexPath.row] forKey:@"selected_pract_id"];
		[userDefaults synchronize];
		NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:self.filteredItemsDict];
		[userDefaults setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"selected_pract_row"];
		[userDefaults setObject:myData forKey:@"selected_pract"];
		[userDefaults synchronize];
	} else {
		DLog(@"Full list");
		DLog(@"selected item : %@", [self.itemsDict valueForKeyPath:@"vw_user_id"][indexPath.row]);
		[userDefaults setObject:[self.itemsDict valueForKeyPath:@"vw_user_id"][indexPath.row] forKey:@"selected_pract_id"];
		[userDefaults synchronize];
		NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:self.itemsDict];
		[userDefaults setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"selected_pract_row"];
		[userDefaults setObject:myData forKey:@"selected_pract"];
		[userDefaults synchronize];
	}
	*/
	NSArray *array = [NSString isEmpty:self.searchText] ? self.items : self.filteredItems;
	NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:array];
	NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];


	[userDefaults setObject:[array[indexPath.row] valueForKeyPath:@"vw_user_id"] forKey:@"selected_pract_id"];
	[userDefaults setObject:itemIndex forKey:@"selected_pract_row"];
	[userDefaults setObject:itemsData forKey:@"selected_pract"];
	[userDefaults synchronize];
    
    
    NSArray *rowArray = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:itemsData];
    NSInteger rowIndex =[[NSNumber numberWithInteger:indexPath.row] intValue];
    NSDictionary *doctorDict = rowArray[rowIndex];
    self.arrShopArray = [doctorDict objectForKey:@"userassignedshop"];
    self.arrDownPicker=[[NSMutableArray alloc] init];
    self.arrIndexShopArray=[[NSMutableArray alloc] init];

    [self createShopOption: self.arrShopArray ];
    
    
	if ([[userDefaults objectForKey:@"capture_current"] isEqualToString:@"existing"]) {

        [self displaySelectShopOption];
        
	} else {
		[self dismissViewControllerAnimated:true completion:^{
			DLog(@"Dismiss completed");
			NSDictionary *pract_dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:110]
																   forKey:@"practid"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"selectpract"
																object:nil
															  userInfo:pract_dict];
		}];
	}
}

-(void) displaySelectShopOption {
    self.searchBar.hidden=TRUE;
    self.tableView.hidden=TRUE;
    self.selected_shop.hidden=FALSE;
    self.gocapture.hidden=FALSE;
    
}

-(void) createShopOption:(NSMutableArray*) assignedShopArray{
    
    for(NSMutableDictionary *obj in assignedShopArray){
        [self.arrDownPicker addObject:[[obj objectForKey:@"shop"] objectForKey:@"shop_name"]];
        [self.arrIndexShopArray addObject:[[obj objectForKey:@"shop"] objectForKey:@"id"]];
        
    }
    self.downPicker =[[DownPicker alloc] initWithTextField:self.selected_shop withData:self.arrDownPicker];
    [self.downPicker addTarget:self action:@selector(shop_Selected:) forControlEvents:UIControlEventValueChanged];
    
}

-(void)shop_Selected:(id) dp{
   
    NSInteger selectedValue = [self.downPicker selectedIndex];
    self.pract_shop_id =[self.arrIndexShopArray objectAtIndex:selectedValue];
    
    
    DLog(@"get index shop array %@", [self.arrIndexShopArray objectAtIndex:selectedValue]);
    
}
- (IBAction)gotoCapture:(id)sender {
    
    if (![NSString isEmpty:self.selected_shop.text]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.pract_shop_id forKey:@"pract_shop_id"];
        [userDefaults removeObjectForKey:@"selectedtreatment"];
        
        [userDefaults synchronize];
        
        [self performSegueWithIdentifier:@"unwindOnPracitionerSelected" sender:self];
    } else {
        [ToastView showToastInParentView:self.view withText:@"All required fields Require" withDuaration:1.0];

    }
    
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchText = searchText;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
	self.filteredItems = [self.items filteredArrayUsingPredicate:predicate];
	[self.tableView reloadData];
}

#pragma mark - Networking

- (void)BackGroundProcess {
	if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
		[self showDismissAlertWithTitle:@"Oops !!"
								message:@"Internet Is not avalible"];
		return;
	}
	[self performSelectorInBackground:@selector(executeInBackgroundHomeconfig) withObject:nil];
	DLog(@"IS REACHABILE");
	[SVProgressHUD show];
}

- (void)executeInBackgroundHomeconfig {
	DLog(@"executeInBackground");
	NSURL *url = [Server url:@"/techface_api/getPractitioners?company_id=%@&company_user_id=%@&tf_token=%@", self.companyId, self.companyUserId, self.tf_token];
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
										  DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
										  [SVProgressHUD dismiss];
										  NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  self.items = [s objectForKey:@"pract_list"];
										  DLog(@"%@", self.items);
										  self.com_details_c = [s objectForKey:@"com_details"];
										  self.com_user_details_c = [s objectForKey:@"com_user_details"];
										  self.company_states_c = [s objectForKey:@"company_states"];
                                          self.arrShopArray = [s objectForKey:@"userassignedshop"];
										  DLog(@"%@", self.com_details_c);
										  DLog(@"%@", self.com_user_details_c);
										  DLog(@"%@", self.company_states_c);
										  [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
									  }];
	[dataTask resume];
  
}

- (void)executeInMain {
	DLog(@"Total items: %@", self.items);
	[self.tableView reloadData];
}

@end
