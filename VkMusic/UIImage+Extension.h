//
//  UIImage+Extension.h
//  VkMusic
//
//  Created by keepcoder on 17.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect;
- (UIImage *)scaleAndRotateImage;
- (UIImage *)rotate:(float)rads;
@end
