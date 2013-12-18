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

- (void)clearTokens
{
    [[KSinaWeiboShared Instance] clearToken];
}


- (BOOL)shareText:(NSString *)text type:(SharedType)type completion:(void(^)(NSError *))completion
{
    if (text.length == 0 || type >= SharedType_Unknown) {
        return NO;
    }

    switch (type) {
        case SharedType_SinaWeibo:
            [[KSinaWeiboShared Instance] share:text image:nil completion:completion];
            break;
        case SharedType_TencentWeibo:
            [[KTencentWeiboShared Instance] share:text image:nil completion:completion];
            break;
        case SharedType_WeChatFriend:
            [[KWeChatShared Instance] shareTextToFriend:text completion:completion];
            break;
        case SharedType_WeChatCircel:
            [[KWeChatShared Instance] shareTextToCircel:text completion:completion];
            break;
        case SharedType_QQChat:
            return [[KQQChatShared Instance] shareText:text completion:completion];
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)shareImage:(UIImage *)image type:(SharedType)type completion:(void(^)(NSError *))completion
{
    if (!image) {
        return NO;
    }
    
    switch (type) {
        case SharedType_SinaWeibo:
            [[KSinaWeiboShared Instance] share:@"[分享图片]" image:image completion:completion];
            break;
        case SharedType_TencentWeibo:
            [[KTencentWeiboShared Instance] share:@"[分析图片]" image:image completion:completion];
            break;
        case SharedType_WeChatFriend:
            [[KWeChatShared Instance] shareImageToFriend:image completion:completion];
            break;
        case SharedType_WeChatCircel:
            [[KWeChatShared Instance] shareImageToCircel:image completion:completion];
            break;
        case SharedType_QQChat:
            return [[KQQChatShared Instance] shareImage:image completion:completion];
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage*)image url:(NSString*)urlstring type:(SharedType)type completion:(void(^)(NSError *))completion
{
    if (content.length == 0 || type >= SharedType_Unknown) {
        return NO;
    }
    
    switch (type) {
        case SharedType_SinaWeibo:
        case SharedType_TencentWeibo:
            return NO;
            break;
        case SharedType_WeChatFriend:
            [[KWeChatShared Instance] shareNewsToFriend:title Content:content Image:image Url:urlstring completion:completion];
            break;
        case SharedType_WeChatCircel:
            [[KWeChatShared Instance] shareNewsToCircel:title Content:content Image:image Url:urlstring completion:completion];
            break;
        case SharedType_QQChat:
            return [[KQQChatShared Instance] shareNews:title Content:content Image:image Url:urlstring completion:completion];
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)handleURL:(NSURL *)url
{
    NSString *paramString = [url absoluteString];
    NSLog(@"sharedHandleURL:url=%@", paramString);
    
    //weChat
    NSRange range = [paramString rangeOfString:@"wechat"];
    if (range.location != NSNotFound) {
        return [[KWeChatShared Instance] handleURL:url];
    }
    
    //qqChat
    range = [paramString rangeOfString:kQQChatURLScheme];
    if (range.location != NSNotFound) {
        return [[KQQChatShared Instance] handleURL:url];
    }
    
    //sinaWeibo
    range = [paramString rangeOfString:kAppURLScheme];
    if (range.location != NSNotFound) {
        return [[KSinaWeiboShared Instance] handleURL:paramString];
    }
    
    return NO;
}

@end
