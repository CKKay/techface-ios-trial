//
//  UIViewController+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-4.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extended)

#pragma mark - UI

- (void)setupEmptyBackButtonOnPushed;
- (void)setupBackButtonOnPushed:(nullable NSString *)text;
- (UITapGestureRecognizer *)addTapGestureToView:(UIView *)view action:(nullable SEL)action;

#pragma mark - Keyboard Handling and Scrolling

- (void)setTapToDismissKeyboardForView:(UIView *)view;
- (void)dismissKeyboard;

#pragma mark - Helpers

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title
								  message:(nullable NSString *)message
						cancelButtonTitle:(nullable NSString *)cancelButtonTitle
							cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler
							okButtonTitle:(nullable NSString *)okButtonTitle
								okHandler:(nullable void (^)(UIAlertAction *action))okHandler;

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title
								  message:(nullable NSString *)message
						cancelButtonTitle:(nullable NSString *)cancelButtonTitle
							cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler
						 destructiveTitle:(nullable NSString *)destructiveTitle
					   destructiveHandler:(nullable void (^)(UIAlertAction *action))destructiveHandler;

- (UIAlertController *)showDismissAlertWithTitle:(nullable NSString *)title
										 message:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END
