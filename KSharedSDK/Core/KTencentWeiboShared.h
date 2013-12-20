//
//  KTencentWeiboShared.h
//  KSharedSDKDemo
//
//  Created by kyle on 12/12/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! @brief 腾讯微博接口函数类
 *
 * 该类封装了腾讯微博相关所有接口
 * 腾讯微博App太坑了，跳转到app授权经常莫名失败，故本类只提供web页面授权登录
 *
 * 该类不依赖任何第三方库
 */
@interface KTencentWeiboShared : NSObject

+ (instancetype)Instance;

- (void)clearToken;

- (BOOL)share:(NSString *)text image:(UIImage *)image completion:(void(^)(NSError *))completion;

@end
