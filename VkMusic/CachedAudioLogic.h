//
//  CachedAudioLogic.h
//  VkMusic
//
//  Created by keepcoder on 29.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "CachedAudio.h"
#import "AudioLogicDelegate.h"
#import "ILogicController.h"
#import "BaseLogicController.h"
@interface CachedAudioLogic : BaseLogicController<NSFetchedResultsControllerDelegate>
@property (nonatomic,strong)NSFetchedResultsController *controller;
+(CachedAudioLogic *)instance;
-(void)createCachedFromAudio:(Audio*)audio;
-(BOOL)isExists:(Audio*)audio;
-(NSArray *)list;
-(void)updateList:(NSArray *)list;
@end
