//
//  ViewController.m
//  KSharedSDKDemo
//
//  Created by kyle on 13-12-9.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "ViewController.h"
#import "KSharedSDK.h"
#import "KShareViewManage.h"

@interface ViewController () <UIActionSheetDelegate>

@end

@implementation ViewController {
    SharedType _sharedType;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendSinaWeibo:(id)sender {
    _sharedType = SharedType_SinaWeibo;
    [self showActionSheet];
}

- (IBAction)sendTencentWeibo:(id)sender {
    [[KSharedSDK Instance] shareImage:[UIImage imageNamed:@"share"] type:SharedType_TencentWeibo completion:^(NSError *e){
        if (e) {
            NSLog(@"shareImage failed. Error = %@", e);
        } else {
            NSLog(@"shareImage succeed.");
        }
    }];
//    _sharedType = SharedType_TencentWeibo;
//    [self showActionSheet];
}

- (IBAction)sendWeixinFriend:(id)sender {
    _sharedType = SharedType_WeChatFriend;
    [self showActionSheet];
}

- (IBAction)sendWeixinCircel:(id)sender {
    _sharedType = SharedType_WeChatCircel;
    [self showActionSheet];
}

- (IBAction)sendQQChat:(id)sender {
    _sharedType = SharedType_QQChat;
    [self showActionSheet];
}

- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                              otherButtonTitles:@"文本", @"图片", @"新闻", nil];

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(actionClick:) withObject:[NSNumber numberWithInt:buttonIndex] afterDelay:1.0];
}

- (void)actionClick:(NSNumber *)num
{
    NSInteger buttonIndex = [num longValue];
    switch (buttonIndex) {
            //文本
        case 0:
            [[KSharedSDK Instance] shareText:@"发布一条新微博！喵～by KSharedSDK." type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareText failed. Error = %@", e);
                } else {
                    NSLog(@"shareText sinaWeibo succeed.");
                }
            }];
            break;
            //图片
        case 1:
            [[KSharedSDK Instance] shareImage:[UIImage imageNamed:@"kSharedSDK"] type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareImage failed. Error = %@", e);
                } else {
                    NSLog(@"shareImage succeed.");
                }
            }];
            break;
            //新闻
        case 2:
            [[KSharedSDK Instance] shareNews:@"发新闻拉" Content:@"发布一条新微博！喵～by KSharedSDK." Image:[UIImage imageNamed:@"kSharedSDK"] url:@"http://baidu.com" type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareNews failed. Error = %@", e);
                } else {
                    NSLog(@"shareNews succeed.");
                }
            }];
            break;
            //取消
        case 3:
            break;
        default:
            break;
    }
}


- (IBAction)showShareMessageView:(id)sender {

    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo,nil];
    
    [KShareViewManage showViewToShareText:@"发布一条新微博！喵～by KSharedSDK."
                                 platform:platform
                         inViewController:self];
}

- (IBAction)showShareImageView:(id)sender {
    
    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo,nil];
    
    [KShareViewManage showViewToShareImge:[UIImage imageNamed:@"kSharedSDK"]
                                 platform:platform
                         inViewController:self];
}

- (IBAction)showShareNewsView:(id)sender {
    
    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo,nil];
    
    [KShareViewManage showViewToShareNews:@"发新闻拉"
                                  Content:@"发布一条新微博！喵～by KSharedSDK."
                                    Image:[UIImage imageNamed:@"kSharedSDK"]
                                      Url:@"http://baidu.com"
                                 platform:platform
                         inViewController:self];
}
@end
