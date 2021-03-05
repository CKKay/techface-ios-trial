//
//  ClientProfileViewController.m
//  Tech Face
//
//  Created by MedEXO on 11/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ClientProfileViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSDate+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSString+Extended.h"

@interface ClientProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *client_pic;
@property (weak, nonatomic) IBOutlet UILabel *client_name;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *height;
@property (weak, nonatomic) IBOutlet UILabel *weight;
@property (weak, nonatomic) IBOutlet UILabel *blood;
@property (weak, nonatomic) IBOutlet UILabel *birthdate;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *treatment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *clientId;

@property (strong, nonatomic) NSArray *treatments;

@end

@implementation ClientProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupEmptyBackButtonOnPushed];
	// Setup tableview to use auto height
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:100];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSData *itemsData = [userDefaults dataForKey:@"selected_client"];
	NSInteger itemIndex = [[userDefaults objectForKey:@"selected_client_id"] intValue];
	NSArray *items = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:itemsData];

	NSDictionary *clientDict = items[itemIndex];
	DLog(@"%@", clientDict);
	self.clientId = [clientDict valueForKeyPath:@"id"];

	NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [clientDict valueForKeyPath:@"photo_url"]];

	[self.client_pic sd_setImageWithURL:imageUrl
					   placeholderImage:[UIImage imageNamed:@"female_avatar"]];
	self.client_name.text = [clientDict valueForKeyPath:@"username"];
	self.sex.text = [clientDict valueForKeyPath:@"sex"];
	self.height.text = [clientDict valueForKeyPath:@"height"];
	self.weight.text = [clientDict valueForKeyPath:@"weight"];
	self.blood.text = [clientDict valueForKeyPath:@"blood"];
	self.birthdate.text = [clientDict valueForKeyPath:@"birth"];

	NSString *time = [clientDict valueForKeyPath:@"birth"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *bdate = [dateFormatter dateFromString:time];
    DLog(@"%@", bdate);
    NSDate *now = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:bdate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
	self.age.text = [NSString stringWithFormat:@"%ld", (long)age];

	[self BackGroundProcess];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.treatments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	// Configure the cell...
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	// Display treatment in the table cell
    UILabel *treatmentLabel = (UILabel *)[cell viewWithTag:11];
	UILabel *timeLabel = (UILabel *)[cell viewWithTag:12];
	NSArray *array = self.treatments;
	NSDictionary *itemDict = array[indexPath.row];
    treatmentLabel.text = [itemDict valueForKeyPath:@"treatment_type.name"];
    
    NSArray *treatAssignArray = [itemDict valueForKeyPath:@"treatment_type_assigned"];
    
    NSMutableString *treatmentName=[[NSMutableString alloc] init];
    for(NSArray *assignItems in treatAssignArray){
                NSArray *treatArray = [assignItems valueForKey:@"treatment_type"];
                NSString *treatmentypeName = [treatArray valueForKey:@"name"];
                [treatmentName appendString:[NSString stringWithFormat:@"%@ ",treatmentypeName]];
    }
    
    if(![NSString isEmpty:treatmentName]){
      treatmentLabel.text=treatmentName;
    }
    
    
    NSString *treatment_date = [itemDict valueForKeyPath:@"treatment_date"];
    timeLabel.text = [treatment_date substringToIndex:(treatment_date.length - 3)];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];

	NSArray *array = self.treatments;
	NSData *itemsData = [NSKeyedArchiver archivedDataWithRootObject:array];
	NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:itemIndex forKey:@"selected_treatment_id"];
	[userDefaults setObject:itemsData forKey:@"selected_treatment"];
	[userDefaults synchronize];
	
	[self performSegueWithIdentifier:@"Show Treatment" sender:self];
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
	NSURL *url = [Server url:@"/techface_api/getClientTreatment?client_id=%@", self.clientId];
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
										  NSString *ad = [s objectForKey:@"message"];
										  if ([ad isEqualToString:@"Client Treatment Details"]) {
											  self.treatments = [s objectForKey:@"client_treatment_data"];
											  DLog(@"%@", self.treatments);
											  [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
										  }
									  }];
	[dataTask resume];
  
}

- (void)executeInMain {
	[self.tableView reloadData];
}

@end
