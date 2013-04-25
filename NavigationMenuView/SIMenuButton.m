//
//  SAMenuButton.m
//  NavigationMenu
//
//  Created by Ivan Sapozhnik on 2/19/13.
//  Copyright (c) 2013 Ivan Sapozhnik. All rights reserved.
//

#import "SIMenuButton.h"
#import "SIMenuConfiguration.h"
#import "Consts.h"
@implementation SIMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([self defaultGradient]) {
            
        } else {
            [self setSpotlightCenter:CGPointMake(frame.size.width/2, frame.size.height*(-1)+10)];
            [self setBackgroundColor:[UIColor clearColor]];
            [self setSpotlightStartRadius:0];
            [self setSpotlightEndRadius:frame.size.width/2];
        }
        
        frame.origin.y -= 2.0;
        self.title = [[UILabel alloc] initWithFrame:frame];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont fontWithName:FONT_BOLD size:17];
        //self.title.shadowColor = [UIColor darkGrayColor];
        //self.title.shadowOffset = CGSizeMake(0, -1);
        self.title.lineBreakMode= NSLineBreakByTruncatingTail;
        [self addSubview:self.title];

        self.arrow = [[UIImageView alloc] initWithImage:[SIMenuConfiguration arrowImage]];
        [self addSubview:self.arrow];
    }
    return self;
}

- (UIImageView *)defaultGradient
{
    return nil;
}

- (void)layoutSubviews
{
    CGSize textSize = [[self.title text] sizeWithFont:[self.title font]];
    self.title.frame = CGRectMake(self.title.frame.origin.x, self.title.frame.origin.y, textSize.width > 150 ? 150 : textSize.width, self.title.frame.size.height);
    self.title.center = CGPointMake(self.frame.size.width/2, (self.frame.size.height-2.0)/2);
    self.arrow.center = CGPointMake(CGRectGetMaxX(self.title.frame) + [SIMenuConfiguration arrowPadding], self.frame.size.height / 2 +1);
}

#pragma mark -
#pragma mark Handle taps
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.isActive = !self.isActive;
    CGGradientRef defaultGradientRef = [[self class] newSpotlightGradient];
    [self setSpotlightGradientRef:defaultGradientRef];
    CGGradientRelease(defaultGradientRef);
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.spotlightGradientRef = nil;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.spotlightGradientRef = nil;
}

#pragma mark - Drawing Override
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGGradientRef gradient = self.spotlightGradientRef;
    float radius = self.spotlightEndRadius;
    float startRadius = self.spotlightStartRadius;
    CGContextDrawRadialGradient (context, gradient, self.spotlightCenter, startRadius, self.spotlightCenter, radius, kCGGradientDrawsAfterEndLocation);
}


#pragma mark - Factory Method

+ (CGGradientRef)newSpotlightGradient
{
    size_t locationsCount = 2;
    CGFloat locations[2] = {1.0f, 0.0f,};
    CGFloat colors[12] = {0.0f,0.0f,0.0f,0.0f,
        0.0f,0.0f,0.0f,0.55f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    return gradient;
}

- (void)setSpotlightGradientRef:(CGGradientRef)newSpotlightGradientRef
{
    CGGradientRelease(_spotlightGradientRef);
    _spotlightGradientRef = nil;
    
    _spotlightGradientRef = newSpotlightGradientRef;
    CGGradientRetain(_spotlightGradientRef);
    
    [self setNeedsDisplay];
}

#pragma mark - Deallocation

- (void)dealloc
{
    [self setSpotlightGradientRef:nil];
}

@end
