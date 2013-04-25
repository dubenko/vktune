//
//  AudioViewCell.h
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTransformableTableViewCell.h"
#import "Audio.h"
@interface AudioViewCell : JTTransformableTableViewCell

-(void)setState:(AudioState)state;
@end
