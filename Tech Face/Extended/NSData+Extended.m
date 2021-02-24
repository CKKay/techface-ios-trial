//
//  NSData+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-19.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "NSData+Extended.h"

@implementation NSMutableData (Extended)

- (void)appendString:(NSString *)string {
	[self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)appendStringWithFormat:(NSString *)format, ... {
	va_list argList;
	va_start(argList, format);
	NSString *string = [[NSString alloc] initWithFormat:format arguments:argList];
	va_end(argList);
	[self appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
