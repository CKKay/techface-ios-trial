//
//  SelectClientViewController.h
//  Tech Face
//
//  Created by MedEXO on 07/09/18.
//  Copyright © 2018 MedEXO. All rights reserved.
//

@import UIKit;

@class TreatmentTypeViewController;

@protocol TreatmentTypeViewControllerDelegate <NSObject>
- (void)addItemViewController:(TreatmentTypeViewController *)controller didFinishEnteringItem:(NSString *)item;
@end

@interface TreatmentTypeViewController : UIViewController<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *selectedArray;
@property (strong, nonatomic) NSString *testvalue;


@end

