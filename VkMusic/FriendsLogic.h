//
//  FriendsLogic.h
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioLogic.h"
#import "IFriendsController.h"
#import "Friend.h"
@interface FriendsLogic : AudioLogic
+(FriendsLogic *)instance;
@property (nonatomic) id<IFriendsController> friendsDelegate;
@property (nonatomic,strong) NSMutableArray *friends;

-(void)initFriends;
-(void)loadFriendAudio:(Friend *)friend;
-(NSArray *)friendList;
-(BOOL)searchFriends:(NSString *)searchText;
@end
