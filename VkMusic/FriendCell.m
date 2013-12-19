//
//  FriendCell.m
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "FriendCell.h"
#import "SIMenuConfiguration.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Extension.h"
@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont boldSystemFontOfSize:15];
        self.textLabel.textColor = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha:1];
         [self.imageView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corners"]]];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[SIMenuConfiguration selectionColor]]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(5.0f, 5.0f, 50.0f, 50.0f);
    self.textLabel.frame = CGRectMake(70.0f, (60.0-20.0)/2, 240.0f, 20);
    
    CGRect detailTextLabelFrame = CGRectOffset(self.textLabel.frame, 0.0f, 25.0f);
    self.detailTextLabel.frame = detailTextLabelFrame;
}

-(void)setFriend:(Friend *)friend {
    self.textLabel.text = [NSString stringWithFormat:@"%@ %@",friend.first_name, friend.last_name];
    [self.imageView setImageWithURL:[NSURL URLWithString:friend.photo] placeholderImage:[UIImage imageNamed:@"camera_b"]];
   
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
