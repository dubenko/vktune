//
//  SaveQueue.h
//  VkMusic
//
//  Created by keepcoder on 30.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "AVFoundation/AVFoundation.h"
@interface SaveQueue : NSObject
@property (nonatomic,strong) NSMutableArray *queue;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,strong) NSMutableArray *requestQueue;
-(void)addAudioToQueue:(Audio *)audio;
+(SaveQueue *)instance;
@end
