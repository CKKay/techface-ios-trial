//
//  ScheduleViewController.m
//  Tech Face
//
//  Created by MedEXO on 10/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//
#import "ScheduleViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSDate+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ScheduleViewController ()

@property (weak, nonatomic) IBOutlet UIButton *practitionersButton;
@property (weak, nonatomic) IBOutlet UIButton *clientsButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *selectedItemView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedItemImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectedNameLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *treatmentDatePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *companyId;
@property (strong, nonatomic) NSString *shopId;

@property (strong, nonatomic) NSArray *practitionersArray;
@property (strong, nonatomic) NSArray *clientsArray;
@property (strong, nonatomic) NSArray *treatmentsArray;

@property (strong, nonatomic) NSArray *filteredPractitionersArray;
@property (strong, nonatomic) NSArray *filteredClientsArray;
@property (strong, nonatomic) NSArray *filteredTreatmentsArray;

@property (strong, nonatomic) NSString *selectedPractitionerId;
@property (strong, nonatomic) NSString *selectedClientId;

@property (assign, nonatomic) BOOL searchPractitioners;
@property (assign, nonatomic, getter=isSearching) BOOL searching;

@end

@implementation ScheduleViewController

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupEmptyBackButtonOnPushed];
	// Setup background to dismiss keyboard
	[self setTapToDismissKeyboardForView:self.view];
	// Setup tableview to use auto height
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:100];

	[self.treatmentDatePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
	// [self.selectDate performSelector:@selector(setHighlightsToday:) withObject:nil];
	[self.treatmentDatePicker addTarget:self action:@selector(updateTreatmentsArray:) forControlEvents:UIControlEventValueChanged];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
	self.companyId = [myDictionary valueForKeyPath:@"vw_company_id"];
    self.shopId = [myDictionary valueForKeyPath:@"vw_shop_id"];
    self.searching = true;
	[self selectPractitioner:nil];
	[self BackGroundProcess];
}

#pragma mark - Actions

- (IBAction)selectPractitioner:(id)sender {
	self.searchPractitioners = true;
}

- (IBAction)selectClient:(id)sender {
	self.searchPractitioners = false;
}

- (void)setSearchPractitioners:(BOOL)searchPractitioners {
	_searchPractitioners = searchPractitioners;

	UIColor *activeColour = UIColorFromRGB(0xBF3CBA);
	UIColor *inactiveColour = [activeColour colorWithAlphaComponent:0.3];
	self.practitionersButton.backgroundColor = searchPractitioners ? activeColour : inactiveColour;
	self.clientsButton.backgroundColor = !searchPractitioners ? activeColour : inactiveColour;

	self.filteredPractitionersArray = nil;
	self.filteredClientsArray = nil;
	self.filteredTreatmentsArray = nil;
	self.selectedPractitionerId = nil;
	self.selectedClientId = nil;

	self.searchBar.text = nil;

	self.selectedItemView.superview.hidden = true;
	self.treatmentDatePicker.hidden = true;
	[self.tableView reloadData];
}

- (void)updateTreatmentsArray:(id)sender {
//	NSMutableArray *schedule_pract_client = [[NSMutableArray alloc] init];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *theDate = [dateFormat stringFromDate:self.treatmentDatePicker.date];
	DLog(@"%@", theDate);
	NSPredicate *predicate2;
	if (self.searchPractitioners) {
		predicate2 = [NSPredicate predicateWithFormat:@"pract_id == %@", self.selectedPractitionerId];
	} else {
		predicate2 = [NSPredicate predicateWithFormat:@"client_id == %@", self.selectedClientId];
	}
	NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"treatment_date contains[c] %@", theDate];
	NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate2, predicate1]];
	// searchResults = [recipes filteredArrayUsingPredicate:resultPredicate];
	self.filteredTreatmentsArray = [self.treatmentsArray filteredArrayUsingPredicate:predicate];
	//  NSMutableArray *pract_client_list = [[NSMutableArray alloc] init]; //alloc
//	for (int i = 0; i < self.filteredTreatmentsArray.count; i++) {
//		NSString *practitionerId = [(NSNumber *)[self.filteredTreatmentsArray[i] valueForKeyPath:@"pract_id"] stringValue];
//		NSString *clientId = [(NSNumber *)[self.filteredTreatmentsArray[i] valueForKeyPath:@"client_id"] stringValue];
//		if ([practitionerId isEqualToString:self.selectedPractitionerId]) {
//			for (int j = 0; j < self.clientsArray.count; j++) {
//				NSString *itemId = [(NSNumber *)[self.clientsArray[j] valueForKeyPath:@"id"] stringValue];
//				if ([clientId isEqualToString:itemId]) {
//					[schedule_pract_client addObject:itemId];
//					// NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[client_data_list_schedule[j] valueForKeyPath:@"id"], @"id", [client_data_list_schedule[j] valueForKeyPath:@"username"], @"username", [client_data_list_schedule[j] valueForKeyPath:@"photo_url"], @"photo_url",
//					// 								nil];
//					//   NSArray *array = @[];
//					// [array ad:jsonDictionary];
//				}
//			}
//		}
//	}
	DLog(@"Count %lu", (unsigned long)self.filteredTreatmentsArray.count);
	[self.tableView reloadData];
	// self.birth.text = theDate;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.tableView) {
		if (self.isSearching) {
            if ([NSString isEmpty:self.searchBar.text]) {
                self.filteredPractitionersArray = self.practitionersArray;
                self.filteredClientsArray = self.clientsArray;
            }
            NSArray *array = self.searchPractitioners ? self.filteredPractitionersArray : self.filteredClientsArray;
			return array.count;
		}
		return self.filteredTreatmentsArray.count;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.tableView) {
		if (self.isSearching) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Search Cell" forIndexPath:indexPath];
			UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
			UILabel *nameLabel = (UILabel *)[cell viewWithTag:11];

			if (self.searchPractitioners) {
				NSDictionary *itemDict = self.filteredPractitionersArray[indexPath.row];
				nameLabel.text = [itemDict valueForKeyPath:@"name"];
				NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"avatar"]];
				[imageView sd_setImageWithURL:imageUrl
							 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
			} else {
				NSDictionary *itemDict = self.filteredClientsArray[indexPath.row];
				nameLabel.text = [itemDict valueForKeyPath:@"username"];
				NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"photo_url"]];
				[imageView sd_setImageWithURL:imageUrl
							 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
			}
			return cell;
		} else {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Treatment Cell" forIndexPath:indexPath];
			UIImageView *imageView = (UIImageView *)[cell viewWithTag:10];
			UILabel *nameLabel = (UILabel *)[cell viewWithTag:11];
			UILabel *treatmentLabel = (UILabel *)[cell viewWithTag:12];
			UILabel *timeLabel = (UILabel *)[cell viewWithTag:13];

			NSDictionary *itemDict = self.filteredTreatmentsArray[indexPath.row];
			if (self.searchPractitioners) {
				NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"client.photo_url"]];
				[imageView sd_setImageWithURL:imageUrl
							 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
				nameLabel.text = [NSString stringWithFormat:@"[%@] %@", [itemDict valueForKeyPath:@"client.member_no"], [itemDict valueForKeyPath:@"client.username"]];
				treatmentLabel.text = [itemDict valueForKeyPath:@"treatment_type.name"];
                NSString *treatment_date = [itemDict valueForKeyPath:@"treatment_date"];
                timeLabel.text = [treatment_date substringToIndex:(treatment_date.length - 3)];
			} else {
				NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"practitioner.avatar"]];
				[imageView sd_setImageWithURL:imageUrl
							 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
				nameLabel.text = [itemDict valueForKeyPath:@"practitioner.name"];
                NSString *treatment_date = [itemDict valueForKeyPath:@"treatment_date"];
                timeLabel.text = [treatment_date substringToIndex:(treatment_date.length - 3)];
			}

			return cell;
		}
	}

	return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:false];
	if (self.isSearching) {
		self.selectedItemView.superview.hidden = false;
		self.treatmentDatePicker.hidden = false;
		if (self.searchPractitioners) {
			NSDictionary *itemDict = self.filteredPractitionersArray[indexPath.row];
			self.selectedNameLabel.text = [itemDict valueForKeyPath:@"name"];
			NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"avatar"]];
			[self.selectedItemImageView sd_setImageWithURL:imageUrl
										  placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];
			self.selectedPractitionerId = [itemDict valueForKeyPath:@"vw_user_id"];
		} else {
			NSDictionary *itemDict = self.filteredClientsArray[indexPath.row];
			self.selectedNameLabel.text = [itemDict valueForKeyPath:@"username"];
			NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"photo_url"]];
			[self.selectedItemImageView sd_setImageWithURL:imageUrl
										  placeholderImage:[UIImage imageNamed:@"female_avatar"]];
			self.selectedClientId = [itemDict valueForKeyPath:@"id"];
		}
		self.treatmentDatePicker.maximumDate = [NSDate date];
		[self updateTreatmentsArray:self.treatmentDatePicker];
		self.searching = false;
		[self.tableView reloadData];
	} else {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *itemDict = self.filteredTreatmentsArray[indexPath.row];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [itemDict valueForKeyPath:@"client_id"]];
		DLog(@"Pridicate %@", predicate);
		NSArray *filteredArray = [self.clientsArray filteredArrayUsingPredicate:predicate];
		DLog(@"Client : %@", filteredArray);
        if ([filteredArray count] <= 0) {
            [self showDismissAlertWithTitle:@"Oops !!"
                                    message:@"You have no permission to access this patient."];
            return;
        }
		NSData *clientdata = [NSKeyedArchiver archivedDataWithRootObject:filteredArray];
		[userDefaults setObject:clientdata forKey:@"selected_treatment_client"];
		[userDefaults synchronize];
		NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:self.filteredTreatmentsArray];
		[userDefaults setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"selected_treatment_report_row"];
		[userDefaults setObject:myData forKey:@"selected_treatment_report"];
		[userDefaults synchronize];

		[self performSegueWithIdentifier:@"Show Treatment" sender:nil];
	}
	DLog(@"%ld", (long)indexPath.row);
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	self.searching = true;
	self.selectedItemView.superview.hidden = true;
	self.treatmentDatePicker.hidden = true;
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if (self.searchPractitioners) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
		self.filteredPractitionersArray = [self.practitionersArray filteredArrayUsingPredicate:predicate];
		DLog(@"Count %lu", (unsigned long)self.filteredPractitionersArray.count);
	} else {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchText];
		self.filteredClientsArray = [self.clientsArray filteredArrayUsingPredicate:predicate];
		DLog(@"Count %lu", (unsigned long)self.filteredClientsArray.count);
	}
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
	NSURL *url = [Server url:@"/techface_api/getClient?company_id=%@&shop_id=%@", self.companyId, self.shopId];
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
										  self.clientsArray = [s objectForKey:@"client_data"];
										  self.treatmentsArray = [s objectForKey:@"client_treat_data"];
										  self.practitionersArray = [s objectForKey:@"pract_data"];
										  [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
									  }];
	[dataTask resume];
 
}

- (void)executeInMain {
	//   DLog(@"Total pract : %@", client_data_list_cap);
	//   [self.clienttable reloadData];
	[self selectPractitioner:nil];
}

@end
