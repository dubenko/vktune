//
//  AudioPlayer.m
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AudioPlayer.h"
#import "CachedAudioLogic.h"
#import "AudioLogic.h"
#import "MediaPlayer/MediaPlayer.h"
#import "AudioToolbox/AudioServices.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


#define kAudioEndInterruption   @"AudioEndInterruptionNotification"
#define kAudioBeginInterruption @"AudioBeginInterruptionNotification"

void AudioInterruptionListener (
                                void *inClientData,
                                UInt32 inInterruptionState
                                )
{
    NSString *notificationName = nil;
    switch (inInterruptionState) {
        case kAudioSessionEndInterruption:
            notificationName = kAudioEndInterruption;
            break;
            
        case kAudioSessionBeginInterruption:
            notificationName = kAudioBeginInterruption;
            break;
            
        default:
            break;
    }
    
    if (notificationName) {
        NSNotification *notice = [NSNotification notificationWithName:notificationName object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notice];
    }
}

@implementation AudioPlayer
@synthesize player;
@synthesize delegate;
@synthesize timer;
@synthesize audio;
@synthesize dispatchQueue;
@synthesize needPlayAfterInterrupted;

-(id)init {
    if(self = [super init]) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(endAudioInterruption:)
                                                     name:kAudioEndInterruption object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(beginAudioInterruption:)
                                                     name:kAudioBeginInterruption object:nil];
        
        dispatchQueue = dispatch_queue_create("ru.keepcoder.PlayerQueue", 0); 
        AudioSessionInitialize(NULL, NULL, AudioInterruptionListener, NULL);
        player = [[AVPlayer alloc] init];
        needPlayAfterInterrupted = NO;
    }
     

    return self;
}

-(void)beginAudioInterruption:(id)context
{
    NSLog(@"pause");
    if([self isPlay]) {
        needPlayAfterInterrupted = YES;
    }
    [self pauseFromExternal];
}

-(void)endAudioInterruption:(id)context
{
     NSLog(@"play");
    if(needPlayAfterInterrupted) {
        [self play];
    }
}



-(void)currentTime:(NSTimer *)sender {
    if([delegate respondsToSelector:@selector(didUpdateCurrentTime:duration:)]) {
        double d = CMTimeGetSeconds([[player currentItem] duration]);
        double c = CMTimeGetSeconds([player currentTime]);
        if(!isnan(d) && !isnan(c)) {
            NSNumber *duration = [NSNumber numberWithDouble:d];
            NSNumber *currentTime = [NSNumber numberWithDouble:c];
            [delegate performSelector:@selector(didUpdateCurrentTime:duration:) withObject:currentTime withObject:duration];
        }
      
    }
}




-(void) playWithUrl:(NSURL *)url audio:(Audio *)_audio {
    [self clear];
    self.audio = _audio;
    dispatch_async(dispatchQueue, ^{
        [[AudioLogic instance] setBroadcast:audio];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        NSArray *keys = [NSArray arrayWithObject:@"playable"];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                [player replaceCurrentItemWithPlayerItem:item];
                [self updateRemotePlaying];
                [self play]; 
            });
            
        }];;
    });
}

-(void)clear {
    [timer invalidate];
    timer = nil;
}


-(void)updateRemotePlaying {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        NSDictionary *songInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  audio.artist, MPMediaItemPropertyArtist,
                                  audio.title, MPMediaItemPropertyTitle,
                                  audio.duration,MPMediaItemPropertyPlaybackDuration,
                                  nil];
        center.nowPlayingInfo = songInfo;
    }
}


-(void)seekTo:(float)currentTime {
    [player seekToTime:CMTimeMakeWithSeconds(currentTime,1)];
}

-(void)pauseFromExternal {
    [player pause];
    [timer invalidate];
    timer = nil;
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:NO]];
    }
}


-(void)pause {
    needPlayAfterInterrupted = NO;
    [player pause];
    [timer invalidate];
    timer = nil;
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:NO]];
    }
}

-(void)play {
    [player play];
    [timer invalidate];
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(currentTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:YES]];
    }
        
   
}
-(BOOL)isPlay {
    return [player rate];
}

-(void)stop {
    [player replaceCurrentItemWithPlayerItem:nil];
     audio = nil;
    [self clear];
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:NO]];
    }
}

-(void)itemDidFinishPlaying {
     [timer invalidate];
     timer = nil;
    if([delegate respondsToSelector:@selector(needAudioToPlay:)]) {
        [delegate performSelector:@selector(needAudioToPlay:) withObject:[NSNumber numberWithBool:NO]];
     }
}


@end


