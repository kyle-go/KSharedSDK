//
//  KUnits.h
//  Keibo
//
//  Created by kyle on 11/10/13.
//  Copyright (c) 2013 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KUnits : NSObject

//获取一个uuid字符串
+ (NSString *)generateUuidString;

//格式化一个http连接
+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;

//获取屏幕
+ (CGRect)XYScreenBounds;

@end
