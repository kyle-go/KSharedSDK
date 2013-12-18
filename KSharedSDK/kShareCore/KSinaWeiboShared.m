//
//  KSinaWeiboShared.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSinaWeiboShared.h"
#import "KUnits.h"
#import "KHttpManager.h"
#import "KWeiboOauthView.h"
#import "KSharedSDKDefine.h"
#import "KSharedMessage.h"

#define KSharedSDK_sinaWeibo_accessToken    @"KSharedSDK_sinaWeibo_accessToken"
#define KSharedSDK_sinaWeibo_uid            @"KSharedSDK_sinaWeibo_uid"

@interface KSinaWeiboShared() <KWeiboOauthDelegate>
{

}
@end

@implementation KSinaWeiboShared {
    //发送队列，都是主线程不需要锁
    NSMutableArray *shareMessages;
    //sinaWeibo
    NSString *access_token;
    NSString *uid;
}

+ (instancetype)Instance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}


- (void)clearToken
{
    [shareMessages removeAllObjects];
    access_token = nil;
    uid = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_sinaWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_sinaWeibo_uid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    if (self = [super init]) {
        shareMessages = [[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL)share:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion
{
    if (text.length > 140 || text.length == 0) {
        return NO;
    }
    
    //添加到队列
    KSharedMessage *message = [[KSharedMessage alloc] init];
    message.text = text;
    message.image = image;
    if (completion) {
        message.completion = completion;
    }
    [shareMessages addObject:message];
    
    if (access_token.length == 0 || uid.length == 0) {
        access_token = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_accessToken];
        uid = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_uid];
    }
    
    if (access_token.length && uid.length) {
        [self checkSharedMessages];
        return YES;
    }
    
    [self getNewToken];
    
    return YES;
}

- (BOOL)handleURL:(NSString *)paramString
{
    NSString *temp_uid;
    NSString *temp_access_token;
    NSArray *array = [paramString componentsSeparatedByString:@"&"];
    NSRange range;
    for (NSString *item in array) {
        range = [item rangeOfString:@"uid=" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            temp_uid = [item substringFromIndex:range.location + range.length];
            continue;
        }
        range = [item rangeOfString:@"access_token=" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            temp_access_token = [item substringFromIndex:range.location + range.length];
        }
    }
    
    //成功获取token
    if (temp_uid && temp_access_token) {
        uid = temp_uid;
        access_token = temp_access_token;
        [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:KSharedSDK_sinaWeibo_accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:KSharedSDK_sinaWeibo_uid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self checkSharedMessages];
        return YES;
    
    //用户取消了
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"用户取消授权!" code:ErrorType_UserCancel userInfo:nil];
        
        //判断队列中是否有SinaWeibo待分享数据,全部调用起回调，通知认证失败
        for (KSharedMessage *m in shareMessages) {
                m.completion(error);
                [shareMessages removeObject:m];
        }
        return YES;
    }
    
    return FALSE;
}

- (void)getNewToken
{
    NSDictionary *param = @{@"redirect_uri": kSinaWeiboRedirectURI,
                            @"callback_uri": kAppURLScheme,
                            @"client_id":kSinaWeiboAppKey};
    NSURL *appAuthURL = [KUnits generateURL:@"sinaweibosso://login" params:param];
    BOOL ssoLoggingIn = [[UIApplication sharedApplication] openURL:appAuthURL];
    
    //未安装客户端，发请求验证
    if (!ssoLoggingIn) {
        KWeiboOauthView *oathView = [KWeiboOauthView Instance];
        oathView.delegate = self;
        [oathView show:SharedType_SinaWeibo];
    }
}


#pragma  ---- KSinaWeiboOauthDelegate----
- (void)weiboOauthCallback:(NSDictionary *)userInfo
{
    NSString *errorString = [userInfo objectForKey:@"error"];
    
    if (errorString.length) {
        NSError *error = [[NSError alloc] initWithDomain:errorString code:ErrorType_Unknown userInfo:nil];
        
        //判断队列中是否有SinaWeibo待分享数据,全部调用起回调，通知认证失败
        for (KSharedMessage *m in shareMessages) {
            m.completion(error);
            [shareMessages removeObject:m];
        }
        return;
    }
    
    access_token = [userInfo objectForKey:@"access_token"];
    uid = [userInfo objectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:KSharedSDK_sinaWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:KSharedSDK_sinaWeibo_uid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkSharedMessages];
}

- (void)checkSharedMessages
{
    for (KSharedMessage *m in shareMessages) {
        if (m.image) {
            [self sinaWeiboSendTextWithImages:m.text image:m.image completion:m.completion];
        } else {
            [self sinaWeiboSendText:m.text completion:m.completion];
        }
        
        [shareMessages removeObject:m];
        break;
    }
}

- (void)sinaWeiboSendText:(NSString *)text completion:(void(^)(NSError *))completion
{
    assert(access_token.length);
    assert(uid.length);
    
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
            
            //添加到队列
            KSharedMessage *messageInfo = [[KSharedMessage alloc] init];
            messageInfo.text = text;
            if (completion) {
                messageInfo.completion = completion;
            }
            [shareMessages addObject:messageInfo];
            
            
            //重新请求token
            [self getNewToken];
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
    
    //发一条新微博
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *params = @{@"status":text, @"access_token":access_token};
    NSMutableURLRequest *request = [manager getRequest:@"https://api.weibo.com/2/statuses/update.json" parameters:params success:success_callback failure:failure_callback];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [manager start];
}


- (void)sinaWeiboSendTextWithImages:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion
{
    
}
@end
