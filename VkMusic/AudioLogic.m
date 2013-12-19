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
#import "RecommendsAudio.h"
@implementation AudioLogic
@synthesize lastId;
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
        instance_.loadMethod = METHOD_AUDIO_GET;
        instance_.global = YES;
        instance_.uid = [[UserLogic instance].currentUser integerForKey:@"uid"];
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






-(void)firstRequest:(id)target selector:(SEL)selector {
    if(!firstInit || target != nil) {
        self.fullLoaded = NO;
       NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:self.uid],@"uid", nil];
        APIData *apiData = [[APIData alloc] initWithMethod:EXECUTE_FIRST_REQUEST user:[[UserLogic instance] currentUser] queue:requestQueue params:params];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(error == nil) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if(json != nil) {
                    NSJSONSerialization *user = [[json valueForKey:@"response"] valueForKey:@"user"];
                    BOOL broadcast = [[[json valueForKey:@"response"] valueForKey:@"broadcast"] boolValue];
                    [[UserLogic instance] setFirstName:[user valueForKey:@"first_name"] lastName:[user valueForKey:@"last_name"] photo:[user valueForKey:@"photo_rec"] broadcast:broadcast];
                    self.fullList = [[NSMutableArray alloc] init];
                    [self updateAudioMap];
                    [self withoutSave:[[json valueForKey:@"response"] valueForKey:@"audio"] animated:NO];
                    [RecommendsAudio instance].fullList = [[NSMutableArray alloc] init];
                    [[RecommendsAudio instance] updateAudioMap];
                    [[RecommendsAudio instance] withoutSave:[[json valueForKey:@"response"] valueForKey:@"recommends"] animated:NO];
                    firstInit = YES;
                }
            }
            if([target respondsToSelector:selector]) {
                [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

-(void)loadWithOffset:(NSInteger)offset animated:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:self.uid],@"uid",@"30",@"count",
                                       [NSString stringWithFormat:@"%d",offset],@"offset", nil];
            APIData *apiData = [[APIData alloc] initWithMethod:self.loadMethod user:[[UserLogic instance] currentUser] queue:requestQueue params:params ];
            NSLog(@"%@",[apiData buildRequest]);
            [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
                if(error == nil) {
                    NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                    
                    if(json != nil) {
                        NSArray *list = [json valueForKey:@"response"];
                        [self withoutSave:list animated:animated];
                    }
                } else {
                    [self updateContent:NO];
                }
            
            }];
        });

    
}


-(void)setBroadcast:(Audio *)audio {
    if([[UserLogic instance] vkBroadcast]) {
        NSString *format = [NSString stringWithFormat:@"%d_%d",self.uid,[audio.aid integerValue]];
        APIData *apiData = [[APIData alloc] initWithMethod:STATUS_SET user:[[UserLogic instance] currentUser] queue:requestQueue params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:format,@"audio", nil]];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            
        }];
    }
}

-(NSArray *)list {
    NSMutableArray *full = self.searchList != nil ? [self.searchList mutableCopy] : [self.fullList mutableCopy];
    [full addObjectsFromArray:self.globalResult];
    return [full copy];
}

-(void)deleteAudio:(Audio *)audio callback:(voidCallback)callback {
   // [[CachedAudioLogic instance] deleteAudio:audio];
}

-(BOOL)search:(NSString *)input {
    return [super search:input fullList:self.fullList];
}

-(void)withoutSave:(NSArray *)list animated:(BOOL)animated {
    for (NSDictionary *audio in list) {
        
        Audio *n = [self createNewAudio:NO aid:[[audio valueForKey:@"aid"] integerValue] ownerId:[[audio valueForKey:@"owner_id"] integerValue] artist:[audio valueForKey:@"artist"] title:[audio valueForKey:@"title"] duration:[[audio valueForKey:@"duration"] integerValue]];
        [self.fullList addObject:n];
        
    }
    if(list != nil && list.count == 0) {
        self.fullLoaded = YES;
    }
    lastId = self.fullList.count;
    [self updateAudioMap];
    [[CachedAudioLogic instance] updateList:[self list]];
    [self updateContent:animated];
}



-(void)loadUrlWithAudio:(Audio *)audio target:(id)target selector:(SEL)selector {
    APIData *apiData = [[APIData alloc] initWithMethod:AUDIO_GET_BY_ID user:[[UserLogic instance] currentUser] queue:requestQueue params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d_%d",[audio.owner_id  integerValue],[audio.aid integerValue]],@"audios", nil]];
    [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *forLoad = [[NSDictionary alloc] initWithObjectsAndKeys:audio,@"audio",[NSValue valueWithPointer:selector],@"selector",target,@"target", nil];
        if(error == nil) {
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if([[json valueForKey:@"response"] count] > 0) {
                [target performSelectorOnMainThread:selector withObject:[NSURL URLWithString:[json valueForKeyPath:@"response.url"][0]] waitUntilDone:NO];
            } else {
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimerComplete:) userInfo:forLoad repeats:NO];
            }
            
        } else {
           [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimerComplete:) userInfo:forLoad repeats:NO];
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
        if(!self.fullLoaded) {
            [self loadWithOffset:lastId animated:NO];
        }
    }
}
@end


