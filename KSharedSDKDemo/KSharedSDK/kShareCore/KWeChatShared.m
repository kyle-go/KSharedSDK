//
//  KWeChatShared.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSharedSDK.h"
#import "KWeChatShared.h"
#import "KSharedSDKDefine.h"
#import "WXApi.h"

@interface KWeChatShared() <WXApiDelegate>

@end

@implementation KWeChatShared {
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
        [WXApi registerApp:kWeChatAppKey];
        _completionBlock = ^(NSError* e){};
    }
    return self;
}

- (void)shareTextToFriend:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToWX:text scene:WXSceneSession];
}

- (void)shareTextToCircel:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToWX:text scene:WXSceneTimeline];
}

- (void)shareImageToFriend:(UIImage *)image completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendImageToWX:image scene:WXSceneSession];
}

- (void)shareImageToCircel:(UIImage *)image completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendImageToWX:image scene:WXSceneTimeline];
}

- (void)shareNewsToFriend:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendNewsToWX:content title:title image:image weburl:urlString scene:WXSceneSession];
}

- (void)shareNewsToCircel:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendNewsToWX:content title:title image:image weburl:urlString scene:WXSceneTimeline];
}
/*
 enum WXScene {
    WXSceneSession  = 0,        //聊天界面
    WXSceneTimeline = 1,        //朋友圈
    WXSceneFavorite = 2,        //收藏
 };
*/
- (void) sendTextToWX:(NSString *)content scene:(int)scene
{
    if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.text = content;
        req.bText = YES;
        req.scene = scene;
        [WXApi sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装微信客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
    }
}

- (void) sendImageToWX:(UIImage *)image scene:(int)scene
{
    if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        
        WXImageObject* imageObject = [[WXImageObject alloc] init];
        imageObject.imageData = UIImageJPEGRepresentation([image compressImageToSize:200.f],1.f);
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.mediaObject = imageObject;
        [message setThumbImage:[image compressImageToSize:80.f]];
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        [WXApi sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装微信客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
    }
}

- (void) sendNewsToWX:(NSString*)content title:(NSString*)title image:(UIImage*)image weburl:(NSString*)url scene:(int)scene
{
    if([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = content;
        [message setThumbImage:[image compressImageToSize:80.f]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装微信客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
    }
}

- (BOOL)handleURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark ----- WXApiDelegate ----
- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SendMessageToWXResp* r = (SendMessageToWXResp*)resp;
        NSError *e;
        if (r.errCode != 0) {
            NSString *errStr = r.errStr.length? r.errStr : @"Unknow error!";
            e = [NSError errorWithDomain:errStr code:r.errCode userInfo:nil];
        }
        _completionBlock(e);
    }
}

@end
