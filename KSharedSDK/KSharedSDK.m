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

#define KSharedSDK_sinaWeibo_accessToken    @"KSharedSDK_sinaWeibo_accessToken"
#define KSharedSDK_sinaWeibo_uid            @"KSharedSDK_sinaWeibo_uid"

@interface KSharedSDK () <KSinaWeiboLoginDelegate>

@end

@implementation KSharedSDK {
    void(^didFinishedSharedMessage)(NSDictionary *, NSError *);
    
    //sinaWeibo
    KSinaWeiboLoginView *loginView;
    NSString *sinaWeibo_accessToken;
    NSString *sinaWeibo_uid;
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
            
            //未安装客户端，发请求验证
            if (!ssoLoggingIn) {
                loginView = [[KSinaWeiboLoginView alloc] init];
                loginView.delegate = self;
                [loginView show];
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

#pragma  ---- KSinaWeiboLoginDelegate----
- (void)sinaWeiboLoginCallback:(NSDictionary *)userInfo
{
    NSString *error = [userInfo objectForKey:@"error"];
    if (error.length) {
        //sth wrong
        return;
    }
    
    sinaWeibo_accessToken = [userInfo objectForKey:@"access_token"];
    sinaWeibo_uid = [userInfo objectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:sinaWeibo_accessToken forKey:KSharedSDK_sinaWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:sinaWeibo_uid forKey:KSharedSDK_sinaWeibo_uid];
}

@end
