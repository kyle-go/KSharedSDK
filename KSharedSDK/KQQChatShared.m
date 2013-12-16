//
//  KQQChatShared.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/14/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KQQChatShared.h"
#import "KSharedSDKDefine.h"

@interface KQQChatShared()

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

- (void)shareText:(NSString *)text completion:(void(^)(NSError *))completion
{
    _completionBlock = completion;
    [self sendTextToQQ:text];
}

- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion
{
    if (completion) {
        _completionBlock = completion;
    }
    
    NSString *tempString;
    
    NSMutableString *param = [[NSMutableString alloc] init];
    [param setString:@"mqqapi://share/to_fri?callback_type=scheme&version=1&src_type=app&"];
    [param appendString:[NSString stringWithFormat:@"callback_name=%@&", kQQChatURLScheme]];
    
    tempString = [NSString stringWithFormat:@"title=%@&", [[title dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [param appendString:tempString];
    
    tempString = [NSString stringWithFormat:@"description=%@&", [[content dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [param appendString:tempString];
    
    tempString = [NSString stringWithFormat:@"thirdAppDisplayName=%@&", [[kAppName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [param appendString:tempString];
    
    [param appendString:@"objectlocation=pasteboard&"];
    
    tempString = [NSString stringWithFormat:@"url=%@&", [[urlString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
    [param appendString:tempString];
    
    [param appendString:@"file_type=news&generalpastboard=1&cflag=0&shareType=0"];
    
    NSURL *url = [[NSURL alloc] initWithString:param];
    
    NSData *dataImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share" ofType:@"png"]];
    
    NSMutableData *d = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:d];
    NSMutableDictionary *sendParam = [[NSMutableDictionary alloc] init];
    [sendParam setObject:dataImage forKey:@"previewimagedata"];
    [archiver encodeObject:sendParam forKey:@"root"];
    [archiver finishEncoding];
    
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    [paste setPersistent:YES];
    [paste setValue:d forPasteboardType:@"com.tencent.mqq.api.apiLargeData"];
    
    BOOL result = [[UIApplication sharedApplication] openURL:url];
    if (!result) {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
        _completionBlock(e);
    }
    return result;
}

- (void) sendTextToQQ:(NSString*)content
{
//    if([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {
//        QQApiNewsObject *object = [QQApiNewsObject objectWithURL:[[NSURL alloc]initWithString:@"http://baidu.com"] title:@"title" description:content previewImageData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"share" ofType:@"png"]]];
//        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:object];
//        req.type = ESENDMESSAGETOQQREQTYPE;
//        QQApiSendResultCode resultCode = [QQApiInterface sendReq:req];
//        if (resultCode != EQQAPISENDSUCESS) {
//            NSError *e = [NSError errorWithDomain:@"sendReq failed." code:resultCode userInfo:nil];
//            _completionBlock(e);
//        }
//    } else {
//        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:-1 userInfo:nil];
//        _completionBlock(e);
//    }
}

- (BOOL)handleURL:(NSURL *)url
{
    return YES;
     //[QQApiInterface handleOpenURL:url delegate:self];
}

@end
