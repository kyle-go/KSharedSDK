//
//  shareMessageInfo.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSharedMessage : NSObject

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) void(^completion)(NSError *);

@end
