//
//  APIData.h
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface APIData : NSObject
@property (nonatomic,strong) NSUserDefaults *user;
@property (nonatomic,strong) NSString *method;
@property (nonatomic,strong) NSMutableDictionary *params;
@property (nonatomic,strong) NSOperationQueue *queue;
-(NSString *)buildRequest;
-(id)initWithMethod:(NSString *)_method user:(NSUserDefaults *)_user params:(NSMutableDictionary *)_params;
-(id)initWithMethod:(NSString *)_method user:(NSUserDefaults *)_user queue:(NSOperationQueue *)_queue params:(NSMutableDictionary *)_params;
@end
