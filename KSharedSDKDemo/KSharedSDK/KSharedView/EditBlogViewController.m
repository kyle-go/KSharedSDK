//
//  EditBlogViewController.m
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-19.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import "EditBlogViewController.h"

//定义分享类型
enum
{
    Send_Type_Text = 1,
    Send_Type_Image,
    Send_Type_News,
};
typedef NSUInteger SendType;

@interface EditBlogViewController ()

@end

@implementation EditBlogViewController
{
    SharedType sharedType;
    SendType sendType;
    NSString *content;
    UIWindow *keyWindow;
    UITextView *textView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(send)];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
    [textView setBackgroundColor:[UIColor clearColor]];
    textView.text = content;
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithSendText:(NSString *)text type:(SharedType)type
{
    sharedType = type;
    sendType = Send_Type_Text;
    content = text;
    [self show];
}

- (void)show
{
    keyWindow = [UIApplication sharedApplication].keyWindow;
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0) {
        keyWindow = [windows lastObject];
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    [keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)send
{
    if (sendType == Send_Type_Text) {
        [[KSharedSDK Instance] shareText:textView.text type:SharedType_SinaWeibo completion:^(NSError *e){
            if (e) {
                NSLog(@"shareText failed. Error = %@", e);
                [self cancel];
            } else {
                NSLog(@"shareText sinaWeibo succeed.");
                [self cancel];
            }
        }];
    }

}

@end
