//
//  URLParser.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "URLParser.h"

@implementation URLParser
@synthesize variables;
- (id) initWithURLString:(NSString *)url  {
    self = [super init];
    if (self != nil) {
        variables = [[NSMutableDictionary alloc] init];
        NSArray * pairs = [url componentsSeparatedByString:@"&"];
        for (NSString * pair in pairs) {
            NSArray * bits = [pair componentsSeparatedByString:@"="];
            NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            [variables setObject:value forKey:key];
        }
        
    }
    return self;
}

- (NSString *)valueForVariable:(NSString *)varName {
    return [variables objectForKey:varName];
}
@end
