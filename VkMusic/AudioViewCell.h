//
//  AudioViewCell.h
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
@interface AudioViewCell : UITableViewCell
@property (nonatomic,assign) id accessoryTarget;
@property (nonatomic,assign) SEL accessorySelector;

-(void)addAccessoryTarget:(id)target selector:(SEL)selector;
-(void)setState:(AudioState)state;
@end
