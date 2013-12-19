//
//  KShareViewManage.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-19.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSharedSDK.h"

@interface KShareViewManage : NSObject

/**
 *	@brief	分享静态文本到需要平台
 *
 *	@param 	text     分享的文本内容
 *          platform 社会化平台类型 通过getShareListWithType获取
 *          inView   在某视图中显示
 *
 *	@return	空
 */
+ (void)showViewToShareText:(NSString *)text platform:(NSArray *)platform inView:(UIView *)view;

/**
 *	@brief	分享静态文本到需要平台
 *
 *	@param 	image    分享的图片内容
 *          platform 社会化平台类型 通过getShareListWithType获取
 *          inView   在某视图中显示
 *
 *	@return	空
 */
+ (void)showViewToShareImge:(UIImage *)image platform:(NSArray *)platform inView:(UIView *)view;

/**
 *	@brief	分享静态文本到需要平台
 *
 *	@param 	title    新闻标题
 *          content  新闻内容
 *          image    新闻图片
 *          url      新闻链接
 *          platform 社会化平台类型 通过getShareListWithType获取
 *          inView   在某视图中显示
 *
 *	@return	空
 */
+ (void)showViewToShareNews:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)url platform:(NSArray *)platform inView:(UIView *)view;

/**
 *	@brief	获取分享列表
 *
 *	@param 	shareType 	社会化平台类型
 *
 *	@return	分享列表
 */
+ (NSArray *)getShareListWithType:(SharedType)sharedType, ... NS_REQUIRES_NIL_TERMINATION;
@end
