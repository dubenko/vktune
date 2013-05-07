//
//  BaseLogicController.m
//  VkMusic
//
//  Created by keepcoder on 04.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "BaseLogicController.h"
#import "APIRequest.h"
#import "UserLogic.h"
#import "AudioLogic.h"
#import "CachedAudioLogic.h"
#import "NSMutableArray+Shuffler.h"

@implementation BaseLogicController
@synthesize delegate;
@synthesize searchList;
@synthesize album;
@synthesize searchTimer;
@synthesize fullList;
@synthesize globalResult;
@synthesize global;
@synthesize loadMethod;
@synthesize fullLoaded;
@synthesize audioMap;
-(id)init {
    if(self = [super init]) {
        album = -1;
        audioMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)shuffle {
    if(q == nil) {
        [self.fullList shuffle];
        [self updateContent:YES];
    }
}
-(void)updateFullList:(NSMutableArray *)newList {
    
}
-(void)deleteFromSearch:(Audio *)audio {
    [searchList removeObject:audio];
}

-(BOOL)search:(NSString *)input fullList:(NSArray *)_fullList{
    NSMutableArray *copy = [[NSMutableArray alloc] init];
    if(input != nil && [input length] > 0) {
        for (Audio *current in _fullList) {
            if(([current.artist rangeOfString:input options:NSCaseInsensitiveSearch].location != NSNotFound) || ([current.title rangeOfString:input options:NSCaseInsensitiveSearch].location != NSNotFound)) {
                [copy addObject:current];
            }
        }
    } else {
        copy = nil;
    }
    BOOL needUpdate = ![[self list] isEqualToArray:copy];
    
    searchList = copy;
    globalResult = nil;
    q = nil;
    if(copy != nil && [copy count] < 5 && global) {
        
        [searchTimer invalidate];
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(globalSearch:) userInfo:input repeats:NO];
    }
    [self updateAudioMap];
    return needUpdate || copy == nil;
}

-(void)globalSearch:(NSTimer *)timer {
    q = [timer userInfo];
    globalResult = [[NSMutableArray alloc] init];
    fullLoaded = NO;
    [self loadGlobalWithOffset];
}
-(void)loadGlobalWithOffset {
    if (!fullLoaded){
        APIData *apiData = [[APIData alloc] initWithMethod:AUDIO_SEARCH user:[[UserLogic instance]currentUser] params:[[NSMutableDictionary alloc] initWithObjectsAndKeys:q,@"q",@"30",@"count",[NSString stringWithFormat:@"%d",globalResult.count],@"offset", nil]];
        [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(error == nil) {
                NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if([[json valueForKey:@"response"] count] > 0) {
                    json = [json valueForKey:@"response"];
                    [json removeObjectAtIndex:0];
                    for (NSDictionary *audio in json) {
                        Audio *n = [[AudioLogic instance] createNewAudio:NO aid:[[audio valueForKey:@"aid"] integerValue] ownerId:[[audio valueForKey:@"owner_id"] integerValue] artist:[audio valueForKey:@"artist"] title:[audio valueForKey:@"title"] duration:[[audio valueForKey:@"duration"] integerValue]];
                        [globalResult addObject:n];
                    }
                    if(json.count < 30) {
                        fullLoaded = YES;
                    }
                    [[CachedAudioLogic instance] updateList:[self list]];
                    [self updateContent:globalResult.count <= 30];
                    [self updateAudioMap];
                }
            }
        }];
    }
}


-(Audio *)findAudio:(NSInteger)aid ownerId:(NSInteger)owner_id {
    NSNumber *row = [self.audioMap objectForKey:[NSString stringWithFormat:@"%d_%d",owner_id,aid]];
    return row != nil ? [[self list] objectAtIndex:[row integerValue]] : nil;
}


-(void)updateContent:(BOOL)animated {
    if([self.delegate respondsToSelector:@selector(didChangeContent:)]) {
        [self.delegate performSelector:@selector(didChangeContent:) withObject:[NSNumber numberWithBool:animated]];
    }
}


-(void)updateAlbum:(NSInteger)_album {
    self.album = _album;
}


-(BOOL)search:(NSString *)input {
    return YES;
}

-(NSIndexPath *)findRowIndex:(Audio*)rowAudio {
    NSArray *copy = [self list];
    int row = -1;
    for (int i = 0; i < copy.count; i++) {
        Audio *current = copy[i];
        if([current.aid integerValue] == [rowAudio.aid integerValue] && [current.owner_id integerValue] == [rowAudio.owner_id integerValue]) {
            row = i;
            break;
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:0];
}

-(void)updateAudioMap {
    self.audioMap = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [self list].count; i++) {
        Audio *audio = [self list][i];
        [self.audioMap setObject:[NSNumber numberWithInt:i] forKey:[NSString stringWithFormat:@"%d_%d",[audio.owner_id integerValue],[audio.aid integerValue]]];
    }
}

-(BOOL)needGlobalLoad {
    return q != nil;
}


-(void)updateAudioState:(Audio *)audio state:(AudioState)state {
    audio.state = state;
    if([self.delegate respondsToSelector:@selector(didChangeAudioState:)]) {
        [self.delegate performSelector:@selector(didChangeAudioState:) withObject:audio];
    }
}



-(Audio *)findAudioByRow:(NSInteger)row {
    return [[self list] objectAtIndex:row];
}


-(NSArray *)list {
    return nil;
}
-(void)loadMore {
    [self loadGlobalWithOffset];
}


-(void)deleteAudio:(Audio *)audio callback:(voidCallback)callback {
    
}


@end
