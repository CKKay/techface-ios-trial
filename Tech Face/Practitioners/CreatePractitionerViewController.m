//
//  CreatePractitionerViewController.m
//  Tech Face
//
//  Created by John on 2019-6-28.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "CreatePractitionerViewController.h"
#import "PractitionerFormViewController.h"
#import "ConfirmPractitionerViewController.h"

@interface CreatePractitionerViewController ()

@end

@implementation CreatePractitionerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"Show Confirm"]) {
//		PractitionerFormViewController *source = (PractitionerFormViewController *)sender;
//		ConfirmPractitionerViewController *vc = (ConfirmPractitionerViewController *)segue.destinationViewController;
//		vc.theImage = source.profilepic.image;
//		vc.s_companyname = source.Companyname.text;
//		vc.s_password = source.password.text;
//		vc.s_username = source.Username.text;
//		vc.s_email = source.com_email.text;
//		vc.s_country = source.country.text;
//		vc.s_token = source.token.text;
//		vc.s_city = source.city.text;
//		vc.s_district = source.district.text;
//		vc.s_service = source.service.text;
	}
}

@end
