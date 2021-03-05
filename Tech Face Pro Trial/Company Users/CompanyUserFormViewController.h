//
//  CompanyUserFormViewController.h
//  Tech Face
//
//  Created by MedEXO on 20/08/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

@import UIKit;

@interface CompanyUserFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *profilepic;
@property (weak, nonatomic) IBOutlet UITextField *com_email;
@property (weak, nonatomic) IBOutlet UITextField *Companyname;
@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *conformapassword;
@property (weak, nonatomic) IBOutlet UITextField *token;
@property (weak, nonatomic) IBOutlet UITextField *country;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *district;
@property (weak, nonatomic) IBOutlet UITextView *service;

@end
