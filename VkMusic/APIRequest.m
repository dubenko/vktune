//
//  APIRequest.m
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "APIRequest.h"
#import "MBHUDView.h"
@implementation APIRequest
+(void)executeRequestWithData:(APIData *)data block:(executeData)execute {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[data buildRequest]]];
    [NSURLConnection sendAsynchronousRequest:request queue:[data queue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        BOOL show = NO;
        if(error == nil) {
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if([json valueForKey:@"error"] != nil) {
                show = YES;
            }
        } else show = YES;
        
       /* if(show) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBHUDView *alert = [MBHUDView hudWithBody:@"Ошибка запроса" type:MBAlertViewHUDTypeImage hidesAfter:2.0 show:NO];
                [alert.imageView setImage:[UIImage imageNamed:@"error.png"]];
                
                [alert addToDisplayQueue];
            });
        } */
        execute(response,data,error);
    }];
}



@end
