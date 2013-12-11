//
//  KSharedSDK.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KSharedSDK.h"
#import "KUnits.h"
#import "KHttpManager.h"
#import "KSinaWeiboLoginView.h"

#define KSharedSDK_sinaWeibo_accessToken    @"KSharedSDK_sinaWeibo_accessToken"
#define KSharedSDK_sinaWeibo_uid            @"KSharedSDK_sinaWeibo_uid"

@interface KSharedSDK () <KSinaWeiboLoginDelegate>

@end

@implementation KSharedSDK {
    //发送队列
    NSMutableArray *shareMessages;
    
    //分享消息成功回调
    void(^didFinishedSharedMessage)(NSDictionary *, NSError *);
    
    //sinaWeibo
    KSinaWeiboLoginView *loginView;
    NSString *sinaWeibo_accessToken;
    NSString *sinaWeibo_uid;
}

- (id)init
{
    if (self = [super init]) {
        shareMessages = [[NSMutableArray alloc] init];
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
    if (text.length == 0 || type >= SharedType_Unknown) {
        return NO;
    }
    
    switch (type) {
        case SharedType_SinaWeibo:
        {
            if (text.length > 140) {
                return NO;
            }
            
            //添加到队列
            [shareMessages addObject:text];
            [shareMessages addObject:[[NSNumber alloc] initWithLong:type]];
            if (userInfo.count) {
                [shareMessages addObject:userInfo];
            } else {
                [shareMessages addObject:@{}];
            }
            
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
            }
            
            return YES;
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
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkSharedMessages];
}

- (void)checkSharedMessages
{
    //判断队列中是否有SinaWeibo待分享数据
    for (NSInteger i=0; i<shareMessages.count; i+=3) {
        SharedType sharedType = [[shareMessages objectAtIndex:i+1] longValue];
        switch (sharedType) {
            case SharedType_SinaWeibo:
                [self sinaWeiboSend:[shareMessages objectAtIndex:i] userInfo:[shareMessages objectAtIndex:i+2]];
                [shareMessages removeObjectsInRange:NSMakeRange(i, 3)];
                return;
                break;
                
            default:
                break;
        }
    }
}

- (void)sinaWeiboSend:(NSString *)text userInfo:(NSDictionary *)userInfo
{
    assert(sinaWeibo_accessToken.length);
    assert(sinaWeibo_uid.length);
    
    void (^success_callback) (id responseObject) =
    ^(id responseObject) {
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        error = nil;
        NSString *errorString = [json objectForKey:@"error_code"];
        NSNumber *errorCode = [json objectForKey:@"error"];
        if (errorString && errorCode) {
            error = [[NSError alloc] initWithDomain:errorString code:[errorCode intValue] userInfo:nil];
        }

        if (didFinishedSharedMessage) {
            didFinishedSharedMessage(userInfo, error);
        }
        [self checkSharedMessages];
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        if (didFinishedSharedMessage) {
            didFinishedSharedMessage(userInfo, error);
        }
        [self checkSharedMessages];
    };
    
    //判断token是否过期POST请求
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *params = @{@"status":text, @"access_token":sinaWeibo_accessToken};
    [manager POST:@"https://api.weibo.com/2/statuses/update.json" parameters:params success:success_callback failure:failure_callback content_type:@"application/x-www-form-urlencoded"];
}

@end
