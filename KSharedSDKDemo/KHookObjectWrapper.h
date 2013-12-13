//
// KHookObjectWrapper.h
// ObjectHook
//
// Created by kyle on 13-12-13.
// Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KHookObjectWrapper : NSObject

+ (void)initialize;
- (BOOL)fake_openURL:(NSURL *)url;
- (BOOL)fake_canOpenURL:(NSURL *)url;

@end