//
//  KAlertView.h
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSinaWeiboOauthDelegate <NSObject>

- (void)sinaWeiboOauthCallback:(NSDictionary *)userInfo;

@end

@interface KSinaWeiboOauthView : NSObject

@property (weak, nonatomic) id<KSinaWeiboOauthDelegate> delegate;

- (void)show;

@end
