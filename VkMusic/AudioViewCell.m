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

-(void)setState:(AudioState)state {
    NSString *img = state == AUDIO_SAVED ? @"success_gray": @"download";
    UIImageView *success = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img]];
    self.accessoryView = success;
}




@end
