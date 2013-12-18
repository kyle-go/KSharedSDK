//
//  UIImage+Compress.h
//  heyiweixindemo
//
//  Created by 余成海 on 13-11-28.
//  Copyright (c) 2013年 余成海. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compress)

//按宽度比例压缩图片
- (UIImage *) compressImageToSize:(float)sizewidth;
//压缩图像
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize sourceImage:(UIImage *)sourceImage;

@end
