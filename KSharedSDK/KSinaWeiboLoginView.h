//
//  KAlertView.h
//  TestSinaLogin
//
//  Created by kyle on 13-12-10.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSinaWeiboLoginDelegate <NSObject>

- (void)sinaWeiboLoginCallback:(NSDictionary *)userInfo;

@end

@interface KSinaWeiboLoginView : NSObject

@property (weak, nonatomic) id<KSinaWeiboLoginDelegate> delegate;

- (void)show;

@end
