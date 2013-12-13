//
// KHookObjectWrapper.m
// ObjectHook
//
// Created by kyle on 13-12-13.
// Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KHookObjectWrapper.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation KHookObjectWrapper

+ (void)initialize
{
    //openURL
    {
        Method m = class_getInstanceMethod([UIApplication class], @selector(openURL:));
        Method mMy = class_getInstanceMethod([self class], @selector(hook_openURL:));
        
        IMP mImp = method_getImplementation(m);
        class_addMethod([UIApplication class], @selector(fake_openURL:), mImp, method_getTypeEncoding(m));
        
        IMP selfmImp = method_getImplementation(mMy);
        class_replaceMethod([UIApplication class], @selector(openURL:), selfmImp, method_getTypeEncoding(m));
    }
    
    //CanOpenURL
    {
        Method m = class_getInstanceMethod([UIApplication class], @selector(canOpenURL:));
        Method mMy = class_getInstanceMethod([self class], @selector(hook_canOpenURL:));
        
        IMP mImp = method_getImplementation(m);
        class_addMethod([UIApplication class], @selector(fake_canOpenURL:), mImp, method_getTypeEncoding(m));
        
        IMP selfmImp = method_getImplementation(mMy);
        class_replaceMethod([UIApplication class], @selector(canOpenURL:), selfmImp, method_getTypeEncoding(m));
    }
}

- (BOOL)hook_openURL:(NSURL *)url
{
    NSLog(@"hook_openURL:%@", [url absoluteString]);
    return [self fake_openURL:url];
}

//fake method, never run.
- (BOOL)fake_openURL:(NSURL *)url
{
    abort();
    return YES;
}


- (BOOL)hook_canOpenURL:(NSURL *)url
{
    NSLog(@"hook_canOpenURL:%@", [url absoluteString]);
    return [self fake_canOpenURL:url];
}

//fake method, never run.
- (BOOL)fake_canOpenURL:(NSURL *)url
{
    abort();
    return YES;
}

@end
