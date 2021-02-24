//
//  HomeCaptureViewController.m
//  Tech Face
//
//  Created by John on 2019-6-5.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "HomeCaptureViewController.h"
#import "UIViewController+Extended.h"
#import "RoundCornerButton.h"
#import "NSData+Extended.h"
#import "NSString+Extended.h"

@interface HomeCaptureViewController ()

@property (weak, nonatomic) IBOutlet RoundCornerButton *btnCurrentClients;
@property (strong, nonatomic) NSString *tf_token;
@property (strong, nonatomic) NSString *logout;
@property (strong, nonatomic) NSString *message;

@end

@implementation HomeCaptureViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isSelectedPrac) {
        self.isSelectedPrac = false;
        [self.btnCurrentClients sendActionsForControlEvents:(UIControlEventTouchUpInside)];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         NSDictionary *myDictionary = [userDefaults dictionaryForKey:@"homedata"];
         self.tf_token = [myDictionary valueForKeyPath:@"tf_token"];
         self.logout = [userDefaults objectForKey:@"logout"];
        self.message = [userDefaults objectForKey:@"message"];
        
        [userDefaults setObject:@"0" forKey:@"selected_client_id"];
        [userDefaults setObject:@"0" forKey:@"selected_pract_id"];
        [userDefaults setObject:@"0" forKey:@"pract_shop_id"];
        [userDefaults synchronize];
        
        if ([self.logout isEqualToString:@"Y"]){
             [self showAlertWithTitle:@"Message !!"
                              message:[NSString stringWithFormat:@"%@", self.message]
                cancelButtonTitle:@"Quit App"
                        cancelHandler:^(UIAlertAction * _Nonnull action) {
                             exit(0);
                        }
                        okButtonTitle:@"Log in again"
                            okHandler:^(UIAlertAction * _Nonnull action) {
                               // exit(0);
                         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                         [userDefaults removeObjectForKey:@"signincheck"];
                         [userDefaults synchronize];
                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
                         UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"login"];
                         [self presentViewController:vc animated:true completion:nil];
                 
                 
                         }];
             
         }
        
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation

- (IBAction)unwindToCapture:(UIStoryboardSegue *)segue {
	// Do nothing
}

@end
