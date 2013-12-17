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
        class_addMethod([UIApplication class], @selector(hook_openURL:), method_getImplementation(m), method_getTypeEncoding(m));
        method_setImplementation(m, class_getMethodImplementation([self class], @selector(hook_openURL:)));
    }
    
    //CanOpenURL
    {
        Method m = class_getInstanceMethod([UIApplication class], @selector(canOpenURL:));
        class_addMethod([UIApplication class], @selector(hook_canOpenURL:), method_getImplementation(m), method_getTypeEncoding(m));
        method_setImplementation(m, class_getMethodImplementation([self class], @selector(hook_canOpenURL:)));
    }
    
    //NSKeyedArchiver
    {
        Method m = class_getInstanceMethod([NSKeyedArchiver class], @selector(encodeObject:forKey:));
        class_addMethod([NSKeyedArchiver class], @selector(hook_encodeObject:forKey:), method_getImplementation(m), method_getTypeEncoding(m));
        method_setImplementation(m, class_getMethodImplementation([self class], @selector(hook_encodeObject:forKey:)));
    }
}

- (BOOL)hook_openURL:(NSURL *)url
{
    NSLog(@"hook_openURL:%@", [url absoluteString]);
    
    //4815
//    UIPasteboard *paste = [UIPasteboard generalPasteboard];
//    NSArray *array = [paste pasteboardTypes];
//    for (NSString *item in array) {
//        NSData *d = [paste dataForPasteboardType:item];
//        if (d) {
//            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:d];
//            id userData = [unarchiver decodeObjectForKey:@"root"];
//            [unarchiver finishDecoding];
//            //QQApiNewsObject *
//            NSLog(@"dddsfdsdf");
//        }
//    }
    
    BOOL b = [self hook_openURL:url];
    return b;
}

- (BOOL)hook_canOpenURL:(NSURL *)url
{
    NSLog(@"hook_canOpenURL:%@", [url absoluteString]);
    return [self hook_canOpenURL:url];
}

- (void)hook_encodeObject:(id)objv forKey:(NSString *)key
{
    [self hook_encodeObject:objv forKey:key];
}

@end
