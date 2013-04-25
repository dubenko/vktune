//
//  AppConst.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ApiURL : NSObject
extern NSString * const AUTH_URL;
extern NSString * const SUCCESS_URL;
extern NSString * const API_URL;

extern NSString * const METHOD_USERS_GET;
extern NSString * const METHOD_AUDIO_GET;
extern NSString * const AUDIO_GET_BY_ID;
extern NSString * const STATUS_SET;
extern NSString * const AUDIO_SET_BROADCAST;
extern NSString * const AUDIO_SEARCH;
extern NSString * const EXECUTE_FIRST_REQUEST;
@end
