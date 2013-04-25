//
//  PlayView.h
//  VkMusic
//
//  Created by keepcoder on 17.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ImageElement : UIView
@property (nonatomic,strong) UIImageView *currentImage;
@property (nonatomic) id target;
@property (nonatomic) SEL selector;
- (id)initWithFrame:(CGRect)frame leftOrRight:(NSInteger)border image:(NSString *)image;
-(void)replaceImage:(UIImage *)image;
-(void)setBorderColor:(UIColor *)color;
-(void)addTarget:(id)target selector:(SEL)selector;
@end
