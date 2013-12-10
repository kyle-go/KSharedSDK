//
//  KAlertView.m
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSinaWeiboLoginView.h"
#import "KSharedSDKDefine.h"
#import "KUnits.h"

@interface KSinaWeiboLoginView() <UIWebViewDelegate>

@end

@implementation KSinaWeiboLoginView {
    UIWindow    *keyWindow;
    UIView      *bgView;
    UIWebView   *webView;
    UIButton    *dismissButton;
}

+ (instancetype)kSinaWeiboLoginViewInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
        NSArray *windows = [UIApplication sharedApplication].windows;
        if(windows.count > 0) {
            keyWindow = [windows lastObject];
        }
        
        //背景图片
        CGRect screenBounds = [KUnits XYScreenBounds];
        bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.opaque = YES;
        bgView.alpha = 0.4f;
        
        //网页视图
        webView = [[UIWebView alloc] initWithFrame:screenBounds];
        webView.delegate = self;
        webView.scalesPageToFit = NO;
        //webView.userInteractionEnabled = NO;
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                kSinaWeiboAppKey,                @"client_id",       //申请的appkey
                                kSinaWeiboRedirectURI,           @"redirect_uri",    //申请时的重定向地址
                                @"mobile",                       @"display",         //web页面的显示方式
                                @"all",                          @"scope",
                                @"true",                         @"forcelogin",
                                nil];
        
        NSURL *url = [KUnits generateURL:@"https://open.weibo.cn/oauth2/authorize" params:params];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [webView loadRequest:request];
        
        //退出按钮
        dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [dismissButton setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setupViews
{
    [keyWindow addSubview:bgView];
    [keyWindow addSubview:webView];
    //[keyWindow addSubview:dismissButton];
}

+ (void)show
{
    KSinaWeiboLoginView *view = [KSinaWeiboLoginView kSinaWeiboLoginViewInstance];
    [view setupViews];
}

- (void)dismiss
{
    
}

#pragma mark --- UIWebViewDelegate -----------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"url = %@", requestString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView2
{
    NSString *jsCode = @"var newDiv=document.createElement(\"div\");"
    "newDiv.id=\"newDiv\";"
    "newDiv.style.position=\"absolute\";"
    "newDiv.style.width=\"320px\";"
    "newDiv.style.height=\"568px\";"
    "var e = document.createElement(\"input\");"
    "e.type = \"button\";"
    "e.value = \"取消登录\";"
    "e.style.width=\"260px\";"
    "e.style.height=\"40px\";"
    "e.style.marginLeft=\"30px\";"
    "e.onClick = function(){alert('ddd');};" //window.open('http://kylescript.cancel');
    "var object = newDiv.appendChild(e);"
    "document.body.appendChild(object);";

    [webView2 stringByEvaluatingJavaScriptFromString:jsCode];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end

