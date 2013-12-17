//
//  shareMessageInfo.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-12.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSharedMessage.h"

@implementation KSharedMessage

- (id)init
{
    if (self = [super init]) {
        self.completion = ^(NSError *e){};
    }
    return self;
}

@end
