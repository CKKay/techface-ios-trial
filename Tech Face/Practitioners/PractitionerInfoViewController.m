//
//  PractitionerInfoViewController.m
//  Tech Face
//
//  Created by MedEXO on 25/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "PractitionerInfoViewController.h"
#import "Reachability.h"
#import "ToastView.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface PractitionerInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *companyname;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *emailid;
@property (weak, nonatomic) IBOutlet UILabel *phonenumber;
@property (weak, nonatomic) IBOutlet UILabel *birthdate;
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *district;
@property (weak, nonatomic) IBOutlet UILabel *Professtion;
@property (weak, nonatomic) IBOutlet UIButton *save;

@end

@implementation PractitionerInfoViewController

- (IBAction)back:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)save:(id)sender {
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (_pract_theImage != nil) {
		self.profilepic.image = self.pract_theImage;
		self.username.text = self.s_pract_username;
		self.emailid.text = self.s_pract_email;
		self.phonenumber.text = self.s_pract_phone;
		self.birthdate.text = self.s_pract_birth;
		self.country.text = self.s_pract_country;
		self.city.text = self.s_pract_city;
		self.district.text = self.s_pract_district;
		self.Professtion.text = self.s_pract_profession;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)AddProfilePic:(id)sender {
}

@end
