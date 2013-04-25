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
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation AudioPlayer
@synthesize player;
@synthesize delegate;
@synthesize timer;
@synthesize audio;
@synthesize queue;
@synthesize dispatchQueue;
-(id)init {
    if(self = [super init]) {

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        dispatchQueue = dispatch_queue_create("ru.keepcoder.PlayerQueue", 0);
        queue = [SaveQueue instance];
    }
     

    return self;
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
    [self stop];
    self.audio = _audio;
    dispatch_async(dispatchQueue, ^{
        if(![[CachedAudioLogic instance] findCached:audio]) {
            [queue addAudioToQueue:audio asset:[[AVURLAsset alloc] initWithURL:url options:nil]];
        }
        
        [[AudioLogic instance] setBroadcast:audio];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        NSArray *keys = [NSArray arrayWithObject:@"playable"];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                player = [AVPlayer playerWithPlayerItem:item];
                [self updateRemotePlaying];
                [self play];
                
            });
            
        }];;
    });
    
}


-(void)updateRemotePlaying {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
        NSDictionary *songInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  audio.artist, MPMediaItemPropertyArtist,
                                  audio.title, MPMediaItemPropertyTitle,
                                  nil];
        center.nowPlayingInfo = songInfo;
    }
}


-(void)seekTo:(float)currentTime {
    [player seekToTime:CMTimeMakeWithSeconds(currentTime*CMTimeGetSeconds([[player currentItem]duration])-1,1)];
}




-(void)pause {
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    [player pause];
    [timer invalidate];
    timer = nil;
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:NO]];
    }
}

-(void)play {
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
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
    [[AVAudioSession sharedInstance] setActive:NO error:NULL];
    [player replaceCurrentItemWithPlayerItem:nil];
    player = nil;
    audio = nil;
    [timer invalidate];
    timer = nil;
    if([delegate respondsToSelector:@selector(playerDidPauseOrPlay:)]) {
        [delegate performSelector:@selector(playerDidPauseOrPlay:) withObject:[NSNumber numberWithBool:NO]];
    }
}

-(void)itemDidFinishPlaying {
     [timer invalidate];
     timer = nil;
    if([delegate respondsToSelector:@selector(needAudioToPlay)]) {
        [delegate performSelector:@selector(needAudioToPlay) withObject:player];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    
    if ([keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [self play];
        } else if (player.status == AVPlayerStatusFailed) {
            NSLog(@"error!11!");
        }
    } 
}


@end
