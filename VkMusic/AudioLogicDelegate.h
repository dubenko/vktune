//
//  AudioLogicDelegate.h
//  VkMusic
//
//  Created by keepcoder on 21.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
@protocol AudioLogicDelegate <NSObject>

@optional
-(void)didChangeContent:(NSNumber *)animated list:(NSArray *)list;

-(void)didDeleteRowAtIndex:(NSNumber *)index;
-(void)didChangeAudioState:(Audio *)audio;
@end
