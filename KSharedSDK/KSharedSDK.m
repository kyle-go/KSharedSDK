//
//  KSharedSDK.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KSharedSDK.h"
#import "KUnits.h"
#import "KSinaWeiboLoginView.h"

@interface KSharedSDK ()

@end

@implementation KSharedSDK {
    void(^didFinishedSharedMessage)(NSDictionary *, NSError *);
}

- (id)init
{
    if (self = [super init]) {
        //TODO...
    }
    return self;
}

+ (instancetype)kSharedSDKInstance
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

- (void)setDidFinishedShareMessageCompletion:(void(^)(NSDictionary *, NSError *)) completion
{
    didFinishedSharedMessage = completion;
}

- (BOOL)sharedMessage:(NSString *)text type:(SharedType)type userInfo:(NSDictionary *)userInfo
{
    switch (type) {
        case SharedType_SinaWeibo:
        {
            NSDictionary *param = @{@"redirect_uri": kSinaWeiboRedirectURI,
                                    @"callback_uri": kAppURLScheme,
                                    @"client_id":kSinaWeiboAppKey};
            NSURL *appAuthURL = [KUnits generateURL:@"sinaweibosso://login" params:param];
            
            BOOL ssoLoggingIn = [[UIApplication sharedApplication] openURL:appAuthURL];
            
            //未安装客户端，自己发请求验证
            if (!ssoLoggingIn) {
                [KSinaWeiboLoginView show];
                return YES;
            }
        }
            break;
        case SharedType_TencentWeibo:
        {
            
        }
            break;
        default:
            break;
    }
    
    return NO;
}

- (BOOL)sharedHandleURL:(NSURL *)url
{
    NSLog(@"sharedHandleURL:url=%@", [url absoluteString]);
    return YES;
}

@end
