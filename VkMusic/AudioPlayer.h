//
//  AudioPlayer.h
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "AudioPlayerDelegate.h"
#import "Audio.h"
#import "SaveQueue.h"
@interface AudioPlayer : NSObject<AVAudioPlayerDelegate>
@property(nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) Audio *audio;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic) dispatch_queue_t dispatchQueue;
@property (nonatomic) BOOL needPlayAfterInterrupted;
-(void)playWithUrl:(NSURL *)url audio:(Audio*)audio;
-(void)stop;
-(void)play;
-(void)pause;
-(BOOL)isPlay;
-(void)seekTo:(float)currentTime;
@property (nonatomic, strong) id<AudioPlayerDelegate> delegate;
@end
