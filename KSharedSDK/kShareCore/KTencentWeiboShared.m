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
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_tencentWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_tencentWeibo_openid];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_tencentWeibo_openkey];
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
    KSharedMessage *messageInfo = [[KSharedMessage alloc] init];
    messageInfo.text = text;
    messageInfo.image = image;
    if (completion) {
        messageInfo.completion = completion;
    }
    [shareMessages addObject:messageInfo];
    
    if (access_token.length == 0 || openkey.length == 0 || openid.length == 0) {
        access_token = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_accessToken];
        openkey = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_openkey];
        openid = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_tencentWeibo_openid];
    }
    
    if (access_token.length && openid.length && openkey.length) {
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
        for (KSharedMessage *m in shareMessages) {
            m.completion(error);
            [shareMessages removeObject:m];
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
    for (KSharedMessage *m in shareMessages) {
        if (m.image) {
            [self tencentWeiboSendTextWithImage:m.text image:m.image completion:m.completion];
        } else {
            [self tencentWeiboSendText:m.text completion:m.completion];
        }
        
        [shareMessages removeObject:m];
        break;
    }
}

- (void)tencentWeiboSendText:(NSString *)text completion:(void(^)(NSError *))completion
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
        if (![errorString isEqualToString:@"ok"] && [errorCode intValue] != 0) {
            error = [[NSError alloc] initWithDomain:errorString code:[errorCode intValue] userInfo:nil];
        }
        
        //token已过期
        if ([errorCode intValue] == 37) {
            
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
        
        //表示有过多脏话，请认真检查content内容
        if ([errorCode intValue] == 4) {
            error = [[NSError alloc] initWithDomain:@"表示有过多脏话，请认真检查content内容." code:[errorCode intValue] userInfo:nil];
        }
        //不能连续发送相同内容的微博
        if([errorCode intValue] == 13) {
            error = [[NSError alloc] initWithDomain:@"不能连续发送相同内容的微博." code:[errorCode intValue] userInfo:nil];
        }
        
        //更多错误码信息请参考：
        //http://wiki.open.t.qq.com/index.php/API%E6%96%87%E6%A1%A3/%E5%BE%AE%E5%8D%9A%E6%8E%A5%E5%8F%A3/%E5%8F%91%E8%A1%A8%E4%B8%80%E6%9D%A1%E5%BE%AE%E5%8D%9A%E4%BF%A1%E6%81%AF#.E8.AF.B7.E6.B1.82.E7.A4.BA.E4.BE.8B
        //http://wiki.open.t.qq.com/index.php/OAuth2.0%E9%89%B4%E6%9D%83/%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
        
        completion(error);
        [self checkSharedMessages];
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        completion(error);
        [self checkSharedMessages];
    };
    
    //发布文本微博
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *bodyParam = @{@"oauth_consumer_key":kTencentWeiboAppKey,
                                @"access_token":access_token,
                                @"openid":openid,
                                @"clientip":@"10.10.1.31",
                                @"oauth_version":@"2.a",
                                @"scope":@"all",
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

- (void)tencentWeiboSendTextWithImage:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion
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
        if (![errorString isEqualToString:@"ok"] && [errorCode intValue] != 0) {
            error = [[NSError alloc] initWithDomain:errorString code:[errorCode intValue] userInfo:nil];
        }
        
        //token已过期
        if ([errorCode intValue] == 37) {
            
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
        
        //表示有过多脏话，请认真检查content内容
        if ([errorCode intValue] == 4) {
            error = [[NSError alloc] initWithDomain:@"表示有过多脏话，请认真检查content内容." code:[errorCode intValue] userInfo:nil];
        }
        //不能连续发送相同内容的微博
        if([errorCode intValue] == 13) {
            error = [[NSError alloc] initWithDomain:@"不能连续发送相同内容的微博." code:[errorCode intValue] userInfo:nil];
        }
        
        //更多错误码信息请参考：
        //http://wiki.open.t.qq.com/index.php/API%E6%96%87%E6%A1%A3/%E5%BE%AE%E5%8D%9A%E6%8E%A5%E5%8F%A3/%E5%8F%91%E8%A1%A8%E4%B8%80%E6%9D%A1%E5%B8%A6%E5%9B%BE%E7%89%87%E7%9A%84%E5%BE%AE%E5%8D%9A
        //http://wiki.open.t.qq.com/index.php/OAuth2.0%E9%89%B4%E6%9D%83/%E9%94%99%E8%AF%AF%E7%A0%81%E8%AF%B4%E6%98%8E
        
        completion(error);
        [self checkSharedMessages];
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        completion(error);
        [self checkSharedMessages];
    };
    
    //发布图片微博
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *bodyParam = @{@"oauth_consumer_key":kTencentWeiboAppKey,
                                @"access_token":access_token,
                                @"openid":openid,
                                @"clientip":@"10.10.1.31",
                                @"oauth_version":@"2.a",
                                @"scope":@"all"};
    
    NSMutableURLRequest *request = [manager getRequest:@"https://open.t.qq.com/api/t/add_pic" parameters:nil success:success_callback failure:failure_callback];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"--------------------5017d5f06ada3";
    [request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    boundary = [NSString stringWithFormat:@"%@\r\n", boundary];

    //必须参数
    NSMutableString *bodyString = [NSMutableString stringWithString:[[KUnits generateURL:nil params:bodyParam] absoluteString]];
    
    //format=json
    [bodyString appendString:boundary];
    [bodyString appendString:@"Content-Disposition: form-data; name=\"format\";\r\n\r\njson"];
    
    //content＝...
    [bodyString appendString:boundary];
    [bodyString appendString:@"Content-Disposition: form-data; name=\"content\";\r\n\r\n"];
    [bodyString appendString:(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8))];
    
    //clientip=10.10.1.31
    [bodyString appendString:boundary];
    [bodyString appendString:@"Content-Disposition: form-data; name=\"clientip\";\r\n\r\n10.10.1.31"];
    
    //pic=...
    [bodyString appendString:boundary];
    [bodyString appendString:@"Content-Disposition: form-data; name=\"pic\"; filename=\"images08.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"];
    
    NSMutableData *body = [NSMutableData dataWithData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImagePNGRepresentation(image)];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (long)body.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    NSLog(@"xxxx###=%@", [request allHTTPHeaderFields]);
    
    [manager start];
}

@end
