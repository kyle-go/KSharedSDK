//
//  KShareViewManage.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-19.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KShareViewManage.h"
#import "HYActivityView.h"
#import "EditBlogViewController.h"

@implementation KShareViewManage

+ (void)showViewToShareText:(NSString *)text platform:(NSArray *)platform inView:(UIView *)view
{
    HYActivityView *activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:view];
    
    //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
    activityView.numberOfButtonPerLine = 4;
    ButtonView *bv;
    
    for (NSNumber *type in platform) {
        switch ([type unsignedIntValue]) {
            case SharedType_SinaWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"新浪微博" image:[UIImage imageNamed:@"share_platform_sina"] handler:^(ButtonView *buttonView){
                    EditBlogViewController *editBlogViewController = [[EditBlogViewController alloc] init];
                    [editBlogViewController showWithSendText:text type:SharedType_SinaWeibo];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_QQChat:
            {
                bv = [[ButtonView alloc]initWithText:@"QQ" image:[UIImage imageNamed:@"share_platform_qqfriends"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareText:text type:SharedType_QQChat completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_TencentWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"腾讯微博" image:[UIImage imageNamed:@"share_platform_TencentWeibo"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareText:text type:SharedType_TencentWeibo completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatFriend:
            {
                bv = [[ButtonView alloc]initWithText:@"微信" image:[UIImage imageNamed:@"share_platform_wechat"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareText:text type:SharedType_WeChatFriend completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatCircel:
            {
                bv = [[ButtonView alloc]initWithText:@"微信朋友圈" image:[UIImage imageNamed:@"share_platform_wechattimeline"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareText:text type:SharedType_WeChatCircel completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            default:
                break;
        }
    }
    
    [activityView show];
}


+ (void)showViewToShareImge:(UIImage *)image platform:(NSArray *)platform inView:(UIView *)view
{
    HYActivityView *activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:view];
    
    //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
    activityView.numberOfButtonPerLine = 4;
    ButtonView *bv;
    
    for (NSNumber *type in platform) {
        switch ([type unsignedIntValue]) {
            case SharedType_SinaWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"新浪微博" image:[UIImage imageNamed:@"share_platform_sina"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareImage:image type:SharedType_SinaWeibo completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_QQChat:
            {
                bv = [[ButtonView alloc]initWithText:@"QQ" image:[UIImage imageNamed:@"share_platform_qqfriends"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareImage:image type:SharedType_QQChat completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_TencentWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"腾讯微博" image:[UIImage imageNamed:@"share_platform_TencentWeibo"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareImage:image type:SharedType_TencentWeibo completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatFriend:
            {
                bv = [[ButtonView alloc]initWithText:@"微信" image:[UIImage imageNamed:@"share_platform_wechat"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareImage:image type:SharedType_WeChatFriend completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatCircel:
            {
                bv = [[ButtonView alloc]initWithText:@"微信朋友圈" image:[UIImage imageNamed:@"share_platform_wechattimeline"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareImage:image type:SharedType_WeChatCircel completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            default:
                break;
        }
    }
    
    [activityView show];
}

+ (void)showViewToShareNews:(NSString *)title Content:(NSString *)content Image:(UIImage *)image Url:(NSString *)url platform:(NSArray *)platform inView:(UIView *)view
{
    HYActivityView *activityView = [[HYActivityView alloc]initWithTitle:@"分享到" referView:view];
    
    //横屏会变成一行6个, 竖屏无法一行同时显示6个, 会自动使用默认一行4个的设置.
    activityView.numberOfButtonPerLine = 4;
    ButtonView *bv;
    
    for (NSNumber *type in platform) {
        switch ([type unsignedIntValue]) {
            case SharedType_SinaWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"新浪微博" image:[UIImage imageNamed:@"share_platform_sina"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareNews:title Content:content Image:image url:url type:SharedType_SinaWeibo completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_QQChat:
            {
                bv = [[ButtonView alloc]initWithText:@"QQ" image:[UIImage imageNamed:@"share_platform_qqfriends"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareNews:title Content:content Image:image url:url type:SharedType_QQChat completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_TencentWeibo:
            {
                bv = [[ButtonView alloc]initWithText:@"腾讯微博" image:[UIImage imageNamed:@"share_platform_TencentWeibo"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareNews:title Content:content Image:image url:url type:SharedType_TencentWeibo completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatFriend:
            {
                bv = [[ButtonView alloc]initWithText:@"微信" image:[UIImage imageNamed:@"share_platform_wechat"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareNews:title Content:content Image:image url:url type:SharedType_WeChatFriend completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            case SharedType_WeChatCircel:
            {
                bv = [[ButtonView alloc]initWithText:@"微信朋友圈" image:[UIImage imageNamed:@"share_platform_wechattimeline"] handler:^(ButtonView *buttonView){
                    [[KSharedSDK Instance] shareNews:title Content:content Image:image url:url type:SharedType_WeChatCircel completion:^(NSError *e){
                        if (e) {
                            NSLog(@"shareText failed. Error = %@", e);
                        } else {
                            NSLog(@"shareText sinaWeibo succeed.");
                        }
                    }];
                }];
                [activityView addButtonView:bv];
            }
                break;
                
            default:
                break;
        }
    }
    
    [activityView show];
}

+ (NSArray *)getShareListWithType:(SharedType)sharedType, ...
{
    va_list args;
    va_start(args, sharedType);
    
    NSMutableArray *typeList = [[NSMutableArray alloc] init];
    
    for (SharedType type=sharedType; type != (SharedType)nil; type = va_arg(args, SharedType)) {
        [typeList addObject:[NSNumber numberWithUnsignedInt:type]];
    }
    
    va_end(args);
    return typeList;
}
@end
