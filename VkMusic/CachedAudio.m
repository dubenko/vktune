//
//  CachedAudio.m
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "CachedAudio.h"


@implementation CachedAudio

@dynamic aid;
@dynamic artist;
@dynamic title;
@dynamic duration;
@dynamic owner_id;
@dynamic album_id;
@synthesize state;
-(id)init {
    if(self = [super init]) {
        //NSLog(@"created");
    }
    
    return self;
}

-(id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    if(self = [super initWithEntity:entity insertIntoManagedObjectContext:context]) {
        state = AUDIO_SAVED;
    }
    return self;
}
@end
