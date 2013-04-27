//
//  Audio.h
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//


/*
 states:
 
 0 - default;
 1 - in save queue
 2 - in progress save;
 3 - saved;
 */

#import <Foundation/Foundation.h>

@interface Audio : NSObject

typedef enum {
    AUDIO_DEFAULT = 0,
    AUDIO_IN_SAVE_QUEUE = 1,
    AUDIO_IN_PROGRESS_SAVE = 2,
    AUDIO_SAVED = 3
} AudioState;

@property (nonatomic, strong) NSNumber * aid;
@property (nonatomic, strong) NSNumber * owner_id;
@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * duration;

@property (nonatomic,assign) AudioState state;
@end
