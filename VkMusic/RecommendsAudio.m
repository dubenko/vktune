//
//  RecommendsAudio.m
//  VkMusic
//
//  Created by keepcoder on 28.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "RecommendsAudio.h"
#import "UserLogic.h"
#import "APIRequest.h"
@implementation RecommendsAudio

+(RecommendsAudio *) instance {
    static RecommendsAudio *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RecommendsAudio alloc] init];
        instance.requestQueue = [[NSOperationQueue alloc] init];
        instance.global = NO;
        instance.loadMethod = METHOD_GET_RECOMMENDS;
    });
    return instance;
}


@end
