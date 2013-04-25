//
//  APIData.m
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "APIData.h"
#import "ApiURL.h"
#import "CryptoUtils.h"
#import "NSString+URLEncoding.h"
@implementation APIData
@synthesize method;
@synthesize params;
@synthesize user;
@synthesize queue;
-(NSString *)buildRequest {
    NSMutableString *url = [[NSMutableString alloc] init];
    [url appendFormat:@"/method/%@?",method];
    
    
    for (NSString *key in params) {
        [url appendFormat:@"%@=%@&",key,[params objectForKey:key]];
    }
    
    
    [url appendFormat:@"sig=%@",[self buildSig:[url substringToIndex:[url length]-1]]];
    return [NSString stringWithFormat:@"%@%@",API_URL,[url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
}




-(NSString *)buildSig:(NSString *)url {
    NSMutableString *sig = [[NSMutableString alloc] initWithString:url];;
    [sig appendFormat:@"%@",[user stringForKey:@"secret"]];
    return [CryptoUtils md5:sig];
}



-(id)initWithMethod:(NSString *)_method user:(NSUserDefaults *)_user params:(NSMutableDictionary *)_params {
    if(self = [super init]) {
        self.method = _method;
        self.user = _user;
        self.params = _params;
        self.queue = self.queue != nil ? queue : [[NSOperationQueue alloc] init];
        [params setObject:[user stringForKey:@"access_token"] forKey:@"access_token"];
    }
   
    return self;
}

-(id)initWithMethod:(NSString *)_method user:(NSUserDefaults *)_user queue:(NSOperationQueue *)_queue params:(NSMutableDictionary *)_params {
    self = [self initWithMethod:_method user:_user params:_params];
    self.queue = _queue != nil ? _queue : [[NSOperationQueue alloc] init];
    return self;
}




@end
