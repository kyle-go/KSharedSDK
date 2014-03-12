//
//  KAlertView.h
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSharedSDK.h"

@protocol KWeiboOauthViewDelegate <NSObject>

- (void)weiboOauthCallback:(NSDictionary *)userInfo;

@end

@interface KWeiboOauthView : NSObject

@property (weak, nonatomic) id<KWeiboOauthViewDelegate> delegate;

+ (instancetype)Instance;

- (void)show:(SharedType)type;

- (void)showInNewWindow:(SharedType)type;

@end
