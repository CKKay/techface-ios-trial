//
//  NSData+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-19.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableData (Extended)

- (void)appendString:(NSString *)string;
- (void)appendStringWithFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
