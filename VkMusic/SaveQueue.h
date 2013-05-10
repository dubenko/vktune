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
#import "DACircularProgressView.h"
@interface SaveQueue : NSObject<NSURLConnectionDataDelegate>
@property (nonatomic,strong) NSMutableArray *queue;
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,strong) NSMutableArray *requestQueue;
@property (nonatomic,strong) NSMutableData *currentData;
@property (nonatomic) NSInteger dataLength;
@property (strong, nonatomic) DACircularProgressView *largeProgressView;
-(void)addAudioToQueue:(Audio *)audio;
+(SaveQueue *)instance;
@end
