//
//  PinchImageViewController.m
//  Tech Face
//
//  Created by John on 2019-6-8.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "PinchImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#include <stdlib.h>

@interface PinchImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PinchImageViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
//	int r = arc4random_uniform(3);
//	NSArray *thumbnails = [NSArray arrayWithObjects:@"d_1", @"d_2", @"d_5", nil];
//	UIImage* image = [UIImage imageNamed:thumbnails[r]];
//
//	NSAssert(image, @"image must not be nil."
//			 "Check that you added the image to your bundle and that "
//			 "the filename above matches the name of your image.");

//	self.imageView.image = image;
//	[self.imageView sizeToFit];
//
//	self.scrollView.contentSize = image.size;
	self.scrollView.minimumZoomScale = 1.0;
	self.scrollView.maximumZoomScale = 100.0;
	[self.imageView sd_setImageWithURL:self.imageURL
					  placeholderImage:nil
							 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
								 [self updateImageView];
							 }];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self updateImageView];
}

- (void)updateImageView {
	[self.imageView sizeToFit];
	UIImage *image = self.imageView.image;
	if (image) {
		CGFloat widthScale = self.scrollView.bounds.size.width / self.imageView
		.bounds.size.width;
		CGFloat heightScale = self.scrollView.bounds.size.height / self.imageView
		.bounds.size.height;
		CGFloat zoomScale = MAX(widthScale, heightScale);
		if (isinf(zoomScale)) {
			NSLog(@"minScale is inf");
			return;
		}
		if (isnan(zoomScale)) {
			NSLog(@"minScale is NaN");
			return;
		}
		self.scrollView.minimumZoomScale = zoomScale;
		self.scrollView.zoomScale = zoomScale;
		self.scrollView.maximumZoomScale = 10.0;
		// Recenter the image view if it is smaller than scrollView
		CGFloat scrollW = CGRectGetWidth(self.scrollView.bounds);
		CGFloat scrollH = CGRectGetHeight(self.scrollView.bounds);
		CGFloat contentW = self.scrollView.contentSize.width;
		CGFloat contentH = self.scrollView.contentSize.height;
		
		CGFloat offsetX = (scrollW > contentW ? (scrollW - contentW) * 0.5 : 0.0);
		CGFloat offsetY = (scrollH > contentH ? (scrollH - contentH) * 0.5 : 0.0);
		self.imageView.center = CGPointMake(contentW * 0.5 + offsetX,
											contentH * 0.5 + offsetY);
	}
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint {
	CGRect vf = view.frame;
	CGPoint co = self.scrollView.contentOffset;

	CGFloat x = centerPoint.x - vf.size.width / 2.0;
	CGFloat y = centerPoint.y - vf.size.height / 2.0;

	if (x < 0) {
		co.x = -x;
		vf.origin.x = 0.0;
	} else {
		vf.origin.x = x;
	}
	if (y < 0) {
		co.y = -y;
		vf.origin.y = 0.0;
	} else {
		vf.origin.y = y;
	}

	view.frame = vf;
	self.scrollView.contentOffset = co;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv {
	UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
	CGRect zvf = zoomView.frame;
	if (zvf.size.width < sv.bounds.size.width) {
		zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
	} else {
		zvf.origin.x = 0.0;
	}
	if (zvf.size.height < sv.bounds.size.height) {
		zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
	} else {
		zvf.origin.y = 0.0;
	}
	zoomView.frame = zvf;
}

@end
