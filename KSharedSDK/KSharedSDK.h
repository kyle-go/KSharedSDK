//
//  KSharedSDK.h
//  KSharedSDKDemo
//
//  Created by kyle on 12/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSharedSDKDefine.h"

//定义分享类型
enum
{
    SharedType_SinaWeibo = 0,
    SharedType_TencentWeibo,
    SharedType_WeixinFriend,
    SharedType_WeixinCircel,
    SharedType_QQFriend,
    SharedType_QQZone,
    SharedType_Unknown,
};
typedef NSUInteger SharedType;


@interface KSharedSDK : NSObject

/**
 *@description 获取单实例
 */
+ (instancetype)sharedSDKInstance;

/**
 *@description 清除内存中保存的token等信息
 */
- (void)sharedClearTokens;

/**
 *@description 分享消息
 */
- (BOOL)sharedMessage:(NSString *)text type:(SharedType)type completion:(void(^)(NSError *))completion;

/**
 *@description 处理系统回调,在AppDelegate实现方法：-(BOOL)application: openURL: sourceApplication: annotation:方法并调用此函数
 */
- (BOOL)sharedHandleURL:(NSURL *)url;

@end
