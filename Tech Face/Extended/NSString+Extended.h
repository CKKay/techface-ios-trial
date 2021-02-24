//
//  NSString+Extended.h
//  Tech Face
//
//  Created by John on 2019-6-4.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extended)

+ (BOOL)isEmpty:(nullable NSString *)string;
+ (nonnull NSString *)nonNull:(nullable NSString *)s;
- (NSString *)trim;

+ (NSString *)fullPathOfUserDocumentWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
