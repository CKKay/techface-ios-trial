//
//  SearchClientViewController.m
//  Tech Face
//
//  Created by MedEXO on 09/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "SearchClientViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface SearchClientViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSString *companyUserId;
@property (strong, nonatomic) NSString *companyId;
@property (strong, nonatomic) NSString *shopId;
@property (strong, nonatomic) NSString *tf_token;
@property (strong, nonatomic) NSString *logout;
@property (strong, nonatomic) NSString *message;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *filteredItems;

@property (strong, nonatomic) NSString *searchText;

@end

@implementation SearchClientViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupEmptyBackButtonOnPushed];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Setup tableview to use auto height
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:100];
	// Setup pull-to-refresh
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:self.refreshControl];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *data = [userDefaults dictionaryForKey:@"homedata"];
	self.companyUserId = [data valueForKeyPath:@"vw_user_id"];
	self.companyId = [data valueForKeyPath:@"vw_company_id"];
    self.shopId = [data valueForKeyPath:@"vw_shop_id"];
    self.tf_token = [data valueForKeyPath:@"tf_token"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self BackGroundProcess];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)refreshTable {
	//TODO: refresh your data
	[self.refreshControl endRefreshing];
	[self BackGroundProcess];
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
	NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"photo_url"]];
	[imageView sd_setImageWithURL:imageUrl
				 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
    nameLabel.text = [NSString stringWithFormat:@"[%@] %@", [itemDict valueForKeyPath:@"member_no"], [itemDict valueForKeyPath:@"username"]];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];

	NSArray *array = [NSString isEmpty:self.searchText] ? self.items : self.filteredItems;
	NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:array];
	NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:itemIndex forKey:@"selected_client_id"];
	[userDefaults setObject:itemsData forKey:@"selected_client"];
	[userDefaults synchronize];
/*
	NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:self.filteredItemsDict];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"selected_client_id"];
	[[NSUserDefaults standardUserDefaults] setObject:myData forKey:@"selected_client"];
*/

	[self.parentViewController performSegueWithIdentifier:@"Show Client" sender:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	self.searchText = searchText;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username contains[c] %@ || (member_no contains[c] %@ && member_no != '')", searchText, searchText];
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
	NSURL *url = [Server url:@"/techface_api/searchClient?company_id=%@&shop_id=%@&companyUserId=%@&tf_token=%@", self.companyId, self.shopId,self.companyUserId,self.tf_token];
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
										  self.items = [s objectForKey:@"client_data"];
                                          self.logout = [s objectForKey:@"logout"];
                                          self.message = [s objectForKey:@"message"];
                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                          [userDefaults setObject:self.logout forKey:@"logout"];
                                          [userDefaults setObject:self.message forKey:@"message"];
                                          [userDefaults synchronize];
        
										  DLog(@"%@", self.items);
										  [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
									  }];
	[dataTask resume];
   
}

- (void)executeInMain {
	
    if ([self.logout isEqualToString:@"Y"]){
         [self showAlertWithTitle:@"Message !!"
                          message:[NSString stringWithFormat:@"%@", self.message]
            cancelButtonTitle:@"Quit App"
                    cancelHandler:^(UIAlertAction * _Nonnull action) {
                         exit(0);
                    }
                    okButtonTitle:@"Log in again"
                        okHandler:^(UIAlertAction * _Nonnull action) {
                           // exit(0);
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults removeObjectForKey:@"signincheck"];
                     [userDefaults synchronize];
                     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
                     UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"login"];
                     [self presentViewController:vc animated:true completion:nil];
             
                     }];
    } else {
        [self.tableView reloadData];
    }
    
}

- (void) dealloc
{
    //[observer unregisterObject:self];
   //  [observer unregisterObject:self];
    DLog(@"search client dealloc");
   // [super dealloc]; //(provided by the compiler)
}


@end
