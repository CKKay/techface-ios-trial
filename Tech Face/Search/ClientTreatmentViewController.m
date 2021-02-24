//
//  ClientTreatmentViewController.m
//  Tech Face
//
//  Created by MedEXO on 12/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "ClientTreatmentViewController.h"
#import "CompareImagesViewController.h"
#import "Server.h"
#import "NSDate+Extended.h"
#import "UIImage+Extended.h"
#import "UIImageView+Extended.h"
#import "NSString+Extended.h"
#import "UIViewController+Extended.h"
#import <SVProgressHUD/SVProgressHUD.h>

@import AVFoundation;
@import AVKit;

@interface ClientTreatmentViewController ()

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
@property (weak, nonatomic) IBOutlet UILabel *treatmentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientRemarkLabel;

// Treatments section
@property (weak, nonatomic) IBOutlet UIButton *prevTreatmentButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTreatmentButton;

// Video section
@property (weak, nonatomic) IBOutlet UIImageView *prevVideoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextVideoImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevVideoDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextVideoDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevVideoPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *nextVideoPlayButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *prevVideoIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextVideoIndicator;

// Photo - Front section
@property (weak, nonatomic) IBOutlet UIStackView *frontStackView;
@property (weak, nonatomic) IBOutlet UIImageView *prevFrontImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextFrontImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevFrontDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextFrontDateLabel;

// Photo - Half Left section
@property (weak, nonatomic) IBOutlet UIStackView *hLeftStackView;
@property (weak, nonatomic) IBOutlet UIImageView *prevHLeftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextHLeftImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevHLeftDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextHLeftDateLabel;

// Photo - Half Right section
@property (weak, nonatomic) IBOutlet UIStackView *hRightStackView;
@property (weak, nonatomic) IBOutlet UIImageView *prevHRightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextHRightImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevHRightDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextHRightDateLabel;

// Photo - Left section
@property (weak, nonatomic) IBOutlet UIStackView *leftStackView;
@property (weak, nonatomic) IBOutlet UIImageView *prevLeftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextLeftImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevLeftDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextLeftDateLabel;

// Photo - Right section
@property (weak, nonatomic) IBOutlet UIStackView *rightStackView;
@property (weak, nonatomic) IBOutlet UIImageView *prevRightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nextRightImageView;
@property (weak, nonatomic) IBOutlet UILabel *prevRightDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextRightDateLabel;

@property (strong, nonatomic) NSArray *treatments;

@property (weak, nonatomic) NSDictionary *prevTreatment;
@property (weak, nonatomic) NSDictionary *nextTreatment;

@end

@implementation ClientTreatmentViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSData *clientsData = [userDefaults dataForKey:@"selected_client"];
	NSInteger clientIndex = [[userDefaults objectForKey:@"selected_client_id"] intValue];
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
	// self.clientAgeLabel.text = [myDictionary  valueForKeyPath:@"birth"];
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

	NSData *treatmentsData = [userDefaults dataForKey:@"selected_treatment"];
	NSUInteger selectedIndex = [[userDefaults objectForKey:@"selected_treatment_id"] intValue];
	self.treatments = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:treatmentsData];
	DLog(@"Array : %@", self.treatments);

	NSDictionary *itemDict = self.treatments[selectedIndex];
	NSURL *pract_imageUrl = [Server url:@"/storage/avatar/%@", [itemDict valueForKeyPath:@"practitioner.avatar"]];
	DLog(@"%@", pract_imageUrl);
	self.practitionerNameLabel.text = [itemDict valueForKeyPath:@"practitioner.name"];
	self.practitionerNameLabel2.text = [itemDict valueForKeyPath:@"practitioner.name"];
	[self.practitionerImageView sd_setImageWithURL:pract_imageUrl
						placeholderImage:[UIImage imageNamed:@"doctor_avatar"]];

	self.treatmentDateLabel.text = [itemDict valueForKeyPath:@"treatment_date"];
	self.treatmentTypeLabel.text = [itemDict valueForKeyPath:@"treatment_type.name"];
	self.clientRemarkLabel.text = [itemDict valueForKeyPath:@"treatment_details"];
    NSArray *treatAssignArray = [itemDict valueForKeyPath:@"treatment_type_assigned"];
    
    NSMutableString *treatmentName=[[NSMutableString alloc] init];
    for(NSArray *assignItems in treatAssignArray){
                NSArray *treatArray = [assignItems valueForKey:@"treatment_type"];
                NSString *treatmentypeName = [treatArray valueForKey:@"name"];
                [treatmentName appendString:[NSString stringWithFormat:@"%@\n",treatmentypeName]];
    }
    
    if(![NSString isEmpty:treatmentName]){
      self.treatmentTypeLabel.text=treatmentName;
    }
    
    
    self.clientRemarkLabel.backgroundColor = UIColor.whiteColor;
	DLog(@"selectedIndex : %ld", (long)selectedIndex);
	DLog(@"self.treatments.count = %lu", (unsigned long)self.treatments.count);

	/*
	 A potential bug happens here when there are N treatments, where N > 2.

	 If there is only one item, it is considered as "Before".

	 If users selected the last item, where index + 1 = count, the selected item (last item)
	 is considered as "After" (i.e. next) and the previous (index-1) item is considered as
	 "Before".  This suggested the array is sorted from oldest to newest.

	 In original code, however, intermediate rows suggest the current index as "After" and
	 (index + 1) as "Before".  This is contradict with the above logic.  Only either one is
	 true but not both.  We picked oldest-to-newest.

	 Simply flip the assignment of prev/next if the above was wrong, i.e. treatments are
	 sorted from newest to oldest.
	 */

	self.prevTreatment = itemDict;
	if (selectedIndex > 0) {
		self.nextTreatment = self.treatments[selectedIndex - 1];
	}
//	if (self.treatments.count <= 1) {
//		DLog(@"Only one raw");
//		self.prevTreatment = itemDict;
//		self.nextTreatment = nil;
//	} else if (selectedIndex + 1 == self.treatments.count) {
//		DLog(@"Last row");
//		self.prevTreatment = itemDict;
//		self.nextTreatment = self.treatments[selectedIndex - 1];
//	} else {
//		DLog(@"intermediate row");
//		self.prevTreatment = self.treatments[selectedIndex + 1];
//		self.nextTreatment = itemDict;
//	}

	[self addTapGestureToCompareImageForView:self.frontStackView];
	[self addTapGestureToCompareImageForView:self.leftStackView];
	[self addTapGestureToCompareImageForView:self.rightStackView];
	[self addTapGestureToCompareImageForView:self.hLeftStackView];
	[self addTapGestureToCompareImageForView:self.hRightStackView];
}

- (void)addTapGestureToCompareImageForView:(UIView *)view {
	[self addTapGestureToView:view action:@selector(compareImagesAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTreatmentSelected:) name:@"selecttreatment" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"Compare Images"]) {
		CompareImagesViewController *vc = (CompareImagesViewController *)segue.destinationViewController;
		if (sender == self.frontStackView) {
			vc.imagePath = @"treatment_directory";
			vc.itemKey = @"photo_front_url";
		} else if (sender == self.leftStackView) {
			vc.imagePath = @"treatment_directory";
			vc.itemKey = @"photo_left_url";
		} else if (sender == self.rightStackView) {
			vc.imagePath = @"treatment_directory";
			vc.itemKey = @"photo_right_url";
		} else if (sender == self.hLeftStackView) {
			vc.imagePath = @"treatment_directory";
			vc.itemKey = @"photo_half_left_url";
		} else if (sender == self.hRightStackView) {
			vc.imagePath = @"treatment_directory";
			vc.itemKey = @"photo_half_right_url";
		}
		vc.prevItemDict = self.prevTreatment;
		vc.nextItemDict = self.nextTreatment;
	}
}

#pragma mark - Actions

- (IBAction)selectTreatmentAction:(id)sender {
	NSString *value = (sender == self.prevTreatmentButton ? @"before" : @"after");
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:value forKey:@"select_treatment_client"];
	[userDefaults synchronize];
	[self performSegueWithIdentifier:@"Select Treatment" sender:self];
}

- (IBAction)playVideoAction:(id)sender {
	NSDictionary *dict = (sender == self.prevVideoPlayButton ? self.prevTreatment : self.nextTreatment);
	if (dict) {
        
        NSString *storageType = [dict valueForKey:@"storagetype"];
         
        NSURL *url = nil;
        if( [storageType isEqualToString:@"OTHER"] ){
             NSString *treatmenturl = [dict valueForKey:@"treatmentfileurl"];
            
            url = [NSURL URLWithString:[treatmenturl valueForKey:@"video_url"] ];
          //  url  = [treatmenturl valueForKey:@"photo_front_url"];
         } else {
            url = [Server url:@"/uploads/%@/%@", [dict valueForKeyPath:@"treatment_directory"], [dict valueForKeyPath:@"video_url"]];
         }
        

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

- (IBAction)compareImagesAction:(id)sender {
	UIGestureRecognizer *gesture = (UIGestureRecognizer *)sender;
	[self performSegueWithIdentifier:@"Compare Images" sender:gesture.view];
}

- (void)onTreatmentSelected:(NSNotification *)notification {
	DLog(@"onTreatmentSelected");
	NSDictionary *dict = notification.userInfo;
	int post_id = [[dict objectForKey:@"treatmentid"] intValue];
	if (post_id == 111) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSInteger index = [[userDefaults objectForKey:@"select_treatment_client_id"] intValue];
		if ([[userDefaults objectForKey:@"select_treatment_client"] isEqualToString:@"after"]) {
			DLog(@"After %ld", (long)index);
			self.nextTreatment = self.treatments[index];
		} else {
			DLog(@"Before %ld", (long)index);
			self.prevTreatment = self.treatments[index];
		}
	}
}

#pragma mark - Setters

- (void)setPrevTreatment:(NSDictionary *)dict {
	_prevTreatment = dict;
    
    
    //NSArray *array = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
   // NSArray *urlArray = [[dict objectForKey:@"treatmentfileurl"] valueForKey:@"photo_front_url"];
   // DLog(@"get url array log %@",urlArray);
    
    NSString *storageType = [dict valueForKey:@"storagetype"];
    
    [self setPrevTreatmentDate:[dict valueForKeyPath:@"treatment_date"]];
    if( [storageType isEqualToString:@"OTHER"] ){
        NSString *treatmenturl = [dict valueForKey:@"treatmentfileurl"];
       [self.prevFrontImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_front_url"]]];
        [self.prevLeftImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_left_url"]]];
        [self.prevRightImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_right_url"]]];
        [self.prevHLeftImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_half_left_url"]]];
        [self.prevHRightImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_half_right_url"]]];
    
    
    } else {
    
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
    
    
     }
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.prevVideoIndicator startAnimating];
		[self performSelectorInBackground:@selector(loadPrevVideoImage) withObject:nil];
	});
}

- (void)setNextTreatment:(NSDictionary *)dict {
	_nextTreatment = dict;
    
    NSString *storageType = [dict valueForKey:@"storagetype"];
    
    [self setNextTreatmentDate:[dict valueForKeyPath:@"treatment_date"]];
    if( [storageType isEqualToString:@"OTHER"] ){
        NSString *treatmenturl = [dict valueForKey:@"treatmentfileurl"];
       [self.nextFrontImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_front_url"]]];
        [self.nextLeftImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_left_url"]]];
        [self.nextRightImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_right_url"]]];
        [self.nextHLeftImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_half_left_url"]]];
        [self.nextHRightImageView setImageWithOtherPath: [NSURL URLWithString:[treatmenturl valueForKey:@"photo_half_right_url"]]];
    
    
    } else {

        [self.nextFrontImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
                                             name:[dict valueForKeyPath:@"photo_front_url"]];
        [self.nextLeftImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
                                            name:[dict valueForKeyPath:@"photo_left_url"]];
        [self.nextRightImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
                                             name:[dict valueForKeyPath:@"photo_right_url"]];
        [self.nextHLeftImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
                                             name:[dict valueForKeyPath:@"photo_half_left_url"]];
        [self.nextHRightImageView setImageWithPath:[dict valueForKeyPath:@"treatment_directory"]
                                              name:[dict valueForKeyPath:@"photo_half_right_url"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nextVideoIndicator startAnimating];
            [self performSelectorInBackground:@selector(loadNextVideoImage) withObject:nil];
        });
}

- (void)setPrevTreatmentDate:(nullable NSString *)date {
	NSString *text = [self displayDateStringFromDate:date];
	// Ensure these run on main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.prevTreatmentButton setTitle:text forState:UIControlStateNormal];
		self.prevVideoDateLabel.text = text;
		self.prevFrontDateLabel.text = text;
		self.prevLeftDateLabel.text = text;
		self.prevRightDateLabel.text = text;
		self.prevHLeftDateLabel.text = text;
		self.prevHRightDateLabel.text = text;
	});
}

- (void)setNextTreatmentDate:(nullable NSString *)date {
	NSString *text = [self displayDateStringFromDate:date];
	// Ensure these run on main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.nextTreatmentButton setTitle:text forState:UIControlStateNormal];
		self.nextVideoDateLabel.text = text;
		self.nextFrontDateLabel.text = text;
		self.nextLeftDateLabel.text = text;
		self.nextRightDateLabel.text = text;
		self.nextHLeftDateLabel.text = text;
		self.nextHRightDateLabel.text = text;
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

- (void)loadNextVideoImage {
	UIImage *image = [self videoThumbnailWithTreatment:self.nextTreatment];
	// Ensure these run on main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		self.nextVideoImageView.image = image;
		self.nextVideoPlayButton.hidden = (image == nil);
		[self.nextVideoIndicator stopAnimating];
	});
}

- (nullable UIImage *)videoThumbnailWithTreatment:(NSDictionary *)dict {
    NSString *directory = [dict valueForKeyPath:@"treatment_directory"];
	NSString *name = [dict valueForKeyPath:@"video_url"];
    NSString *storageType = [dict valueForKey:@"storagetype"];
     NSURL *url = nil;
     if( [storageType isEqualToString:@"OTHER"] ){
         NSString *treatmenturl = [dict valueForKey:@"treatmentfileurl"];
         url = [NSURL URLWithString:[treatmenturl valueForKey:@"video_url"] ];
       //  url = [treatmenturl valueForKey:@"video_url"];
     } else {

         url = [Server url:@"/uploads/%@/%@", directory, name];
     }
	return [UIImage assetImageFromURL:url];
}

#pragma mark - Helpers

- (NSString *)displayDateStringFromDate:(nullable NSString *)date {
    return [NSString isEmpty:date] ? @"-" : [date substringToIndex:10];
}

@end
