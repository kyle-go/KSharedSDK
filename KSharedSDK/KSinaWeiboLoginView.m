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
    UILabel     *loading;
    UIActivityIndicatorView *indicatorView;
}

+ (instancetype)kSinaWeiboLoginViewInstance
{
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void)setupViews
{
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
    bgView.alpha = 0.8f;
    
    //加载中...
    loading = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, screenBounds.size.width, 60)];
    loading.backgroundColor = [UIColor clearColor];
    loading.textColor = [UIColor lightGrayColor];
    loading.text = @"玩命加载中...";
    loading.font = [UIFont systemFontOfSize:28];
    loading.textAlignment = NSTextAlignmentCenter;
    
    //指示器
    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame : CGRectMake(0.0f, 0.0f, 88.0f, 88.0f)] ;
    [indicatorView setCenter: CGPointMake(bgView.center.x, bgView.center.y - 70)];
    [indicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView startAnimating];
    
    //网页视图
    webView = [[UIWebView alloc] initWithFrame:screenBounds];
    webView.delegate = self;
    webView.scalesPageToFit = NO;
    webView.scrollView.scrollEnabled = NO;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            kSinaWeiboAppKey,                @"client_id",       //申请的appkey
                            kSinaWeiboRedirectURI,           @"redirect_uri",    //申请时的重定向地址
                            @"mobile",                       @"display",         //web页面的显示方式
                            @"all",                          @"scope",
                            @"true",                         @"forcelogin",
                            nil];
    
    NSURL *url = [KUnits generateURL:@"https://open.weibo.cn/oauth2/authorize" params:params];
    
    //退出按钮，暂时这样处理吧，以后这里用动画效果来处理一下
    dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 380, 200, 50)];
    [dismissButton setTitle:@"取消登陆" forState:UIControlStateNormal];
    [dismissButton setBackgroundColor:[UIColor colorWithRed:222.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:0.6]];
    [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    
    [keyWindow addSubview:bgView];
    [keyWindow addSubview:loading];
    [keyWindow addSubview:indicatorView];
    [keyWindow addSubview:dismissButton];
}

+ (void)show
{
    [[KSinaWeiboLoginView kSinaWeiboLoginViewInstance] setupViews];
}

- (void)dismiss
{
    [bgView removeFromSuperview];
    [loading removeFromSuperview];
    [indicatorView removeFromSuperview];
    [dismissButton removeFromSuperview];
    [webView removeFromSuperview];
}

#pragma mark --- UIWebViewDelegate -----------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"url = %@", requestString);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView2
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView2
{
    [loading removeFromSuperview];
    [indicatorView removeFromSuperview];
    [keyWindow insertSubview:webView aboveSubview:bgView];
    [dismissButton setBackgroundColor:[UIColor colorWithRed:222.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0]];
    
    //disable selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicatorView removeFromSuperview];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络" message:@"打开网页失败,请检查网络!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [self dismiss];
}

@end

