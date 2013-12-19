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

#define KSharedSDK_MediaTitle   @"我是KSharedSDK标题"
#define KSharedSDK_MediaText    @"我是一条测试数据，由KSharedSDK提供!"
#define KSharedSDK_MediaURL     @"http://www.163.com"
#define KSharedSDK_MediaImage   [UIImage imageNamed:@"kSharedSDK"]

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
    _sharedType = SharedType_TencentWeibo;
    [self showActionSheet];
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
    BOOL result = NO;
    switch (buttonIndex) {
            //文本
        case 0:
            result = [[KSharedSDK Instance] shareText:KSharedSDK_MediaText type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareText failed. Error = %@", e);
                } else {
                    NSLog(@"shareText sinaWeibo succeed.");
                }
            }];
            break;
            //图片
        case 1:
            result = [[KSharedSDK Instance] shareImage:KSharedSDK_MediaImage type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareImage failed. Error = %@", e);
                } else {
                    NSLog(@"shareImage succeed.");
                }
            }];
            break;
            //新闻
        case 2:
            result = [[KSharedSDK Instance] shareNews:KSharedSDK_MediaTitle Content:KSharedSDK_MediaText Image:KSharedSDK_MediaImage url:KSharedSDK_MediaURL type:_sharedType completion:^(NSError *e){
                if (e) {
                    NSLog(@"shareNews failed. Error = %@", e);
                } else {
                    NSLog(@"shareNews succeed.");
                }
            }];
            if (!result) {
                if (_sharedType == SharedType_SinaWeibo || _sharedType == SharedType_TencentWeibo) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"微博不支持新闻接口！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                    return;
                }
            }
            break;
            //取消
        case 3:
            result = YES;
            break;
        default:
            break;
    }
    
    if (!result) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"参数错误！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (IBAction)showShareMessageView:(id)sender
{
    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo, nil];
    
    [KShareViewManage showViewToShareText:KSharedSDK_MediaText
                                 platform:platform
                         inViewController:self];
}

- (IBAction)showShareImageView:(id)sender
{
    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo, nil];
    
    [KShareViewManage showViewToShareImge:KSharedSDK_MediaImage
                                 platform:platform
                         inViewController:self];
}

- (IBAction)showShareNewsView:(id)sender
{
    NSArray *platform = [KShareViewManage getShareListWithType:SharedType_SinaWeibo, SharedType_WeChatFriend, SharedType_WeChatCircel, SharedType_QQChat, SharedType_TencentWeibo, nil];
    
    [KShareViewManage showViewToShareNews:KSharedSDK_MediaTitle
                                  Content:KSharedSDK_MediaText
                                    Image:KSharedSDK_MediaImage
                                      Url:KSharedSDK_MediaURL
                                 platform:platform
                         inViewController:self];
}

@end
