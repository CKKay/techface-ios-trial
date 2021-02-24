//
//  UIViewController+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-4.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "UIViewController+Extended.h"

@implementation UIViewController (Extended)

#pragma mark - UI

/*
 Changes the back button to empty text. Must called from parent view controller.
 */
- (void)setupEmptyBackButtonOnPushed {
	[self setupBackButtonOnPushed:nil];
}

/*
 Changes the back button to any text. Must called from parent view controller.
 Default value is "Back",
 */
- (void)setupBackButtonOnPushed:(nullable NSString *)text {
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:text style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = item;
}

- (UITapGestureRecognizer *)addTapGestureToView:(UIView *)view action:(nullable SEL)action {
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
	gesture.numberOfTapsRequired = 1;
	[view setUserInteractionEnabled:true];
	[view addGestureRecognizer:gesture];
	return gesture;
}

#pragma mark - Keyboard Handling and Scrolling

- (void)setTapToDismissKeyboardForView:(UIView *)view {
	// Setup background to dismiss keyboard
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:@selector(dismissKeyboard)];
	tap.cancelsTouchesInView = false;
	[view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
	[self.view endEditing:true];
}

#pragma mark - Helpers

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title
								  message:(nullable NSString *)message
						cancelButtonTitle:(nullable NSString *)cancelButtonTitle
							cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler
							okButtonTitle:(nullable NSString *)okButtonTitle
								okHandler:(nullable void (^)(UIAlertAction *action))okHandler {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	if (cancelButtonTitle) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:cancelHandler];
		[alert addAction:action];
	}
	if (okButtonTitle) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:okHandler];
		[alert addAction:action];
	}
	[self presentViewController:alert animated:true completion:nil];
	return alert;
}

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title
								  message:(nullable NSString *)message
						cancelButtonTitle:(nullable NSString *)cancelButtonTitle
							cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler
						 destructiveTitle:(nullable NSString *)destructiveTitle
					   destructiveHandler:(nullable void (^)(UIAlertAction *action))destructiveHandler {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	if (cancelButtonTitle) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:cancelHandler];
		[alert addAction:action];
	}
	if (destructiveTitle) {
		UIAlertAction *action = [UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:destructiveHandler];
		[alert addAction:action];
	}
	[self presentViewController:alert animated:true completion:nil];
	return alert;
}

- (UIAlertController *)showDismissAlertWithTitle:(nullable NSString *)title
										 message:(nullable NSString *)message {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:action];
	[self presentViewController:alert animated:true completion:nil];
	return alert;
}

@end
