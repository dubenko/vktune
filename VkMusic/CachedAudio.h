//
//  CachedAudio.h
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Audio.h"
/*
 states:
 
 0 - default;
 1 - in save queue
 2 - in progress save;
 3 - saved;
 
 */

@interface CachedAudio : NSManagedObject

@property (nonatomic, retain) NSNumber * aid;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * album_id;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, assign) AudioState state;

@end
