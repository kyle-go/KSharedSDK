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

@implementation KSharedSDK {
    BOOL _enableDebugLog;
}

+ (instancetype)Instance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        _enableDebugLog = YES;
    }
    return self;
}

- (void)enableDebugLog:(BOOL)enableDebugLog
{
    _enableDebugLog = enableDebugLog;
}

- (void)clearTokens
{
    [[KSinaWeiboShared Instance] clearToken];
}

- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage*)image url:(NSString*)urlstring type:(SharedType)type completion:(void(^)(NSError *))completion
{
    if (content.length == 0 || type >= SharedType_Unknown) {
        return NO;
    }
    
    switch (type) {
        case SharedType_SinaWeibo: {
            NSString *text;
            if (title.length) {
                text = [NSString stringWithFormat:@"#%@#%@", title, content];
            } else {
                text = content;
            }
            return [[KSinaWeiboShared Instance] share:text image:image completion:completion];
        }
            break;
        case SharedType_TencentWeibo:
        {
            NSString *text;
            if (title.length) {
                text = [NSString stringWithFormat:@"#%@#%@", title, content];
            } else {
                text = content;
            }
            return [[KTencentWeiboShared Instance] share:text image:image completion:completion];
        }
            break;
        case SharedType_WeChatFriend:
            return [[KWeChatShared Instance] shareNewsToFriend:title Content:content Image:image Url:urlstring completion:completion];
            break;
        case SharedType_WeChatCircel:
            return [[KWeChatShared Instance] shareNewsToCircel:title Content:content Image:image Url:urlstring completion:completion];
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
