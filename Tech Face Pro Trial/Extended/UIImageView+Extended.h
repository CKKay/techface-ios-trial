//
//  UIImageView+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-8.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import UIKit;
#import <SDWebImage/UIImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Extended)

- (void)setImageWithPath:(NSString *)path name:(nullable NSString *)name;

- (void)setImageWithOtherPath:(NSURL *)path;

@end

NS_ASSUME_NONNULL_END
