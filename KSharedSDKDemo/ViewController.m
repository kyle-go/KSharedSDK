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
    [[KSharedSDK sharedSDKInstance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_SinaWeibo completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage succeed.");
        }
    }];
}

- (IBAction)sendTencentWeibo:(id)sender {
}

- (IBAction)sendWeixinFriend:(id)sender {
    [[KSharedSDK sharedSDKInstance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_WeChatFriend completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage weixin failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage weixin succeed.");
        }
    }];
}

- (IBAction)sendWeixinCircel:(id)sender {
    [[KSharedSDK sharedSDKInstance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_WeChatCircel completion:^(NSError *e){
        if (e) {
            NSLog(@"sharedMessage weixin failed. Error = %@", e);
        } else {
            NSLog(@"sharedMessage weixin succeed.");
        }
    }];
}

- (IBAction)sendQQFriend:(id)sender {
}

- (IBAction)sendQQZone:(id)sender {
}
@end
