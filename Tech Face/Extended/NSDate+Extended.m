//
//  NSDate+Extended.m
//  Tech Face
//
//  Created by John on 2019-6-14.
//  Copyright © 2019 MedEXO. All rights reserved.
//

#import "NSDate+Extended.h"

@implementation NSDateFormatter (Extended)

+ (NSDateFormatter *)parseDateFormatter {
	static NSDateFormatter *formatter;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		formatter = [NSDateFormatter new];
		[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
		[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	});
	return formatter;
}

+ (NSDateFormatter *)shortDateFormatter {
	static NSDateFormatter *formatter;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		formatter = [NSDateFormatter new];
		[formatter setDateFormat:@"dd-MM-yyyy"];
	});
	return formatter;
}

+ (NSDateFormatter *)shortTimeFormatter {
	static NSDateFormatter *formatter;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		formatter = [NSDateFormatter new];
		[formatter setDateFormat:@"HH:mm"];
	});
	return formatter;
}

@end

@implementation NSDate (Extended)

+ (NSDate *)parseDateFromString:(NSString *)string {
	return [[NSDateFormatter parseDateFormatter] dateFromString:string];
}

+ (NSDate *)shortDateFromString:(NSString *)string {
	return [[NSDateFormatter shortDateFormatter] dateFromString:string];
}

+ (NSString *)shortStringFromDate:(NSDate *)date {
	return [[NSDateFormatter shortDateFormatter] stringFromDate:date];
}

+ (NSString *)shortTimeStringFromDate:(NSDate *)date {
	return [[NSDateFormatter shortTimeFormatter] stringFromDate:date];
}

@end
