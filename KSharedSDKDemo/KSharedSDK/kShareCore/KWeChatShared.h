//
//  KWeChatShared.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWeChatShared : NSObject

+ (instancetype)Instance;

- (void)shareTextToFriend:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)shareTextToCircel:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)shareImageToFriend:(UIImage *)image completion:(void(^)(NSError *))completion;

- (void)shareImageToCircel:(UIImage *)image completion:(void(^)(NSError *))completion;

- (void)shareNewsToFriend:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (void)shareNewsToCircel:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (BOOL)handleURL:(NSURL *)url;

@end
