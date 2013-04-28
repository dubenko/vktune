//
//  APIRequest.m
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "APIRequest.h"
#import "MBHUDView.h"
#import "TestFlight.h"
@implementation APIRequest
+(void)executeRequestWithData:(APIData *)data block:(executeData)execute {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[data buildRequest]]];
    [NSURLConnection sendAsynchronousRequest:request queue:[data queue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(error == nil) {
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if([json valueForKey:@"error"] != nil) {
                TFLog(@"%@",[json valueForKey:@"error"]);
            }
        } else {
            TFLog(@"%@",error);
        }
        execute(response,data,error);
    }];
}



@end
