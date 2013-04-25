//
//  AudioPlayerViewDelegate.h
//  VkMusic
//
//  Created by keepcoder on 24.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioPlayerViewDelegate <NSObject>
-(void)playerDidPlayOrPause;
-(void)playeDidStop;
-(void)needPrevToPlay;
-(void)needAudioToPlay;
@end
