//
//  DFBlunoManager+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-19.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "DFBlunoManager+Extended.h"
#import "Server.h"

@implementation DFBlunoManager (Extended)

- (void)writeData:(NSData *)data toDevice:(DFBlunoDevice *)device {
	[self writeDataToDevice:data Device:device];
	DLog(@"Sent data to bluno");
}

- (void)writeString:(NSString *)string toDevice:(DFBlunoDevice *)device {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	[self writeDataToDevice:data Device:device];
	DLog(@"Sent text to bluno: %@", string);
}

@end
