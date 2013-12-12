//
//  KSharedSDK.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KSharedSDK.h"
#import "KSinaWeiboShared.h"

@interface KSharedSDK ()

@end

@implementation KSharedSDK {
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

+ (instancetype)sharedSDKInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void)sharedClearTokens
{
    //TODO...
}

/**
 *@description 分享消息
 */
- (BOOL)sharedMessage:(NSString *)text type:(SharedType)type completion:(void(^)(NSError *))completion
{
    if (text.length == 0 || type >= SharedType_Unknown) {
        return NO;
    }
    

    switch (type) {
        case SharedType_SinaWeibo:
            [[KSinaWeiboShared sharedSDKInstance] sharedMessage:text completion:completion];
            break;
        case SharedType_TencentWeibo:
            
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)sharedHandleURL:(NSURL *)url
{
    NSString *paramString = [url absoluteString];
    NSLog(@"sharedHandleURL:url=%@", paramString);
    
    //sinaWeibo
    NSRange range = [paramString rangeOfString:kAppURLScheme];
    if (range.location != NSNotFound) {
        [[KSinaWeiboShared sharedSDKInstance] sharedHandleURL:paramString];
    }
    
    return YES;
}

@end
