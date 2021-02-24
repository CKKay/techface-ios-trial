//
//  Server.h
//  Tech Face
//
//  Created by John on 2019-4-30.
//  Copyright © 2019 MedEXO. All rights reserved.
//

@import Foundation;

#ifdef DEBUG
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DLog( s, ... )
#endif

NS_ASSUME_NONNULL_BEGIN

//#define SERVER_HEROKU

@interface Server : NSObject

+ (NSURL *)serverURL;
+ (NSURL *)techfaceURL;
+ (nullable NSURL *)url:(NSString *)format, ...;
+ (nullable NSURL *)url:(NSString *)format arguments:(va_list)argList;
+ (nullable NSString *)urlString:(NSString *)format, ...;

+ (nullable NSURL *)websiteurl:(NSString *)format, ...;
+ (nullable NSURL *)websiteurl:(NSString *)format arguments:(va_list)argList;
+ (nullable NSString *)websiteurlString:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
