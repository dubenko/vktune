//
//  AudioViewCell.h
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
@interface BaseViewCell : UITableViewCell
@property (nonatomic,assign) id accessoryTarget;
@property (nonatomic,assign) SEL accessorySelector;
@property (nonatomic,strong) Audio *audio;
-(void)showDeleteButton:(UIButton *)button onAnimationComplete:(void (^)())handler;
-(void)hideDeleteButton:(UIButton *)button onAnimationComplete:(void (^)())handler;
-(void)addAccessoryTarget:(id)target selector:(SEL)selector;
-(void)setState:(Audio *)audio;
@end
