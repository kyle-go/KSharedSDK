//
//  KSharedSDK.h
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

//定义分享类型
enum
{
    SharedType_SinaWeibo = 1,
    SharedType_TencentWeibo,
    SharedType_WeChatFriend,
    SharedType_WeChatCircel,
    SharedType_QQChat,
    SharedType_Unknown,
};
typedef NSUInteger SharedType;

//定义错误类型
enum
{
    ErrorType_Succeed = 0,  //成功
    ErrorType_UserCancel,   //用户已取消操作
    ErrorType_NoAppClient,  //未安装客户端，或者客户端版本太旧
    ErrorType_Unknown,
};
typedef NSUInteger ErrorType;

@interface KSharedSDK : NSObject

/**
 *@description 获取单实例
 */
+ (instancetype)Instance;

/**
 *@description 清除内存中保存的token等信息
 */
- (void)clearTokens;

/**
 *@description 分享文本
 */
- (BOOL)shareText:(NSString *)text type:(SharedType)type completion:(void(^)(NSError *))completion;

/**
 *@description 分享图片
 */
- (BOOL)shareImage:(UIImage *)image type:(SharedType)type completion:(void(^)(NSError *))completion;

/**
 *@description 分享新闻
 */
- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage*)image url:(NSString*)urlstring type:(SharedType)type completion:(void(^)(NSError *))completion;

/**
 *@description 处理系统回调, 在AppDelegate实现：-(BOOL)application:openURL:sourceApplication:annotation:方法并调用此函数
 */
- (BOOL)handleURL:(NSURL *)url;

@end
