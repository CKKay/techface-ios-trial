//
//  RoundCornerView.m
//  Tech Face
//
//  Created by John on 2019-6-5.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "RoundCornerView.h"
#import "UIView+Extended.h"

@implementation RoundCornerView

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

@end
