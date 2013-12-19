//
//  Friend.h
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject
@property (nonatomic,strong) NSString *first_name;
@property (nonatomic,strong) NSString *last_name;
@property (nonatomic,strong) NSString *photo;
@property (nonatomic,assign) NSInteger uid;
@end
