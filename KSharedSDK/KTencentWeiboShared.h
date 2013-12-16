//
//  KTencentWeiboShared.h
//  KSharedSDKDemo
//
//  Created by kyle on 12/12/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTencentWeiboShared : NSObject

+ (instancetype)Instance;

- (void)clearToken;

- (BOOL)shareText:(NSString *)text completion:(void(^)(NSError *))completion;

- (BOOL)shareImage:(UIImage *)image completion:(void(^)(NSError *))completion;

@end
