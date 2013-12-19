//
//  IFriendsController.h
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFriendsController <NSObject>
-(void)friendsDidLoad:(NSArray *)friends;
@end
