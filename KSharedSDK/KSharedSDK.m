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
#import "KSinaWeiboOauthView.h"

#define KSharedSDK_sinaWeibo_accessToken    @"KSharedSDK_sinaWeibo_accessToken"
#define KSharedSDK_sinaWeibo_uid            @"KSharedSDK_sinaWeibo_uid"

@interface KSharedSDK () <KSinaWeiboOauthDelegate>

@end

@implementation KSharedSDK {
    //发送队列，都是主线程不需要锁
    NSMutableArray *shareMessages;
    
    //sinaWeibo
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
        {
            if (text.length > 140) {
                return NO;
            }
            
            //添加到队列
            [shareMessages addObject:text];
            [shareMessages addObject:[[NSNumber alloc] initWithLong:SharedType_SinaWeibo]];
            if (completion) {
                [shareMessages addObject:completion];
            } else {
                [shareMessages addObject:^{}];
            }
            
            if (!sinaWeibo_accessToken || !sinaWeibo_uid) {
                sinaWeibo_accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_accessToken];
                sinaWeibo_uid = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_uid];
            }
            
            if (sinaWeibo_accessToken && sinaWeibo_uid) {
                [self checkSharedMessages];
                return YES;
            }
            
            [self getNewSinaWeiboToken];
            
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
    NSString *paramString = [url absoluteString];
    NSLog(@"sharedHandleURL:url=%@", paramString);
    
    //sinaWeibo
    NSRange range = [paramString rangeOfString:kAppURLScheme];
    if (range.location != NSNotFound) {
        
        NSString *uid;
        NSString *access_token;
        NSArray *array = [paramString componentsSeparatedByString:@"&"];
        for (NSString *item in array) {
            range = [item rangeOfString:@"uid="];
            if (range.location != NSNotFound) {
                uid = [item substringFromIndex:range.location + range.length];
                continue;
            }
            range = [item rangeOfString:@"access_token="];
            if (range.location != NSNotFound) {
                access_token = [item substringFromIndex:range.location + range.length];
            }
        }
        
        //成功获取token
        if (uid && access_token) {
            sinaWeibo_uid = uid;
            sinaWeibo_accessToken = access_token;
            [[NSUserDefaults standardUserDefaults] setObject:sinaWeibo_accessToken forKey:KSharedSDK_sinaWeibo_accessToken];
            [[NSUserDefaults standardUserDefaults] setObject:sinaWeibo_uid forKey:KSharedSDK_sinaWeibo_uid];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self checkSharedMessages];
            
        //用户取消了
        } else {
            NSError *error = [[NSError alloc] initWithDomain:@"用户取消授权!" code:-1 userInfo:nil];
            //判断队列中是否有SinaWeibo待分享数据,全部调用起回调，通知认证失败
            for (NSInteger i=0; i<shareMessages.count; i+=3) {
                SharedType sharedType = [[shareMessages objectAtIndex:i+1] longValue];
                if (sharedType == SharedType_SinaWeibo) {
                    ((void(^)(NSError *))[shareMessages objectAtIndex:i+2])(error);
                    
                    [shareMessages removeObjectsInRange:NSMakeRange(i, 3)];
                    i-=3;
                }
            }
        }

        return YES;
    }
    
    return YES;
}

- (void)getNewSinaWeiboToken
{
    NSDictionary *param = @{@"redirect_uri": kSinaWeiboRedirectURI,
                            @"callback_uri": kAppURLScheme,
                            @"client_id":kSinaWeiboAppKey};
    NSURL *appAuthURL = [KUnits generateURL:@"sinaweibosso://login" params:param];
    
    BOOL ssoLoggingIn = [[UIApplication sharedApplication] openURL:appAuthURL];
    
    //未安装客户端，发请求验证
    if (!ssoLoggingIn) {
        KSinaWeiboOauthView *oathView = [KSinaWeiboOauthView KSinaWeiboOauthViewInstance];
        oathView.delegate = self;
        [oathView show];
    }
}

#pragma  ---- KSinaWeiboOauthDelegate----
- (void)sinaWeiboOauthCallback:(NSDictionary *)userInfo
{
    NSString *errorString = [userInfo objectForKey:@"error"];
    if (errorString.length) {
        NSError *error = [[NSError alloc] initWithDomain:errorString code:-1 userInfo:nil];
        //判断队列中是否有SinaWeibo待分享数据,全部调用起回调，通知认证失败
        for (NSInteger i=0; i<shareMessages.count; i+=3) {
            SharedType sharedType = [[shareMessages objectAtIndex:i+1] longValue];
            if (sharedType == SharedType_SinaWeibo) {
                ((void(^)(NSError *))[shareMessages objectAtIndex:i+2])(error);
                
                [shareMessages removeObjectsInRange:NSMakeRange(i, 3)];
                i-=3;
            }
        }
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
                [self sinaWeiboSend:[shareMessages objectAtIndex:i] completion:[shareMessages objectAtIndex:i+2]];
                [shareMessages removeObjectsInRange:NSMakeRange(i, 3)];
                return;
                break;
                
            default:
                break;
        }
    }
}

- (void)sinaWeiboSend:(NSString *)text completion:(void(^)(NSError *))completion
{
    assert(sinaWeibo_accessToken.length);
    assert(sinaWeibo_uid.length);
    
    void (^success_callback) (id responseObject) =
    ^(id responseObject) {
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        error = nil;
        NSString *errorString = [json objectForKey:@"error"];
        NSNumber *errorCode = [json objectForKey:@"error_code"];
        if (errorString && errorCode) {
            error = [[NSError alloc] initWithDomain:errorString code:[errorCode intValue] userInfo:nil];
        }
        
        //token已过期
        if ([errorCode intValue] == 21315) {
            
            //重新加入到队列中
            [shareMessages addObject:text];
            [shareMessages addObject:[[NSNumber alloc] initWithLong:SharedType_SinaWeibo]];
            [shareMessages addObject:completion];
 
            
            //重新请求token
            [self getNewSinaWeiboToken];
            return ;
        }
        
        //未通过审核的应用且未加入到测试帐号中
        if ([errorCode intValue] == 21321) {
            error = [[NSError alloc] initWithDomain:@"此帐号未加入到应用测试帐号列表." code:[errorCode intValue] userInfo:nil];
        }
        //不能连续发送相同内容的微博
        if([errorCode intValue] == 20019) {
            error = [[NSError alloc] initWithDomain:@"不能连续发送相同内容的微博." code:[errorCode intValue] userInfo:nil];
        }

        completion(error);
        [self checkSharedMessages];
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        completion(error);
        [self checkSharedMessages];
    };
    
    //判断token是否过期POST请求
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *params = @{@"status":text, @"access_token":sinaWeibo_accessToken};
    [manager POST:@"https://api.weibo.com/2/statuses/update.json" parameters:params success:success_callback failure:failure_callback content_type:@"application/x-www-form-urlencoded"];
}

@end
