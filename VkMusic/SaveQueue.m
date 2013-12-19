//
//  SaveQueue.m
//  VkMusic
//
//  Created by keepcoder on 30.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SaveQueue.h"
#import "CachedAudioLogic.h"
#import "AudioPlayer.h"
#import "AudioLogic.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SIMenuConfiguration.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation SaveQueue
@synthesize queue;
@synthesize status;
@synthesize requestQueue;
@synthesize largeProgressView;
@synthesize currentData;
@synthesize dataLength;

-(void)addAudioToQueue:(Audio *)audio {
    if(![[UserLogic instance] onlyWifi] || [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if(![self isset:audio]) {
                [[AppDelegate currentLogic] updateAudioState:audio state:AUDIO_IN_SAVE_QUEUE];
                [queue addObject:audio];
                NSLog(@"added %d, queue count %d",[audio.aid integerValue],queue.count);
                if(queue.count == 1) {
                    [self next];
                }
            }
        });
    }
}


-(void)next {
    Audio *current = [queue objectAtIndex:0];
    [[AudioLogic instance] loadUrlWithAudio:current target:self selector:@selector(save:)];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.currentData appendData:data];
    [largeProgressView setProgress:(((float)currentData.length)/((float)dataLength)) animated:YES];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse: (NSHTTPURLResponse*) response {
    if([response statusCode] == 200)
        dataLength = [response expectedContentLength];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
     Audio *current = [queue objectAtIndex:0];
    [[AppDelegate currentLogic] updateAudioState:current state:AUDIO_DEFAULT];
    [queue removeObjectAtIndex:0];
    if(queue.count > 0) {
        [self next];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
     Audio *current = [queue objectAtIndex:0];
    NSString *mp3 = [NSString stringWithFormat:@"%@/%d_%d.mp3", DOCUMENTS_FOLDER,[current.owner_id integerValue],[current.aid integerValue]];
    
    [[NSFileManager defaultManager] createFileAtPath:mp3
                                            contents:currentData
                                          attributes:nil];
    [[CachedAudioLogic instance] createCachedFromAudio:current];
    [queue removeObjectAtIndex:0];
    if(queue.count > 0) {
        [self next];
    }
}

-(void)updateProgress {
    largeProgressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 29.0f, 29.0f)];
    largeProgressView.roundedCorners = NO;
    largeProgressView.thicknessRatio = 0.15;
    largeProgressView.backgroundColor = [UIColor clearColor];
    [largeProgressView setProgress:0.0];
    largeProgressView.trackTintColor = [UIColor clearColor];
    largeProgressView.progressTintColor = [UIColor colorWithRed:(227.0/255.0) green:(227.0/255.0) blue:(227.0/255.0) alpha:1];
}


-(void) save:(NSURL *)url {
    Audio *current = [queue objectAtIndex:0];
    [self updateProgress];
    [[AppDelegate currentLogic] updateAudioState:current state:AUDIO_IN_PROGRESS_SAVE];
      currentData = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

-(BOOL)isset:(Audio*)audio {
    for (Audio *current in queue) {
        if([current.aid integerValue] == [audio.aid integerValue] && [current.owner_id integerValue] == [audio.owner_id integerValue]) {
            return YES;
        }
    }
    
    return NO;
}

+(SaveQueue *) instance {
    static SaveQueue *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SaveQueue alloc] init];
        instance.queue = [[NSMutableArray alloc] init];
        instance.requestQueue = [[NSMutableArray alloc] init];
        [instance updateProgress];
    });
    return instance;
}

@end
