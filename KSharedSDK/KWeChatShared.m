//
//  KWeChatShared.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

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

- (void)sharedMessageToFriend:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToWX:text scene:WXSceneSession];
}

- (void)sharedMessageToCircel:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToWX:text scene:WXSceneTimeline];
}

/*
 enum WXScene {
    WXSceneSession  = 0,        //聊天界面
    WXSceneTimeline = 1,        //朋友圈
    WXSceneFavorite = 2,        //收藏
 };
*/
- (void) sendTextToWX:(NSString*)content scene:(int)scene
{
    if([WXApi isWXAppInstalled]) {
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.text = content;
        req.bText = YES;
        req.scene = scene;
        [WXApi sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装微信客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void) sendMsgToWX:(NSString*)content title:(NSString*)title image:(UIImage*)image weburl:(NSString*)url scene:(int)scene
{
    if([WXApi isWXAppInstalled])
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = content;
        [message setThumbImage:image];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        
    } else {
        NSError *e = [NSError errorWithDomain:@"未安装微信客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
}

- (void)sharedHandleURL:(NSURL *)url
{
    [WXApi handleOpenURL:url delegate:self];
}

#pragma mark ----- WXApiDelegate ----
-(void) onReq:(BaseReq *)req
{
    
}

-(void) onResp:(BaseResp *)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SendMessageToWXResp* r = (SendMessageToWXResp*)resp;
        NSError *e;
        if (r.errStr) {
            e = [NSError errorWithDomain:r.errStr code:r.errCode userInfo:nil];
        }
        _completionBlock(e);
    }
}

@end
