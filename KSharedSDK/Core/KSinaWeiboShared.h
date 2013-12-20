//
//  KSinaWeiboShared.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! @brief 新浪微博接口函数类
 *
 * 该类封装了新浪微博相关所有接口
 * 若已安装新浪微博官方App，则跳转到新浪微博官方App进行授权登录，否则打开web页面授权登录。
 * 
 * 该类不依赖任何第三方库
 */
@interface KSinaWeiboShared : NSObject

+ (instancetype)Instance;

- (void)clearToken;

- (BOOL)share:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion;

- (BOOL)handleURL:(NSString *)paramString;

@end
