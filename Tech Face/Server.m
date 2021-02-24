//
//  Server.m
//  Tech Face
//
//  Created by John on 2019-4-30.
//  Copyright © 2019 MedEXO. All rights reserved.
//ß

#import "Server.h"

@implementation Server

+ (NSURL *)serverURL {
	static NSURL *url;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
#ifdef SERVER_HEROKU
		url = [NSURL URLWithString:@"https://techface.herokuapp.com/"];
#else
		url = [NSURL URLWithString:@"http://systemuat.techfacepro.com:8080/"];
#endif
	});
	return url;
}


+ (NSURL *)techfaceURL {
    static NSURL *url;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        url = [NSURL URLWithString:@"http://systemuat.techfacepro.com/"];
    });
    return url;
}

+ (nullable NSURL *)url:(NSString *)format, ... {
	va_list argList;
	va_start(argList, format);
	NSURL *url = [self url:format arguments:argList];
	va_end(argList);
	return url;
}

+ (nullable NSURL *)url:(NSString *)format arguments:(va_list)argList {
	NSString *str = [[NSString alloc] initWithFormat:format arguments:argList];
	if ([str containsString:@"<null>"]) { // args contains null value
		DLog(@"argument contains null: %@", str);
		return nil;
	}
	str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
	return [NSURL URLWithString:str relativeToURL:self.serverURL];
}

+ (nullable NSURL *)websiteurl:(NSString *)format, ... {
    va_list argList;
    va_start(argList, format);
    NSURL *url = [self websiteurl:format arguments:argList];
    va_end(argList);
    return url;
}


+ (nullable NSURL *)websiteurl:(NSString *)format arguments:(va_list)argList {
    NSString *str = [[NSString alloc] initWithFormat:format arguments:argList];
    if ([str containsString:@"<null>"]) { // args contains null value
        DLog(@"argument contains null: %@", str);
        return nil;
    }
    str = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    return [NSURL URLWithString:str relativeToURL:self.techfaceURL];
}

+ (nullable NSString *)websiteurlString:(NSString *)format, ... {
	va_list argList;
	va_start(argList, format);
	NSURL *url = [self websiteurl:format arguments:argList];
	va_end(argList);
	return url.absoluteString;
}

@end
