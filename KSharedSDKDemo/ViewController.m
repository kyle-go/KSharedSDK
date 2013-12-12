//
//  ViewController.m
//  KSharedSDKDemo
//
//  Created by kyle on 13-12-9.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "ViewController.h"
#import "KSharedSDK.h"

@interface ViewController ()

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

- (IBAction)sendSinaWeibo:(id)sender {
    [[KSharedSDK Instance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_SinaWeibo completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage sinaWeibo failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage sinaWeibo succeed.");
        }
    }];
}

- (IBAction)sendTencentWeibo:(id)sender {
    [[KSharedSDK Instance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_TencentWeibo completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage tencentWeibo failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage tecentWeibo succeed.");
        }
    }];
}

- (IBAction)sendWeixinFriend:(id)sender {
    [[KSharedSDK Instance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_WeChatFriend completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage weChatFriend failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage weChatFriend succeed.");
        }
    }];
}

- (IBAction)sendWeixinCircel:(id)sender {
    [[KSharedSDK Instance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_WeChatCircel completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage weChatCircel failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage weChatCircel succeed.");
        }
    }];
}

- (IBAction)sendQQFriend:(id)sender {
}

- (IBAction)sendQQZone:(id)sender {
}
@end
