//
//  HYActivityView.h
//  Test
//
//  Created by crte on 13-11-6.
//  Copyright (c) 2013年 crte. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ButtonView;
@class HYActivityView;

typedef void(^ButtonViewHandler)(ButtonView *buttonView);

@interface ButtonView : UIView

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, weak) HYActivityView *activityView;

- (id)initWithText:(NSString *)text image:(UIImage *)image handler:(ButtonViewHandler)handler;

@end

@interface HYActivityView : UIView

//背景颜色, 默认是透明度0.95的白色
@property (nonatomic, strong) UIColor *bgColor;

//标题
@property (nonatomic, strong) UILabel *titleLabel;

//取消按钮
@property (nonatomic, strong) UIButton *cancelButton;

//一行有多少个, 默认是4. iPhone竖屏不会多于4, 横屏不会多于6. ipad没试, 不建议ipad用这个.
@property (nonatomic, assign) int numberOfButtonPerLine;

//是否可以通过下滑手势关闭视图, 默认为YES
@property (nonatomic, assign) BOOL useGesturer;

//是否正在显示
@property (nonatomic, getter = isShowing) BOOL show;

//初始化
- (id)initWithTitle:(NSString *)title referView:(UIView *)referView;

//添加buttonView, HYActivityView会根据buttonView的数量自动变高, 但是没有对高度上限做过多处理，莫要丧心病狂的添加太多.
- (void)addButtonView:(ButtonView *)buttonView;

- (void)show;

- (void)hide;

@end
