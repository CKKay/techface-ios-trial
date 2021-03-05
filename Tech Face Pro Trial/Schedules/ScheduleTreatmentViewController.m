//
//  ScheduleTreatmentViewController.m
//  Tech Face
//
//  Created by MedEXO on 24/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ScheduleTreatmentViewController.h"
#import "Server.h"
#import "UIImage+Extended.h"
#import "UIImageView+Extended.h"
#import <SDWebImage/UIImageView+WebCache.h>

@import AVFoundation;
@import AVKit;

@interface ScheduleTreatmentViewController ()

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
@property (weak, nonatomic) IBOutlet UILabel *treatmentTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientRemarkLabel;

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

@property (strong, nonatomic) NSArray *treatments;

@property (weak, nonatomic) NSDictionary *prevTreatment;

@end

@implementation ScheduleTreatmentViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSData *clientsData = [userDefaults dataForKey:@"selected_treatment_client"];
	NSInteger clientIndex = 0;
	NSArray *clients = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
	NSDictionary *clientDict = clients[clientIndex];

	NSURL *imageUrl = [Server url:@"/storage/avatar/%@", [clientDict valueForKeyPath:@"photo_url"]];
	self.clientNameLabel.text = [clientDict valueForKeyPath:@"username"];
	[self.clientImageView sd_setImageWithURL:imageUrl
							placeholderImage:[UIImage imageNamed:@"female_avatar"]];
	self.clientGenderLabel.text = [clientDict valueForKeyPath:@"sex"];
	self.clientHeightLabel.text = [clientDict valueForKeyPath:@"height"];
	self.clientWeightLabel.text = [clientDict valueForKeyPath:@"weight"];
	self.clientBloodTypeLabel.text = [clientDict valueForKeyPath:@"blood"];
	self.clientBirthdateLabel.text = [clientDict valueForKeyPath:@"birth"];
	self.clientPhoneLabel.text = [clientDict valueForKeyPath:@"phone"];
	self.clientEmailLabel.text = [clientDict valueForKeyPath:@"email"];
	self.clientAddressLabel.text = [clientDict valueForKeyPath:@"address"];
    
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
    self.clientAgeLabel.text = [NSString stringWithFormat:@"%ld", (long)age];

	NSData *treatmentsData = [userDefaults dataForKey:@"selected_treatment_report"];
	NSUInteger selectedIndex = [[userDefaults objectForKey:@"selected_treatment_report_row"] intValue];
	self.treatments = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:treatmentsData];
	DLog(@"Array : %@", self.treatments);

	NSDictionary *itemDict = self.treatments[selectedIndex];
	NSURL *pract_imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"practitioner.avatar"]];
	DLog(@"%@", pract_imageUrl);
	self.practitionerNameLabel.text = [itemDict valueForKeyPath:@"practitioner.name"];
	self.practitionerNameLabel2.text = [itemDict valueForKeyPath:@"practitioner.name"];
	[self.practitionerImageView sd_setImageWithURL:pract_imageUrl
								  placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];

	self.treatmentTypeLabel.text = [itemDict valueForKeyPath:@"treatment_type.name"];
	self.clientRemarkLabel.text = [itemDict valueForKeyPath:@"treatment_details"];
	self.prevTreatment = itemDict;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
}

#pragma mark - Actions


- (IBAction)playVideoAction:(id)sender {
	NSDictionary *dict = self.prevTreatment;
	if (dict) {
		NSURL *url = [Server url:@"/uploads/%@/%@", [dict valueForKeyPath:@"treatment_directory"], [dict valueForKeyPath:@"video_url"]];
		if (url) {
			DLog(@"Playing %@", url.absoluteString);
			// create an AVPlayer
			AVPlayer *player = [AVPlayer playerWithURL:url];
			// create a player view controller
			AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
			controller.player = player;
			[player play];
			[self presentViewController:controller animated:true completion:nil];
			controller.view.frame = self.view.frame;
			[controller.player play];
		}
	}
}

#pragma mark - Setters

- (void)setPrevTreatment:(NSDictionary *)dict {
	_prevTreatment = dict;
//	NSDate *date = [[self parseDateFormatter] dateFromString:[dict valueForKeyPath:@"created_at"]];
//	[self setPrevTreatmentDate:date];
	[self.prevFrontImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
										 name:[dict valueForKeyPath:@"photo_front_url"]];
	[self.prevLeftImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
										name:[dict valueForKeyPath:@"photo_left_url"]];
	[self.prevRightImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
										 name:[dict valueForKeyPath:@"photo_right_url"]];
	[self.prevHLeftImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
										 name:[dict valueForKeyPath:@"photo_half_left_url"]];
	[self.prevHRightImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
										  name:[dict valueForKeyPath:@"photo_half_right_url"]];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.prevVideoIndicator startAnimating];
		[self performSelectorInBackground:@selector(loadPrevVideoImage) withObject:nil];
	});
}

- (void)loadPrevVideoImage {
	UIImage *image = [self videoThumbnailWithTreatment:self.prevTreatment];
	// Ensure these run on main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		self.prevVideoImageView.image = image;
		self.prevVideoPlayButton.hidden = (image == nil);
		[self.prevVideoIndicator stopAnimating];
	});
}

- (nullable UIImage *)videoThumbnailWithTreatment:(NSDictionary *)dict {
	NSString *directory = [dict valueForKeyPath:@"treatment_directory"];
    NSString *name = [dict valueForKeyPath:@"video_url"];
	NSURL *url = [Server url:@"/uploads/%@/%@", directory, name];
	return [UIImage assetImageFromURL:url];
}

@end
