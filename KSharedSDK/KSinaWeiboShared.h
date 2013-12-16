//
//  KSinaWeiboShared.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSinaWeiboShared : NSObject

+ (instancetype)Instance;

- (void)clearToken;

- (BOOL)sharedMessage:(NSString *)text completion:(void(^)(NSError *))completion;

- (BOOL)sharedImage:(UIImage *)image completion:(void(^)(NSError *))completion;

- (BOOL)sharedHandleURL:(NSString *)paramString;

@end
