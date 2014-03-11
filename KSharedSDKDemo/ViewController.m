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

#define KSharedSDK_MediaTitle   @"标题"
#define KSharedSDK_MediaText    @"我是一条测试数据，由KSharedSDK提供!"
#define KSharedSDK_MediaURL     @"http://www.163.com"
#define KSharedSDK_MediaImage   [UIImage imageNamed:@"kSharedSDK"]

@interface ViewController () <UIActionSheetDelegate>

@end

@implementation ViewController

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

- (IBAction)showSharedView:(id)sender
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
