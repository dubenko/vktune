//
//  APIRequest.h
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIData.h"
#import "ApiURL.h"
#import "Audio.h"
@interface APIRequest : NSObject

typedef void (^executeData)(NSURLResponse *,NSData *, NSError*);
+(void)executeRequestWithData:(APIData *)data block:(executeData)execute;
@end
