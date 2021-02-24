//
//  SettingsViewController.m
//  Tech Face
//
//  Created by MedEXO on 07/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIViewController+Extended.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *languagesHeaderLabel;
@property (weak, nonatomic) IBOutlet UIStackView *languagesStack;
@property (weak, nonatomic) IBOutlet UIView *languagesDivider;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *buildStr = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *versionStr = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", versionStr, buildStr];

	self.languagesHeaderLabel.hidden = true;
	self.languagesStack.hidden = true;
	self.languagesDivider.hidden = true;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)logOutAction:(id)sender {
	UIAlertController *alert = [UIAlertController
								alertControllerWithTitle:nil
								message:@"Are you sure you want to log out?"
								preferredStyle:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
											  style:UIAlertActionStyleCancel
											handler:nil]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Log Out"
											  style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction * _Nonnull action) {
												[self doLogOut];
											}]];
	if (alert.popoverPresentationController) { // For iPad
		UIView *view = (UIView *)sender;
		alert.popoverPresentationController.sourceView = view;
		alert.popoverPresentationController.sourceRect = view.bounds;
	}
	[self presentViewController:alert animated:true completion:nil];
}

- (void)doLogOut {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults removeObjectForKey:@"signincheck"];
	[userDefaults synchronize];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
	UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"login"];
	[self presentViewController:vc animated:true completion:nil];
}

- (IBAction)termsAction:(id)sender {
	[self showDismissAlertWithTitle:nil message:@"No terms and conditions available."];
}

@end
