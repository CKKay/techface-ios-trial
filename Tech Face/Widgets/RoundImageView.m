//
//  RoundImageView.m
//  Tech Face
//
//  Created by John on 2019-6-5.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "RoundImageView.h"
#import "UIView+Extended.h"

@implementation RoundImageView

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
	[self setAsRound];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[self setAsRound];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	[self setAsRound];
}

- (void)setAsRound {
	CGSize size = self.bounds.size;
	CGFloat radius = MIN(size.width, size.height) / 2;
	[self setRoundCornerWithRadius:radius];
}

@end
