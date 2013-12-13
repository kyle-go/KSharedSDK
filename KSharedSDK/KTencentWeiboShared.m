//
//  KTencentWeiboShared.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/12/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KTencentWeiboShared.h"
#import "KUnits.h"
#import "KHttpManager.h"
#import "KSharedSDKDefine.h"
#import "KSharedMessage.h"
#import "KWeiboOauthView.h"

#define KSharedSDK_tencentWeibo_accessToken    @"KSharedSDK_tencentWeibo_accessToken"
#define KSharedSDK_tencentWeibo_openid         @"KSharedSDK_tencentWeibo_openid"
#define KSharedSDK_tencentWeibo_openkey        @"KSharedSDK_tencentWeibo_openkey"

@interface KTencentWeiboShared() <KWeiboOauthDelegate>
{
    
}
@end


@implementation KTencentWeiboShared {
    //发送队列，都是主线程不需要锁
    NSMutableArray *shareMessages;
    
    //uid & accessToken
    NSString *access_token;
    NSString *expires_in;
    NSString *openid;
    NSString *openkey;
    NSString *refresh_token;
    NSString *state;
    NSString *name;
    NSString *nick;
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
    access_token = @"";
    expires_in = @"";
    openid = @"";
    openkey = @"";
    refresh_token = @"";
    state = @"";
    name = @"";
    nick = @"";
}

- (id)init
{
    if (self = [super init]) {
        shareMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 *@description 分享消息
 */
- (BOOL)sharedMessage:(NSString *)text completion:(void(^)(NSError *))completion
{
    if (text.length > 140 || text.length == 0) {
        return NO;
    }
    
    //添加到队列
    KSharedMessage *messageInfo = [[KSharedMessage alloc] init];
    messageInfo.contentText = text;
    if (completion) {
        messageInfo.completionBlock = completion;
    } else {
        messageInfo.completionBlock = ^{};
    }
    [shareMessages addObject:messageInfo];
    
    if (!access_token || !openkey || !openid) {
        access_token = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_accessToken];
        openkey = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_openkey];
        openid = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_openid];
    }
    
    if (access_token && openid && openkey) {
        [self checkSharedMessages];
        return YES;
    }
    
    [self getNewToken];
    
    return YES;
}

- (void)getNewToken
{
    KWeiboOauthView *oathView = [KWeiboOauthView Instance];
    oathView.delegate = self;
    [oathView show:SharedType_TencentWeibo];
}

#pragma  ---- KSinaWeiboOauthDelegate----
- (void)weiboOauthCallback:(NSDictionary *)userInfo
{
    NSString *errorString = [userInfo objectForKey:@"error"];
    if (errorString.length) {
        NSError *error = [[NSError alloc] initWithDomain:errorString code:-1 userInfo:nil];
        //判断队列中是否有待分享消息,全部调用起回调，通知认证失败
        for (KSharedMessage *msgInfo in shareMessages) {
            
            ((void(^)(NSError *))msgInfo.completionBlock)(error);
            
            [shareMessages removeObject:msgInfo];
        }
        return;
    }
    
    access_token = [userInfo objectForKey:@"access_token"];
    openkey = [userInfo objectForKey:@"openkey"];
    openid = [userInfo objectForKey:@"openid"];
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:KSharedSDK_tencentWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:openid forKey:KSharedSDK_tencentWeibo_openid];
    [[NSUserDefaults standardUserDefaults] setObject:openkey forKey:KSharedSDK_tencentWeibo_openkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self checkSharedMessages];
}

- (void)checkSharedMessages
{
    //判断队列中是否有SinaWeibo待分享数据
    for (KSharedMessage *msgInfo in shareMessages) {
        
        [self tencentWeiboSend:msgInfo.contentText completion:((void(^)(NSError *))msgInfo.completionBlock)];
        
        [shareMessages removeObject:msgInfo];
        
        break;
    }
}

- (void)tencentWeiboSend:(NSString *)text completion:(void(^)(NSError *))completion
{
    assert(access_token.length);
    assert(openkey.length);
    assert(openid.length);
    
    void (^success_callback) (id responseObject) =
    ^(id responseObject) {
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        //解析数据失败了
        if (error) {
            completion(error);
            [self checkSharedMessages];
            return ;
        }
        
        error = nil;
        NSString *errorString = [json objectForKey:@"msg"];
        NSNumber *errorCode = [json objectForKey:@"errcode"];
        if (errorString && errorCode) {
            error = [[NSError alloc] initWithDomain:errorString code:[errorCode intValue] userInfo:nil];
        }
        
        //token已过期
        if ([errorCode intValue] == 21315) {
            
            //添加到队列
            KSharedMessage *messageInfo = [[KSharedMessage alloc] init];
            messageInfo.contentText = text;
            if (completion) {
                messageInfo.completionBlock = completion;
            } else {
                messageInfo.completionBlock = ^{};
            }
            [shareMessages addObject:messageInfo];
            
            
            //重新请求token
            [self getNewToken];
            return ;
        }
        
        //未通过审核的应用且未加入到测试帐号中
        //if ([errorCode intValue] == 21321) {
        //    error = [[NSError alloc] initWithDomain:@"此帐号未加入到应用测试帐号列表." code:[errorCode intValue] userInfo:nil];
        //}
        //不能连续发送相同内容的微博
        //if([errorCode intValue] == 20019) {
        //    error = [[NSError alloc] initWithDomain:@"不能连续发送相同内容的微博." code:[errorCode intValue] userInfo:nil];
        //}
        
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
    NSDictionary *bodyParam = @{@"oauth_consumer_key":kTencentWeiboAppKey,
                                @"access_token":access_token,
                                @"openid":openid,
                                @"clientip":@"10.10.1.31",
                                @"oauth_version":@"2.a",
                                @"scope":@"all",
                                @"clientip":@"10.10.1.31",
                                @"format":@"json",
                                @"content":text};
    
    NSString *body = [[KUnits generateURL:nil params:bodyParam] absoluteString];
    
    NSMutableURLRequest *request = [manager getRequest:@"https://open.t.qq.com/api/t/add" parameters:nil success:success_callback failure:failure_callback];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (long)body.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [manager start];
}

@end