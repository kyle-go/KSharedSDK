//
//  KSharedSDK.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KSharedSDK.h"
#import "KSharedSDKDefine.h"
#import "KSinaWeiboShared.h"
#import "KTencentWeiboShared.h"
#import "KWeChatShared.h"
#import "KQQChatShared.h"

@interface KSharedSDK ()

@end

@implementation KSharedSDK

+ (instancetype)Instance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void)sharedClearTokens
{
    [[KSinaWeiboShared Instance] clearToken];
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
            [[KSinaWeiboShared Instance] sharedMessage:text completion:completion];
            break;
        case SharedType_TencentWeibo:
            [[KTencentWeiboShared Instance] sharedMessage:text completion:completion];
            break;
        case SharedType_WeChatFriend:
            [[KWeChatShared Instance] sharedMessageToFriend:text completion:completion];
            break;
        case SharedType_WeChatCircel:
            [[KWeChatShared Instance] sharedMessageToCircel:text completion:completion];
            break;
        case SharedType_QQFriend:
            [[KQQChatShared Instance] sharedMessageToFriend:text completion:completion];
            break;
        case SharedType_QQZone:
            [[KQQChatShared Instance] sharedMessageToZone:text completion:completion];
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
    
    //weChat
    NSRange range = [paramString rangeOfString:@"wechat"];
    if (range.location != NSNotFound) {
        return [[KWeChatShared Instance] sharedHandleURL:url];
    }
    
    //sinaWeibo
    range = [paramString rangeOfString:kAppURLScheme];
    if (range.location != NSNotFound) {
        return [[KSinaWeiboShared Instance] sharedHandleURL:paramString];
    }
    
    return NO;
}

@end
