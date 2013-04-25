//
//  NSString+URLEncoding.m
//  VkMusic
//
//  Created by keepcoder on 09.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"{}",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end
