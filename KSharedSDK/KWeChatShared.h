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

- (void)sharedMessageToFriend:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)sharedMessageToCircel:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)sharedImageToFriend:(UIImage *)image completion:(void(^)(NSError *))completion;

- (void)sharedImageToCircel:(UIImage *)image completion:(void(^)(NSError *))completion;

- (void)sharedNewsToFriend:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (void)sharedNewsToCircel:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)urlString completion:(void(^)(NSError *))completion;

- (BOOL)sharedHandleURL:(NSURL *)url;

@end
