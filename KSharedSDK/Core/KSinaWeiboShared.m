//
//  KSinaWeiboShared.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSinaWeiboShared.h"
#import "KHelper.h"
#import "KHttpManager.h"
#import "KWeiboOauthView.h"
#import "KSharedSDKDefine.h"
#import "KSharedMessage.h"
#import "KSendMessageView.h"

#define KSharedSDK_sinaWeibo_accessToken    @"KSharedSDK_sinaWeibo_accessToken"
#define KSharedSDK_sinaWeibo_uid            @"KSharedSDK_sinaWeibo_uid"

@interface KSinaWeiboShared() <KWeiboOauthViewDelegate, KSendMessageViewDelegate>
{

}
@end

@implementation KSinaWeiboShared {
    //sinaWeibo
    NSString *access_token;
    NSString *uid;
    
    //
    KSharedMessage *message;
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
    access_token = nil;
    uid = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_sinaWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:KSharedSDK_sinaWeibo_uid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    if (self = [super init]) {
        //
    }
    return self;
}

/**
 *@description 分享消息
 */

- (BOOL)share:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion
{
    if (text.length > 140 || text.length == 0) {
        return NO;
    }
    
    //添加到队列
    message = [[KSharedMessage alloc] init];
    message.text = text;
    message.image = image;
    if (completion) {
        message.completion = completion;
    }
    
    if (access_token.length == 0 || uid.length == 0) {
        access_token = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_accessToken];
        uid = [[NSUserDefaults standardUserDefaults] objectForKey:KSharedSDK_sinaWeibo_uid];
    }
    
    if (access_token.length && uid.length) {
        [self showSendMessageView];
    } else {
        [self getNewToken];
    }
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
        
        [self showSendMessageView];
        return YES;
    
    //用户取消了
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"用户取消授权!" code:ErrorType_UserCancel userInfo:nil];
        
        //通知认证失败
        message.completion(error);
        return YES;
    }
    
    return FALSE;
}

- (void)getNewToken
{
    NSDictionary *param = @{@"redirect_uri": kSinaWeiboRedirectURI,
                            @"callback_uri": kAppURLScheme,
                            @"client_id":kSinaWeiboAppKey};
    NSURL *appAuthURL = [KHelper generateURL:@"sinaweibosso://login" params:param];
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
        
        //通知认证失败
        message.completion(error);
        return;
    }
    
    access_token = [userInfo objectForKey:@"access_token"];
    uid = [userInfo objectForKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:KSharedSDK_sinaWeibo_accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:KSharedSDK_sinaWeibo_uid];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [self showSendMessageView];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //do sth in this block.
        [self showSendMessageView];
    });
}

- (void)showSendMessageView
{
    KSendMessageView *sendView = [KSendMessageView Instance];
    sendView.delegate = self;
    [sendView show];
}

- (void)sendWeiboMessage:(KSharedMessage *)m
{
    if (m.image) {
        [self sinaWeiboSendTextWithImage:m.text image:m.image completion:m.completion];
    } else {
        [self sinaWeiboSendText:m.text completion:m.completion];
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
        if ([errorCode intValue] == 21315 || [errorCode intValue] == 21327) {
            
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
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        completion(error);
    };
    
    //发一条新微博
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *params = @{@"status":text, @"access_token":access_token};
    NSMutableURLRequest *request = [manager getRequest:@"https://api.weibo.com/2/statuses/update.json" parameters:params success:success_callback failure:failure_callback];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [manager start];
}

- (void)sinaWeiboSendTextWithImage:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion
{
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
        if ([errorCode intValue] == 21315 || [errorCode intValue] == 21327) {
            
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
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        completion(error);
    };
    
    //发布图片微博
    KHttpManager *manager = [KHttpManager manager];
    NSMutableURLRequest *request = [manager getRequest:@"https://upload.api.weibo.com/2/statuses/upload.json" parameters:nil success:success_callback failure:failure_callback];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"KSharedSDK" forHTTPHeaderField:@"User-Agent"];
    
    NSString *boundary = @"--------------------5017d5f06ada3";
    NSString *boundaryEnd = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
    [request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    boundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    
    NSString *(^boundaryString)(NSString*, NSString*, NSString*) = ^(NSString *boundary, NSString *item, NSString *value) {
        return [NSString stringWithFormat:@"%@Content-Disposition: form-data; name=\"%@\";\r\n\r\n%@", boundary, item, value];
    };
    
    //access_token
    NSMutableString *bodyString = [NSMutableString stringWithString:boundaryString(boundary, @"access_token", access_token)];
    
    //status
    NSString *status = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)text,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    [bodyString appendString:boundaryString(boundary, @"status", status)];
    
    //pic=...
    [bodyString appendString:boundary];
    [bodyString appendString:@"Content-Disposition: form-data; name=\"pic\"; filename=\"file\"\r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
    
    NSMutableData *body = [NSMutableData dataWithData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImagePNGRepresentation(image)];
    [body appendData:[boundaryEnd dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[NSString stringWithFormat:@"%ld", (long)body.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    [manager start];
}

@end
