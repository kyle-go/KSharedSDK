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

- (id)initWithSendText:(NSString *)text type:(SharedType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        sharedType = type;
        if (type == SharedType_SinaWeibo) {
            self.title = @"分享到新浪微博";
        }
        sendType = Send_Type_Text;
        content = text;
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
            } else {
                 NSLog(@"shareText scucess");
            }
        }];
    }
    [self cancel];
}

@end
