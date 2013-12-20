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

/*! @brief 获取单实例
 *  @return 单实例
 */
+ (instancetype)Instance;

/*! @brief 日志系统
 *  @param YES开启日志输出，NO关闭日志输出，默认开启
 */
- (void)enableDebugLog:(BOOL)enableDebugLog;

/*! @brief 清除内存中保存的token等信息
 *
 */
- (void)clearTokens;

/*! @brief 分享文本
 *  @param text 文本信息
 *  @param type 分享类型
 *  @param completion 回调函数，如果回调函数参数为nil则说明分享成功，否则为错误类型
 *  @return 成功返回YES，失败返回NO，错误信息请查看输出日志
 */
- (BOOL)shareText:(NSString *)text type:(SharedType)type completion:(void(^)(NSError *))completion;

/*! @brief 分享图片
 *  @param image 待分享的图片，不能为空
 *  @Param type 分享类型
 *  @param completion 回调函数，如果回调函数参数为nil则说明分享成功，否则为错误类型
 *  @return @return 成功返回YES，失败返回NO，错误信息请查看输出日志
 */
- (BOOL)shareImage:(UIImage *)image type:(SharedType)type completion:(void(^)(NSError *))completion;

/*! @brief 分享新闻
 *  @param title 新闻标题
 *  @param content 新闻内容
 *  @param image 新闻图片
 *  @Param type 分享类型，不支持新浪微博，腾讯微博
 *  @param completion 回调函数，如果回调函数参数为nil则说明分享成功，否则为错误类型
 *  @return @return 成功返回YES，失败返回NO，错误信息请查看输出日志
 *
 *  @attention 分享类型不支持新浪微博，腾讯微博
 */
- (BOOL)shareNews:(NSString *)title Content:(NSString *)content Image:(UIImage*)image url:(NSString*)urlstring type:(SharedType)type completion:(void(^)(NSError *))completion;

/*! @brief 处理系统回调
 *  @param url 从其他应用返回的url
 *  @return 成功返回YES，失败返回FALSE
 *
 *  @attention 在AppDelegate实现：-(BOOL)application:openURL:sourceApplication:annotation:并调用此函数
 */
- (BOOL)handleURL:(NSURL *)url;

@end
