//
//  SaveQueue.m
//  VkMusic
//
//  Created by keepcoder on 30.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SaveQueue.h"
#import "CachedAudioLogic.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation SaveQueue
@synthesize queue;
@synthesize status;





-(void)addAudioToQueue:(Audio *)audio asset:(AVAsset *)asset {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(![self isset:audio]) {
            [queue addObject:[NSDictionary dictionaryWithObjectsAndKeys:audio,@"audio",asset,@"asset", nil]];
            NSLog(@"added %d, queue count %d",[audio.aid integerValue],queue.count);
            if(queue.count == 1) {
                [self save];
            }
        }
    });
}


-(void)save {
        NSDictionary *currentItem = [queue objectAtIndex:0];
        
        AVAsset *asset = [currentItem objectForKey:@"asset"];
        Audio* audio = [currentItem objectForKey:@"audio"];
        
        
        AVMutableComposition* mixComposition = [AVMutableComposition composition];
        if([[asset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
            AVMutableCompositionTrack *compositionAudioSoundTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [compositionAudioSoundTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                            ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                             atTime:kCMTimeZero error:nil];
        }
       
        
        
        AVAssetExportSession *es = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@/%d.m4a", DOCUMENTS_FOLDER, [audio.aid integerValue]];
        [fileManager removeItemAtPath:path error:NULL];
        [es setOutputFileType:@"com.apple.m4a-audio"];
        es.outputURL = [[NSURL alloc] initFileURLWithPath:path];
        es.shouldOptimizeForNetworkUse = YES;
        
        [es exportAsynchronouslyWithCompletionHandler:^{
            NSLog(@"export complete aid:%d with status: %d, queue count:%d",[audio.aid integerValue],es.status,queue.count);
            if(es.status == AVAssetExportSessionStatusCompleted) {
                [[CachedAudioLogic instance] createCachedFromAudio:audio];
               
            }
            
            [queue removeObjectAtIndex:0];
            if(queue.count > 0) {
                [self save];
            }
            
        }];
    
}


-(BOOL)isset:(Audio*)audio {
    for (NSDictionary *item in queue) {
        Audio *queued = [item objectForKey:@"audio"];
        if([queued.aid integerValue] == [audio.aid integerValue]) {
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
    });
    return instance;
}

@end
