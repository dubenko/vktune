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

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation SaveQueue
@synthesize queue;
@synthesize status;
@synthesize requestQueue;




-(void)addAudioToQueue:(Audio *)audio {
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


-(void)next {
    Audio *current = [queue objectAtIndex:0];
    [[AudioLogic instance] loadUrlWithAudio:current target:self selector:@selector(save:) queue:requestQueue];
}



-(void) save:(NSURL *)url {
    Audio *current = [queue objectAtIndex:0];
    [[AppDelegate currentLogic] updateAudioState:current state:AUDIO_IN_PROGRESS_SAVE];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil) {
            NSString *mp3 = [NSString stringWithFormat:@"%@/%d_%d.mp3", DOCUMENTS_FOLDER,[current.owner_id integerValue],[current.aid integerValue]];
            
            [[NSFileManager defaultManager] createFileAtPath:mp3
                                                    contents:data
                                                  attributes:nil];
            [[CachedAudioLogic instance] createCachedFromAudio:current];
        } else {
            [[AppDelegate currentLogic] updateAudioState:current state:AUDIO_DEFAULT];
        }
        [queue removeObjectAtIndex:0];
        if(queue.count > 0) {
            [self next];
        }
    }];
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
    });
    return instance;
}

@end
