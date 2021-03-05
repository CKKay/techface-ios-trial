//
//  UIImageView+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-8.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "UIImageView+Extended.h"
#import "Server.h"

@implementation UIImageView (Extended)

- (void)setImageWithPath:(NSString *)path name:(nullable NSString *)name {
	if (!name) {
		[self setImage:nil];
		return;
	}
	DLog(@"path %@, name %@", path, name);
	NSURL *url = [Server url:@"/uploads/%@/%@", path, name];
	DLog(@"%@", url.absoluteString);
	[self sd_setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithOtherPath:(NSURL *)path {
    if (!path) {
        [self setImage:nil];
        return;
    }
  
    [self sd_setImageWithURL:path placeholderImage:nil];
}

@end
