//
//  KSendMessageView.m
//  KSharedSDKDemo
//
//  Created by kyle on 14-3-11.
//  Copyright (c) 2014年 kyle. All rights reserved.
//

#import "KSendMessageView.h"
#import "KHelper.h"

@implementation KSendMessageView {
    UIWindow *keyWindow;
    UIView *mainView;
    UIView *barView;
    UITextView *textView;
}

+ (instancetype)Instance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void)show
{
    keyWindow = [[UIApplication sharedApplication].windows firstObject];
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    CGRect screenBounds = [KHelper XYScreenBounds];
    mainView = [[UIView alloc] initWithFrame:screenBounds];
    mainView.backgroundColor = [UIColor lightGrayColor];
    
    //textView
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, [KHelper XYScreenBounds].size.height)];
    [textView becomeFirstResponder];
    [mainView addSubview:textView];
    
    //barView
    barView = [[UIView alloc] initWithFrame:CGRectMake(0, [KHelper XYScreenBounds].size.height - 48, 320, 48)];
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, barView.frame.size.width, barView.frame.size.height)];
    bgImgView.image = [UIImage imageNamed:@"bar"];
    [barView addSubview:bgImgView];
    [barView sendSubviewToBack:bgImgView];
    [mainView addSubview:barView];
    
    //加载视图
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.title = @"分享到xxx";

    viewController.view = mainView;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(send)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UIViewController *lastController;
    for (UIViewController *controller = keyWindow.rootViewController; controller; controller = controller.presentedViewController) {
        lastController = controller;
    }
    [lastController presentViewController:nav animated:YES completion:nil];
}


#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    
    barView.hidden = NO;
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.origin.y withDuration:animationDuration];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:[KHelper XYScreenBounds].size.height withDuration:animationDuration];
}

#pragma mark -
#pragma mark moveInputBarWithKeyboardHeight
- (void) moveInputBarWithKeyboardHeight:(CGFloat)posY withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CGRect frame = barView.frame;
                         frame.origin.y = posY - 44;
                         barView.frame = frame;
                         
                         textView.frame = CGRectMake(0, 0, 320, posY - 48 + 5);
                     }];
}


- (void)dismiss
{
    [keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)send
{
    
}

@end
