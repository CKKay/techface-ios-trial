//
//  NSDate+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-14.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDateFormatter (Extended)

+ (NSDateFormatter *)parseDateFormatter;
+ (NSDateFormatter *)shortDateFormatter;
+ (NSDateFormatter *)shortTimeFormatter;

@end

@interface NSDate (Extended)

+ (NSDate *)parseDateFromString:(NSString *)string;
+ (NSDate *)shortDateFromString:(NSString *)string;
+ (NSString *)shortStringFromDate:(NSDate *)date;
+ (NSString *)shortTimeStringFromDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
