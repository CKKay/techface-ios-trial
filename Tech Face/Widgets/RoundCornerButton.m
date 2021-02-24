//
//  RoundCornerButton.m
//  Tech Face
//
//  Created by John on 2019-6-27.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "RoundCornerButton.h"
#import "UIView+Extended.h"

@implementation RoundCornerButton

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setRoundCornerWithRadius:10];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self setRoundCornerWithRadius:10];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	[self setRoundCornerWithRadius:10];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	if (self.isEnabled) {
		if (self.isHighlighted) {
			self.backgroundColor = [UIColor colorWithHue:(302/360.0) saturation:0.50 brightness:0.85 alpha:1.0];
		} else {
			self.backgroundColor = [UIColor colorWithHue:(302/360.0) saturation:0.69 brightness:0.75 alpha:1.0];
		}
	}
}

@end
