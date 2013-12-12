//
//  KAlertView.m
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "KSinaWeiboOauthView.h"
#import "KSharedSDKDefine.h"
#import "KUnits.h"
#import "KHttpManager.h"

#define webViewTag                  9527
#define activityIndicatorViewTag    9528

@interface KSinaWeiboOauthView() <UIWebViewDelegate>

@end

@implementation KSinaWeiboOauthView {
    UIWindow *keyWindow;
    UIView *view;
}

+ (instancetype)KSinaWeiboOauthViewInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void)show
{
    keyWindow = [UIApplication sharedApplication].keyWindow;
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0) {
        keyWindow = [windows lastObject];
    }
    
    CGRect screenBounds = [KUnits XYScreenBounds];
    view = [[UIView alloc] initWithFrame:screenBounds];
    view.backgroundColor = [UIColor lightGrayColor];
    
    //网页视图
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
    webView.tag = webViewTag;
    webView.delegate = self;
    webView.scalesPageToFit = NO;
    [view addSubview:webView];
    
    //指示器
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame : CGRectMake(0.0f, 0.0f, 88.0f, 88.0f)];
    indicatorView.tag = activityIndicatorViewTag;
    [indicatorView setCenter: CGPointMake(view.center.x, view.center.y - 70)];
    [indicatorView setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView startAnimating];
    [view addSubview:indicatorView];
    
    //加载视图
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"登录新浪微博";
    viewController.view = view;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(webViewLoadRequest)];
    
    //发起请求
    [self webViewLoadRequest];
    
    [keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)dismiss
{
    [keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewLoadRequest
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            kSinaWeiboAppKey,                @"client_id",       //申请的appkey
                            kSinaWeiboRedirectURI,           @"redirect_uri",    //申请时的重定向地址
                            @"mobile",                       @"display",         //web页面的显示方式
                            @"all",                          @"scope",
                            @"true",                         @"forcelogin",
                            nil];
    NSURL *url = [KUnits generateURL:@"https://open.weibo.cn/oauth2/authorize" params:params];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    UIWebView * webView= (UIWebView *)[view viewWithTag:webViewTag];
    [view viewWithTag:activityIndicatorViewTag].hidden = NO;
    [view viewWithTag:activityIndicatorViewTag].alpha = 1.0;
    webView.hidden = YES;
    webView.alpha = 0.0;
    [webView loadRequest:request];
}

#pragma mark --- UIWebViewDelegate -----------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSString *searchString = [[NSString alloc] initWithFormat:@"%@?code=", kSinaWeiboRedirectURI];
    NSRange range = [url rangeOfString:searchString];
    if (range.location == NSNotFound) {
        return YES;
    }
    
    NSString *code = [url substringFromIndex:range.location + range.length];
    [self getAccessTokenByCode:code];
    [self dismiss];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIView animateWithDuration:0.8
                     animations:^{
                         [view viewWithTag:activityIndicatorViewTag].hidden = YES;
                         [view viewWithTag:activityIndicatorViewTag].alpha = 0.0;
                         
                         webView.hidden = NO;
                         webView.alpha = 1.0;
                     }
                     completion:nil];
    
    //disable selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请检查网络" message:@"打开网页失败,请检查网络!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

#pragma --- network ------------------------
- (void) getAccessTokenByCode:(NSString *)code
{
    void (^success_callback) (id responseObject) =
    ^(id responseObject) {
        
        NSError *error;
        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSNumber *expire = [json objectForKey:@"expires_in"];
        
        //已经过期则重新认证
        if ([expire intValue] <= 0) {
            if (self.delegate) {
                [self.delegate sinaWeiboOauthCallback:@{@"error": @"token已过期!"}];
            }
            return;
        }
        
        NSString *accessToken = [json objectForKey:@"access_token"];
        NSString *uid = [json objectForKey:@"uid"];
        NSDictionary *params = @{@"access_token":accessToken, @"uid":uid};
        if (self.delegate) {
            [self.delegate sinaWeiboOauthCallback:params];
        }
    };
    
    void (^failure_callback)(NSError *error) =
    ^(NSError *error){
        NSString *errorString = [NSString stringWithFormat:@"%@", error];
        if (self.delegate) {
            [self.delegate sinaWeiboOauthCallback:@{@"error": errorString}];
        }
    };
    
    //判断token是否过期POST请求
    KHttpManager *manager = [KHttpManager manager];
    NSDictionary *params = @{@"client_id":kSinaWeiboAppKey, @"client_secret":kSinaWeiboAppSecret, @"grant_type":@"authorization_code", @"code":code, @"redirect_uri":kSinaWeiboRedirectURI};
    [manager POST:@"https://api.weibo.com/oauth2/access_token" parameters:params success:success_callback failure:failure_callback content_type:nil];
}

@end

