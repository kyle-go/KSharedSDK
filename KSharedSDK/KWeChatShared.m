//
//  KWeChatShared.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KWeChatShared.h"
#import "KSharedSDKDefine.h"

@implementation KWeChatShared

+ (instancetype)sharedSDKInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        //注册微信
        [WXApi registerApp:kWeChatAppKey];
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
    WXSceneSession  = 0,        // 聊天界面
    WXSceneTimeline = 1,         // 朋友圈
    WXSceneFavorite = 2,        // 收藏
 };
*/
- (void) sendTextToWX:(NSString*)content scene:(int)scene
{
    if([WXApi isWXAppInstalled])
    {
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.text = content;
        req.bText = YES;
        req.scene = scene;
        
        [WXApi sendReq:req];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"本机未安装微信客户端"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
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
        req.scene = scene;  //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
        
        [WXApi sendReq:req];
    }
    //如果没有安装微信，提示
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"本机未安装微信客户端"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)sharedHandleURL:(NSURL *)url
{
    [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - wx delegate
-(void) onReq:(BaseReq *)req
{
    //
}

-(void) onResp:(BaseResp *)resp
{
    //微信
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        /*NSString *strTitle = [NSString stringWithFormat:@"发送结果"];
         NSString *strMsg = [NSString stringWithFormat:@"发送消息结果:%d", resp.errCode];
         NSLog(@"%@",strMsg);
         
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         
         [alert show];*/
        SendMessageToWXResp* r = (SendMessageToWXResp*)resp;
        NSError *e;
        if (r.errStr) {
            e = [NSError errorWithDomain:r.errStr code:r.errCode userInfo:nil];
        }
        if (_completionBlock) {
            ((void(^)(NSError *))_completionBlock)(e);
        }
    }
}


@end
