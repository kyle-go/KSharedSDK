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

- (void)sharedMessageToFriend:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)sharedMessageToZone:(NSString *)text completion:(void(^)(NSError *))completion;

- (void)sharedHandleURL:(NSURL *)url;

@end
