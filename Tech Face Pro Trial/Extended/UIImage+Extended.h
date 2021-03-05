//
//  UIImage+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-14.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import UIKit;
@import AVFoundation;
@import AVKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Extended)

- (void)saveInDocumentAsName:(NSString *)name withQuality:(CGFloat)compressionQuality;
+ (UIImage *)imageInDocumentWithName:(NSString *)name;
+ (BOOL) imageRemoveFromDocumentWithName:(NSString *)name;
+ (nullable UIImage *)assetImageFromURL:(nullable NSURL *)url;
+ (nullable UIImage *)imageFromAsset:(nullable AVAsset *)asset;

@end

NS_ASSUME_NONNULL_END
