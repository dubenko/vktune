//
//  AudioPlayerDelegate.h
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioPlayerDelegate <NSObject>
-(void)didUpdateCurrentTime:(NSNumber *)currentTime duration:(NSNumber *)duration;
-(void)needAudioToPlay:(NSNumber *)physic;
-(void)playerDidPauseOrPlay:(NSNumber *)play;
@end
