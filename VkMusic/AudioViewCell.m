//
//  AudioViewCell.m
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AudioViewCell.h"
#import "SIMenuConfiguration.h"
#import "SICellSelection.h"
#import "QuartzCore/QuartzCore.h"
#import "Consts.h"
#import "UIImage+Extension.h"
@implementation AudioViewCell
@synthesize accessoryTarget;
@synthesize accessorySelector;
@synthesize audio = _audio;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
        bg.backgroundColor =  [UIColor whiteColor]; //[UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
        self.backgroundView = bg;
        self.backgroundColor = [UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[SIMenuConfiguration selectionColor]]];
        self.textLabel.font = [UIFont fontWithName:FONT_BOLD size:18];
        self.textLabel.textColor = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha:1];
        self.detailTextLabel.font = [UIFont fontWithName:FONT_BOLD size:13];
        self.detailTextLabel.textColor = [UIColor colorWithRed:0.552 green:0.552 blue:0.552 alpha:1];
                
    }
    return self;
}

-(void)addAccessoryTarget:(id)target selector:(SEL)selector {
    self.accessoryTarget = target;
    self.accessorySelector = selector;
}


-(void)showDeleteButton:(UIButton *)button onAnimationComplete:(void (^)())handler {
    self.accessoryView = button;
    [UIView animateWithDuration:0.3 animations:^{
        button.alpha = 1.0;
    } completion:^(BOOL finished) {
        handler();
    }];

}
-(void)hideDeleteButton:(UIButton *)button onAnimationComplete:(void (^)())handler {
    [UIView animateWithDuration:0.3 animations:^{
        button.alpha = 0.0;
    } completion:^(BOOL finished) {
         [self setState:_audio];
         handler();
    }];
   
}



-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

-(void)setState:(Audio *)audio {
    NSString *icon;
    NSString *highlight;
    _audio = audio;
    AudioState state = audio.state;
    switch (state) {
        case AUDIO_DEFAULT:
            icon = @"download";
            highlight = icon;
            break;
        case AUDIO_IN_SAVE_QUEUE:
            icon = @"queued";
            highlight = @"queue_highlight";
            break;
        case AUDIO_SAVED:
            icon = @"success";
            highlight = @"success_highlight";
            break;
        case AUDIO_IN_PROGRESS_SAVE:
            icon = @"queued";
            highlight = @"queue_highlight";
            break;
        default:
            icon = nil;
            break;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed: icon];
    UIImage *hlImage = [UIImage imageNamed:highlight];
    btn.bounds = CGRectMake( image.size.width, 0, image.size.width*2, image.size.height*2 );
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:hlImage forState:UIControlStateHighlighted];
    btn.userInteractionEnabled = state == AUDIO_DEFAULT ? YES : NO;
    [btn addTarget:accessoryTarget action:accessorySelector forControlEvents:UIControlEventTouchUpInside];
    self.accessoryView = btn;
}




@end
