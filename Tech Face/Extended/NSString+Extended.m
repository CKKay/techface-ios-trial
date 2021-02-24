//
//  NSString+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-4.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "NSString+Extended.h"

@implementation NSString (Extended)

+ (BOOL)isEmpty:(nullable NSString *)s {
	return ((nil == s) || (s == (id)[NSNull null]) || (s.length == 0));
}

+ (nonnull NSString *)nonNull:(nullable NSString *)s {
	return ((nil == s) || (s == (id)[NSNull null]) ? @"" : s);
}

- (NSString *)trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)fullPathOfUserDocumentWithName:(NSString *)name {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
	NSString *documentDir = [paths objectAtIndex:0];
	return [documentDir stringByAppendingPathComponent:name];
}

@end
