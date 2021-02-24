//
//  CompareImagesViewController.h
//  Tech Face
//
//  Created by John on 2019-6-8.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface CompareImagesViewController : UIViewController

@property (strong, nonatomic) NSString *itemKey;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSDictionary *prevItemDict;
@property (strong, nonatomic) NSDictionary *nextItemDict;

@end

NS_ASSUME_NONNULL_END
