//
//  SelectTreatmentViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "SelectTreatmentViewController.h"
#import "Reachability.h"
#import "Server.h"
#import "ToastView.h"
#import "NSDate+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface SelectTreatmentViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *treatmentId;

@property (strong, nonatomic) NSArray *items;

@end

@implementation SelectTreatmentViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.tableView setBackgroundView:nil];
	// Setup tableview to use auto height
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:100];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSInteger itemIndex = [[userDefaults objectForKey:@"selected_client_id"] intValue];
	NSData *data = [userDefaults dataForKey:@"selected_client"];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSDictionary *myDictionary = array[itemIndex];
	self.treatmentId = [myDictionary valueForKeyPath:@"id"];
	[self BackGroundProcess];
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

- (IBAction)dismissAction:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 118;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	// Configure the cell...
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	NSDictionary *itemDict = self.items[indexPath.row];
	UILabel *practname = (UILabel *)[cell viewWithTag:11];
	UILabel *treatment = (UILabel *)[cell viewWithTag:13];
	UILabel *recipeNameLabel = (UILabel *)[cell viewWithTag:12];
	UIImageView *Frontimage = (UIImageView *)[cell viewWithTag:10];
    
    NSString *treatment_date = [itemDict valueForKeyPath:@"treatment_date"];
    recipeNameLabel.text = [treatment_date substringToIndex:(treatment_date.length - 3)];
    NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"practitioner.avatar"]];
    [Frontimage sd_setImageWithURL:imageUrl
                 placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];
	practname.text = [itemDict valueForKeyPath:@"practitioner.name"];
	treatment.text =  [itemDict valueForKeyPath:@"treatment_type.name"];
	[cell setBackgroundColor:[UIColor clearColor]];
	[cell.contentView setBackgroundColor:[UIColor clearColor]];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];
	NSNumber *itemIndex = [NSNumber numberWithInteger:indexPath.row];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:itemIndex forKey:@"select_treatment_client_id"];
	[userDefaults synchronize];
	[self dismissViewControllerAnimated:true completion:^{
		DLog(@"Dismiss completed");
		NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:111] forKey:@"treatmentid"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"selecttreatment"
															object:nil
														  userInfo:dictionary];
	}];
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
	NSURL *url = [Server url:@"/techface_api/getClientTreatment?client_id=%@", self.treatmentId];
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
										  //  DLog(@"Respose : %@", response);
										  //   DLog(@"Data : %@", data);
										  //   DLog(@"Error : %@", error);
										  DLog(@"String sent from server %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
										  [SVProgressHUD dismiss];
										  NSDictionary *s = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
										  NSString *ad = [s objectForKey:@"message"];
										  if ([ad isEqualToString:@"Client Treatment Details"]) {
											  self.items = [s objectForKey:@"client_treatment_data"];
											  DLog(@"%@", self.items);
											  [self performSelectorOnMainThread:@selector(executeInMain) withObject:nil waitUntilDone:true];
										  }
									  }];
	[dataTask resume];
   
}

- (void)executeInMain {
	[self.tableView reloadData];
}

- (void)FillImageView:(UIImageView *)imageview pathname:(NSString *)path imagename:(NSString *)imagename {
	NSURL *url = [Server url:@"/uploads/%@/%@", path, imagename];
	DLog(@"%@", url.absoluteString);
	[imageview sd_setImageWithURL:url
				 placeholderImage:[UIImage imageNamed:@"female_avatar"]];
}

@end
