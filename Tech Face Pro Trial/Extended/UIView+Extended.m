//
//  UIView+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-27.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "UIView+Extended.h"

@implementation UIView (Extended)

- (void)setRoundCornerWithRadius:(CGFloat)radius {
	CGFloat minRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 2;
	self.layer.cornerRadius = MAX(0, MIN(radius, minRadius));
	self.clipsToBounds = true;
}

@end
