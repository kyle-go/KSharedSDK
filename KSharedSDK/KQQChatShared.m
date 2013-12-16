//
//  KQQChatShared.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/14/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KQQChatShared.h"
#import "KSharedSDKDefine.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

@interface KQQChatShared() <QQApiInterfaceDelegate>

@end

@implementation KQQChatShared {
    void(^_completionBlock)(NSError *);
    TencentOAuth *tencentOAuth;
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
        _completionBlock = ^(NSError* e){};
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQChatAppKey andDelegate:nil];
    }
    return self;
}

- (void)sharedMessageToFriend:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToQQ:text];
}

- (void)sharedMessageToZone:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToQQ:text];
}

- (void) sendTextToQQ:(NSString*)content
{
    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {
        QQApiNewsObject *object = [QQApiNewsObject objectWithURL:[[NSURL alloc]initWithString:@"http://baidu.com"] title:@"title" description:content previewImageData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share" ofType:@"png"]]];
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
        req.type = ESENDMESSAGETOQQREQTYPE;
        QQApiSendResultCode resultCode = [QQApiInterface sendReq:req];
        if (resultCode != EQQAPISENDSUCESS) {
            NSError *e = [NSError errorWithDomain:@"sendReq failed." code:resultCode userInfo:nil];
            _completionBlock(e);
        }
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void) sendMsgToQQZone:(NSString*)content title:(NSString*)title image:(UIImage*)image weburl:(NSString*)url scene:(int)scene
{
    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {
        //
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void)sharedHandleURL:(NSURL *)url
{
    [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark ----- QQApiInterfaceDelegate ----
- (void)onReq:(QQBaseReq *)req
{
    
}

- (void)onResp:(QQBaseReq *)resp
{
    if([resp isKindOfClass:[SendMessageToQQResp class]])
    {
        SendMessageToQQResp* r = (SendMessageToQQResp*)resp;
        NSError *e;
        if (r.errorDescription) {
            e = [NSError errorWithDomain:r.errorDescription code:-1 userInfo:nil];
        }
        _completionBlock(e);
    }
}

- (void)isOnlineResponse:(NSDictionary *)response
{
    
}

@end
