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

- (BOOL)shareTextToFriend:(NSString *)text completion:(void(^)(NSError *))completion;

- (BOOL)shareTextToCircel:(NSString *)text completion:(void(^)(NSError *))completion;

- (BOOL)shareImageToFriend:(UIImage *)image completion:(void(^)(NSError *))completion;

- (BOOL)shareImageToCircel:(UIImage *)image completion:(void(^)(NSError *))completion;

- (BOOL)shareNewsToFriend:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (BOOL)shareNewsToCircel:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (BOOL)handleURL:(NSURL *)url;

@end
