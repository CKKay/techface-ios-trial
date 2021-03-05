//
//  CompareImagesViewController.m
//  Tech Face
//
//  Created by John on 2019-6-8.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "CompareImagesViewController.h"
#import "PinchImageViewController.h"
#import "Server.h"

@interface CompareImagesViewController ()

@end

@implementation CompareImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"Embed Prev Image"] ||
		[segue.identifier isEqualToString:@"Embed Next Image"]) {
		Boolean isPrev = [segue.identifier containsString:@"Prev"];
		PinchImageViewController *vc = (PinchImageViewController *)segue.destinationViewController;
		NSDictionary *dict = isPrev ? self.prevItemDict : self.nextItemDict;
        NSString *directory = [dict valueForKeyPath:self.imagePath];
		NSString *name = [dict valueForKeyPath:self.itemKey];
        

        NSString *storageType = [dict valueForKey:@"storagetype"];
   
        
		if (name && name.length > 0) {
            if( [storageType isEqualToString:@"OTHER"] ){
                 NSString *treatmenturl = [dict valueForKey:@"treatmentfileurl"];
                 vc.imageURL = [treatmenturl valueForKey:self.itemKey];
		
            } else {
                vc.imageURL = [Server url:@"/uploads/%@/%@", directory, name];
            }
		}
	}
}

#pragma mark - Actions

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

@end
