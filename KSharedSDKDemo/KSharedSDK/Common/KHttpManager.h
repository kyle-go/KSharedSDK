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

- (NSMutableURLRequest *)getRequest:(NSString *)URLString parameters:(NSDictionary *)parameters
                            success:(void (^)(id))success
                            failure:(void (^)(NSError *))failure;

- (void)start;

@end
