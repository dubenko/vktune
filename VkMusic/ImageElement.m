//
//  PlayView.m
//  VkMusic
//
//  Created by keepcoder on 17.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ImageElement.h"
@interface ImageElement ()
@property (nonatomic,strong) UIView *border;
@end
@implementation ImageElement
@synthesize currentImage;
@synthesize border;
@synthesize target;
@synthesize selector;
- (id)initWithFrame:(CGRect)frame leftOrRight:(NSInteger)_border image:(NSString *)image {
    self = [super initWithFrame:frame];
    if (self) {
        border = [[UIView alloc] initWithFrame:CGRectMake(_border == 0 ? 0 : frame.size.width-1, 0, 1, frame.size.height)];
        border.backgroundColor = [UIColor colorWithRed:0.180 green:0.180 blue:0.180 alpha:1];
        [self replaceImage:[UIImage imageNamed:image]];
        [self addSubview:border];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
       
    }
    return self;
}

-(void)handleSingleTap:(UISwipeGestureRecognizer *)touch {
    if(touch.state == UIGestureRecognizerStateEnded) {
        if(target && selector) {
            [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)replaceImage:(UIImage*)image {
    [currentImage removeFromSuperview];
    currentImage = [[UIImageView alloc] initWithImage:image];
    currentImage.frame = CGRectMake((self.frame.size.width-currentImage.frame.size.width)/2, (self.frame.size.height-currentImage.frame.size.height)/2, currentImage.frame.size.width, currentImage.frame.size.height);
    [self addSubview:currentImage];
}

-(void)setBorderColor:(UIColor *)color {
    border.backgroundColor = color;
}

-(void)addTarget:(id)_target selector:(SEL)_selector {
    self.target = _target;
    self.selector = _selector;
}



@end
