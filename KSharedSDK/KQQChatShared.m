//
//  KQQChatShared.m
//  KSharedSDKDemo
//
//  Created by kyle on 12/14/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import "KSharedSDK.h"
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

- (BOOL)isQQAppClientSupport
{
    NSURL *mqq = [[NSURL alloc] initWithString:@"mqq:"];
    NSURL *mqqapi = [[NSURL alloc] initWithString:@"mqqapi:"];
    NSURL *mqqsdkv2 = [[NSURL alloc] initWithString:@"mqqopensdkapiV2:"];
    
    if ([[UIApplication sharedApplication] canOpenURL:mqq] &&
        [[UIApplication sharedApplication] canOpenURL:mqqapi] &&
        [[UIApplication sharedApplication] canOpenURL:mqqsdkv2]) {
        return YES;
    }
    return NO;
}

- (BOOL)shareText:(NSString *)text completion:(void(^)(NSError *))completion
{
    if (completion) {
        _completionBlock = completion;
    }
    
    if (![self isQQAppClientSupport]) {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
        return YES;
    }
    
    NSMutableString *param = [[NSMutableString alloc] init];
    [param setString:@"mqqapi://share/to_fri?file_type=text&"];
    [param appendString:[NSString stringWithFormat:@"callback_name=%@&", kQQChatURLScheme]];
    [param appendString:[NSString stringWithFormat:@"callback_type=scheme&src_type=app&file_data=%@&", [[text dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]]];
    [param appendString:@"version=1&generalpastboard=1"];
    
    NSURL *url = [[NSURL alloc] initWithString:param];
    BOOL result = [[UIApplication sharedApplication] openURL:url];
    if (!result) {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
    }
    return result;
}

- (BOOL)shareImage:(UIImage *)image completion:(void(^)(NSError *))completion
{
    return YES;
}

- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion
{
    if (completion) {
        _completionBlock = completion;
    }
    if (![self isQQAppClientSupport]) {
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:ErrorType_NoAppClient userInfo:nil];
        _completionBlock(e);
        return YES;
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
        NSError *e = [NSError errorWithDomain:@"未安装QQ客户端." code:ErrorType_NoAppClient userInfo:nil];
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
