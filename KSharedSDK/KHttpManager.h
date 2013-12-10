//
//  KHttpManager.h
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHttpManager : NSObject

+ (KHttpManager *) manager;

- (void)GET:(NSString *)URLString parameters:(NSDictionary *)parameters
    success:(void (^)(id responseData))success
    failure:(void (^)(NSError *))failure;

@end
