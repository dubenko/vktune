//
//  BaseViewList.m
//  VkMusic
//
//  Created by keepcoder on 08.05.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "BaseViewList.h"
#import "BaseViewCell.h"
#import "UIButton+Extension.h"
@implementation BaseViewList
@synthesize editingPath;
-(id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideDelete:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipe];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UISwipeGestureRecognizer *hideswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideDelete:)];
        hideswipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:hideswipe];
    }
    return self;
}

-(void)initDelete {
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed: @"delete"];
    self.deleteButton.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [self.deleteButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
    [self.deleteButton setImage:image forState:UIControlStateNormal];
    [self.deleteButton setImage:image forState:UIControlStateHighlighted];
    [self.deleteButton addTarget:self action:@selector(didDelete:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.userInteractionEnabled = YES;
    self.deleteButton.alpha = 0.0;
    self.deleteButton.center = CGPointMake(self.deleteButton.frame.size.width/2.0, self.deleteButton.frame.size.height/2.0);
}

-(void)didDelete:(UIButton *)sender forEvent:(UIEvent*)event {
    UIView *button = (UIView *)sender;
    UITouch *touch = [[event touchesForView:button] anyObject];
    CGPoint location = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    editingPath = nil;
    BaseViewCell *cell = (BaseViewCell *) [self cellForRowAtIndexPath:indexPath];
    [cell hideDeleteButton:self.deleteButton onAnimationComplete:^{
        self.deleteButton = nil;
    }];
    [self.dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
}


-(void)showDelete:(NSIndexPath *)path {
    if(!editingPath || path.row != editingPath.row) {
        [self initDelete];
        editingPath = path;
        BaseViewCell *cell = (BaseViewCell *) [self cellForRowAtIndexPath:editingPath];
        [cell showDeleteButton:self.deleteButton onAnimationComplete:^{
            
        }];
    }
}

-(BOOL)needShowDeleteForIndexPath:(NSIndexPath *)path {
    return YES;
}

-(void)showOrHideDelete:(UISwipeGestureRecognizer *)swipe {
    __block NSIndexPath *path = [self indexPathForRowAtPoint:[swipe locationInView:self]];
    if([self needShowDeleteForIndexPath:path]) {
        if(editingPath) {
            NSIndexPath *copy = editingPath;
            editingPath = nil;
            BaseViewCell *cell = (BaseViewCell *) [self cellForRowAtIndexPath:copy];
            
            [cell hideDeleteButton:self.deleteButton onAnimationComplete:^{
                 self.deleteButton = nil;
                if(copy.row != path.row) {
                    [self showDelete:path];
                }
                
            }];
            return;
        }
        [self showDelete:path];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
