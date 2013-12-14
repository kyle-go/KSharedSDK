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

@interface KQQChatShared() <QQApiInterfaceDelegate>

@end

@implementation KQQChatShared {
    void(^_completionBlock)(NSError *);
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
        QQApiObject *obj = [[QQApiObject alloc] init];
        obj.title = @"qq message title.";
        obj.description = content;
        obj.cflag = 0;
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:obj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void) sendMsgToQQZone:(NSString*)content title:(NSString*)title image:(UIImage*)image weburl:(NSString*)url scene:(int)scene
{
    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi])
    {

        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void)sharedHandleURL:(NSURL *)url
{
    [QQApiInterface handleOpenURL:url delegate:self];
}

#pragma mark ----- WXApiDelegate ----
- (void)onReq:(QQBaseReq *)req
{
    
}

- (void)isOnlineResponse:(NSDictionary *)response
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

@end
