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
    [[KSharedSDK kSharedSDKInstance] sharedMessage:@"发布一条新微博！喵～by KSharedSDK." type:SharedType_SinaWeibo userInfo:nil];
}

- (IBAction)sendTencentWeibo:(id)sender {
}

- (IBAction)sendWeixinFriend:(id)sender {
}

- (IBAction)sendWeixinCircel:(id)sender {
}

- (IBAction)sendQQFriend:(id)sender {
}

- (IBAction)sendQQZone:(id)sender {
}
@end
