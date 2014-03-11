//
//  KUnits.m
//  Keibo
//
//  Created by kyle on 11/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KHelper.h"

@implementation KHelper

+ (NSString *)generateUuidString {
    CFStringRef uuid = CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
    return [NSString stringWithString:CFBridgingRelease(uuid)];
}

+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params
{
	if ([params count]) {
		NSMutableArray* pairs = [[NSMutableArray alloc] init];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
            //NSString* escapedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* escapedValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																						  NULL, /* allocator */
																						  (CFStringRef)value,
																						  NULL, /* charactersToLeaveUnescaped */
																						  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																						  kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
		}
		
        NSString* url;
		NSString* query = [pairs componentsJoinedByString:@"&"];
        if (baseURL.length) {
            url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        } else {
            url = query;
        }
		
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

+ (CGRect)XYScreenBounds
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    if (UIDeviceOrientationUnknown == orient) {
        orient = UIInterfaceOrientationPortrait;
    }
    
    if (UIInterfaceOrientationIsLandscape(orient)) {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    return bounds;
}

@end
