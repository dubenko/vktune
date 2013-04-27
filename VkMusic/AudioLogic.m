//
//  SoundLogic.m
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AudioLogic.h"
#import "APIData.h"
#import "APIRequest.h"
#import "ApiURL.h"
#import "AppDelegate.h"
#import "CachedAudio.h"
#import "AlbumsLogic.h"
#import "CachedAudioLogic.h"
#import "NSMutableArray+Shuffler.h"
@implementation AudioLogic
@synthesize lastId;
@synthesize fullLoaded;
@synthesize requestQueue;
@synthesize fetchRequest;
@synthesize firstInit;
@synthesize timer;
static AudioLogic *instance_;
#define DEFAULT_LOAD_LENGTH 30;
-(id)init {
    if(self = [super init]) {
        self.fullList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setAlbum:(Audio *)audio albumId:(NSInteger)albumId {
    [[CachedAudioLogic instance] setAlbum:audio albumId:albumId];
}


-(void)updateView {
    
}

+(AudioLogic*)instance {
    if(instance_ == nil) {
        instance_ = [[AudioLogic alloc] init];
        instance_.requestQueue = [[NSOperationQueue alloc] init];
        [instance_.requestQueue setMaxConcurrentOperationCount:1];
    }
    return instance_;
}


-(AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

-(void)clear {
    [self.fullList removeAllObjects];
}

-(Audio *)createNewAudio:(BOOL)save aid:(NSInteger)aid ownerId:(NSInteger)ownerId artist:(NSString *)artist title:(NSString *)title duration:(NSInteger)duration {
    
    Audio *audio = [self findAudio:aid ownerId:ownerId];
    audio = audio != nil ? audio : [[Audio alloc] init];
    audio.aid = [NSNumber numberWithInteger:aid];
    audio.owner_id = [NSNumber numberWithInteger:ownerId];
    audio.artist = artist;
    audio.title = title;
    audio.duration = [NSNumber numberWithInteger:duration];
    audio.state = AUDIO_DEFAULT;
    return audio;
}



-(Audio *)findAudio:(NSInteger)aid ownerId:(NSInteger)owner_id {
    NSArray *copy = [[self list] copy];
    for (Audio *audio in copy) {
        if([audio.aid integerValue] == aid && [audio.owner_id integerValue] == owner_id) {
            return audio;
        }
    }
    return nil;
}




-(void)firstRequest:(id)target selector:(SEL)selector {
    if(!firstInit || target != nil) {
       NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[[UserLogic instance] currentUser] objectForKey:@"uid"],@"uid", nil];
        APIData *apiData = [[APIData alloc] initWithMethod:EXECUTE_FIRST_REQUEST user:[[UserLogic instance] currentUser] queue:requestQueue params:params];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(error == nil) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if(json != nil) {
                    NSJSONSerialization *user = [[json valueForKey:@"response"] valueForKey:@"user"];
                    BOOL broadcast = [[[json valueForKey:@"response"] valueForKey:@"broadcast"] boolValue];
                    [[UserLogic instance] setFirstName:[user valueForKey:@"first_name"] lastName:[user valueForKey:@"last_name"] photo:[user valueForKey:@"photo_rec"] broadcast:broadcast];
                    self.fullList = [[NSMutableArray alloc] init];
                    [self withoutSave:[[json valueForKey:@"response"] valueForKey:@"audio"]];
                    firstInit = YES;
                }
            }
            if([target respondsToSelector:selector]) {
                [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

-(void)loadWithOffset:(NSInteger)offset {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[[UserLogic instance] currentUser] valueForKey:@"uid"],@"uid",@"30",@"count",
                                       [NSString stringWithFormat:@"%d",lastId],@"offset", nil];
        APIData *apiData = [[APIData alloc] initWithMethod:METHOD_AUDIO_GET user:[[UserLogic instance] currentUser] queue:requestQueue params:params ];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(error == nil) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if(json != nil) {
                    NSArray *list = [json valueForKey:@"response"];
                    NSLog(@"%@",json);
                    [self withoutSave:list];
                }
            }
            
        }];
    });
    
}


-(void)setBroadcast:(Audio *)audio {
    if([[UserLogic instance] vkBroadcast]) {
        NSString *format = [NSString stringWithFormat:@"%d_%d",[[[UserLogic instance] currentUser] integerForKey:@"uid"],[audio.aid integerValue]];
        APIData *apiData = [[APIData alloc] initWithMethod:STATUS_SET user:[[UserLogic instance] currentUser] queue:requestQueue params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:format,@"audio", nil]];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            
        }];
    }
}

-(NSArray *)list {
    NSMutableArray *full = self.searchList != nil ? [self.searchList mutableCopy] : [self.fullList mutableCopy];
    [full addObjectsFromArray:self.globalResult];
    return full;
}

-(void)deleteAudio:(Audio *)audio callback:(voidCallback)callback {
   // [[CachedAudioLogic instance] deleteAudio:audio];
}

-(BOOL)search:(NSString *)input {
    return [super search:input fullList:self.fullList];
}

-(void)withoutSave:(NSArray *)list {
    for (NSDictionary *audio in list) {
        
        Audio *n = [self createNewAudio:NO aid:[[audio valueForKey:@"aid"] integerValue] ownerId:[[audio valueForKey:@"owner_id"] integerValue] artist:[audio valueForKey:@"artist"] title:[audio valueForKey:@"title"] duration:[[audio valueForKey:@"duration"] integerValue]];
        [self.fullList addObject:n];
        
    }
    lastId = self.fullList.count;
    [[CachedAudioLogic instance] updateList:[self list]];
    [self updateContent:NO];
}


-(void)loadUrlWithAudio:(Audio *)audio target:(id)target selector:(SEL)selector {

    APIData *apiData = [[APIData alloc] initWithMethod:AUDIO_GET_BY_ID user:[[UserLogic instance] currentUser] queue:requestQueue params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d_%d",[audio.owner_id  integerValue],[audio.aid integerValue]],@"audios", nil]];
    [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if(error == nil) {
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if([[json valueForKey:@"response"] count] > 0) {
                [target performSelectorOnMainThread:selector withObject:[NSURL URLWithString:[json valueForKeyPath:@"response.url"][0]] waitUntilDone:NO];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    [self loadUrlWithAudio:audio target:target selector:selector];
                });
            }
            
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                [self loadUrlWithAudio:audio target:target selector:selector];
            });
        }
        
    }];
}

-(void)onTimerComplete:(NSTimer *)_timer {
    Audio *audio = [_timer.userInfo objectForKey:@"audio"];
    SEL selector = [[_timer.userInfo objectForKey:@"selector"] pointerValue];
    id target = [_timer.userInfo objectForKey:@"target"];
    [self loadUrlWithAudio:audio target:target selector:selector];
}

-(void)loadUrlWithAudio:(Audio *)audio target:(id)target selector:(SEL)selector waitTime:(NSTimeInterval)interval {
    [timer invalidate];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:audio,@"audio",[NSValue valueWithPointer:selector],@"selector",target,@"target", nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(onTimerComplete:) userInfo:data repeats:NO];
    
}




                                       
-(void)loadMore {
    if([self needGlobalLoad]) {
        [super loadMore];
    } else {
        [self loadWithOffset:lastId];
    }
}
@end


