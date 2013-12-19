//
//  EditBlogViewController.h
//  KSharedSDKDemo
//
//  Created by 余成海 on 13-12-19.
//  Copyright (c) 2013年 kyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSharedSDK.h"

@interface EditBlogViewController : UIViewController

- (void)showWithSendText:(NSString* )text type:(SharedType)type;

@end
