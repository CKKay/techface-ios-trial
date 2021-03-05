//
//  UIImage+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-14.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "UIImage+Extended.h"
#import "NSString+Extended.h"

@implementation UIImage (Extended)

- (void)saveInDocumentAsName:(NSString *)name withQuality:(CGFloat)compressionQuality {
	NSString *fullPath = [NSString fullPathOfUserDocumentWithName:name];
	NSLog(@"Saving image to %@", fullPath);
	NSData *data = UIImageJPEGRepresentation(self, compressionQuality);
	[data writeToFile:fullPath atomically:true];
     data =nil ;
}

+ (UIImage *)imageInDocumentWithName:(NSString *)name {
	NSString *fullPath = [NSString fullPathOfUserDocumentWithName:name];
	return [UIImage imageWithContentsOfFile:fullPath];
}

+ (BOOL) imageRemoveFromDocumentWithName:(NSString *)name{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString fullPathOfUserDocumentWithName:name];
    NSError *error;
    BOOL result = [fileManager removeItemAtPath:fullPath error:&error];
    if(result){
        NSLog(@"delete image success to %@", fullPath);
    } else {
         NSLog(@"delete image fail to %@", fullPath);
    }
    fileManager = nil;
    return result;
    
    
}

+ (nullable UIImage *)assetImageFromURL:(nullable NSURL *)url {
	if (!url || [NSString isEmpty:url.absoluteString]) {
		return nil;
	}
	NSLog(@"Asset image from: %@", url.absoluteString);
	return [self imageFromAsset:[AVAsset assetWithURL:url]];
}

+ (nullable UIImage *)imageFromAsset:(nullable AVAsset *)asset {
	if (!asset) {
		NSLog(@"[Abort] asset is null");
		return nil;
	}
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	if (!generator) {
		NSLog(@"Abort: imageGenerator is null");
		return nil;
	}
	generator.appliesPreferredTrackTransform = true;
	CMTime time = [asset duration];
	time.value = 0;
	NSError *error = nil;
	@try {
		CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:nil error:&error];
		if (error) {
			NSLog(@"error %@", error.localizedDescription);
			return nil;
		}
		if (!imageRef) {
			NSLog(@"Abort: imageRef is null");
			return nil;
		}
		UIImage *image = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
		return image;
	}
	@catch (NSException *exception) {
		NSLog(@"exception. %@", exception.reason);
		return nil;
	}
}

@end
