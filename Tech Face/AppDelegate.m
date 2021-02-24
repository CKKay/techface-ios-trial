//
//  AppDelegate.m
//  Tech Face
//
//  Created by MedEXO on 16/07/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

#import "AppDelegate.h"
#import "AgreementViewController.h"
#import "CaptureViewController.h"
#import "VideoCaptureViewController.h"
#import "CompareNavigationController.h"
#import "CompareImagesViewController.h"
#import <BugfenderSDK/BugfenderSDK.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
   [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
//  [Instabug startWithToken:@"94459ab11c47e2060ec1472c6e1878d7" invocationEvents: IBGInvocationEventShake | IBGInvocationEventScreenshot];
//
//
    [Bugfender activateLogger:@"vcnmwaJRN2rjiaVaCEmqo08YFnMguBNG"];
    [Bugfender enableUIEventLogging];  // optional, log user interactions automatically
    [Bugfender enableCrashReporting];
    BFLog(@"Hello world!"); // use BFLog as you would use NSLog

    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	// Search for the top or current view controller
	UIViewController *vc = window.rootViewController;
	// Dig through tab bar and navigation, regardless their order
	while ([vc isKindOfClass:UITabBarController.class] || [vc isKindOfClass:UINavigationController.class]) {
		if ([vc isKindOfClass:UINavigationController.class]) {
			vc = ((UINavigationController *)vc).topViewController;
		} else if ([vc isKindOfClass:UITabBarController.class]) {
			vc = ((UITabBarController *)vc).selectedViewController;
		}
	}
	// Look for model view controller
	while (vc.presentedViewController != nil) {
		vc = vc.presentedViewController;
	}
	// Uncomment this for debug
	// NSLog(@"vc = %@", (vc != nil ? NSStringFromClass(vc.class) : @"nil"));
	if (!vc.isBeingDismissed) {
		if ([vc isKindOfClass:[CompareNavigationController class]] ||
			[vc isKindOfClass:[CompareImagesViewController class]]) {
			// NSLog(@"return UIInterfaceOrientationMaskLandscape");
			return UIInterfaceOrientationMaskLandscape;
		}
		if ([vc isKindOfClass:[UINavigationController class]]) {
			UINavigationController *nc = (UINavigationController *)vc;
			UIViewController * top = nc.topViewController;
			if ([top isKindOfClass:[AgreementViewController class]] ||
				[top isKindOfClass:[CaptureViewController class]] ||
				[top isKindOfClass:[VideoCaptureViewController class]]) {
				// NSLog(@"return UIInterfaceOrientationMaskLandscape");
				return UIInterfaceOrientationMaskPortrait;
			}
		}
	}
	if ([UIDevice.currentDevice userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return UIInterfaceOrientationMaskAll;
	}
	// NSLog(@"return UIInterfaceOrientationMaskPortrait");
	return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
}

@end
