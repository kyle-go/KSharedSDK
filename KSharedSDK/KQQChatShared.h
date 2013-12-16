//
//  KQQChatShared.h
//  KSharedSDKDemo
//
//  Created by kyle on 12/14/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KQQChatShared : NSObject

+ (instancetype)Instance;

- (void)shareTextToFriend:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)shareTextToZone:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)handleURL:(NSURL *)url;

@end
