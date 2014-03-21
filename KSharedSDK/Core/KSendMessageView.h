//
//  KSendMessageView.h
//  KSharedSDKDemo
//
//  Created by kyle on 14-3-11.
//  Copyright (c) 2014年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSharedMessage.h"

@protocol KSendMessageViewDelegate <NSObject>

- (void)sendWeiboMessage:(KSharedMessage *)m;

@end

@interface KSendMessageView : NSObject <UITextViewDelegate>

@property (weak, nonatomic) id<KSendMessageViewDelegate> delegate;

+ (instancetype)Instance;

- (void)setTitle:(NSString *)title;

- (void)setContent:(NSString *)content;

- (void)setImage:(UIImage *)image;

- (void)show;

- (void)showInNewWindow;

@end
