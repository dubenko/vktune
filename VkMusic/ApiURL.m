//
//  AppConst.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ApiURL.h"

@implementation ApiURL
NSString *const AUTH_URL = @"https://oauth.vk.com/authorize?client_id=2965705&scope=offline,audio,friends,nohttps,status,activity&redirect_uri=blank.html&display=mobile&response_type=token";
NSString *const SUCCESS_URL = @"https://oauth.vk.com/blank.html#";
NSString *const API_URL = @"http://api.vk.com";

NSString *const METHOD_USERS_GET = @"users.get";
NSString *const METHOD_AUDIO_GET = @"audio.get";
NSString *const METHOD_GET_RECOMMENDS = @"audio.getRecommendations";
NSString *const AUDIO_GET_BY_ID = @"audio.getById";
NSString *const STATUS_SET = @"status.set";
NSString *const AUDIO_SET_BROADCAST = @"audio.setBroadcast";
NSString *const AUDIO_SEARCH = @"audio.search";
//NSString *const EXECUTE_FIRST_REQUEST = @"var user = API.users.get({uids:%d,fields:\"photo_rec\"}); var audio = API.audio.get({offset:%d,count:%d,uid:%d}); return {user:user[0],broadcast:API.audio.getBroadcast({}).enabled,audio:audio};";
NSString *const EXECUTE_FIRST_REQUEST = @"execute.firstRequest";
@end
