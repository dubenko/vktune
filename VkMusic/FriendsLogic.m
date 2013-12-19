//
//  FriendsLogic.m
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "FriendsLogic.h"
#import "APIRequest.h"
#import "UserLogic.h"

@interface FriendsLogic ()
@property (nonatomic,strong) NSMutableArray *friendSearchList;
@end

@implementation FriendsLogic
+(FriendsLogic *) instance {
    static FriendsLogic *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FriendsLogic alloc] init];
        instance.loadMethod = METHOD_AUDIO_GET;
        instance.friends = [[NSMutableArray alloc] init];
    });
    return instance;
}

-(void)loadFriendAudio:(Friend *)friend {
    self.uid = friend.uid;
    self.fullList = [[NSMutableArray alloc] init];
    
    [self updateAudioMap];
    [super loadWithOffset:0 animated:YES];
}

-(NSArray *)friendList {
    NSMutableArray *full = self.friendSearchList != nil ? [self.friendSearchList mutableCopy] : [self.friends mutableCopy];
    return [full copy];
}

-(BOOL)searchFriends:(NSString *)searchText {
    NSMutableArray *copy = [[NSMutableArray alloc] init];
    if(searchText != nil && [searchText length] > 0) {
        for (Friend *current in [FriendsLogic instance].friends) {
            if(([current.first_name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) || ([current.last_name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)) {
                [copy addObject:current];
            }
        }
    } else {
        copy = nil;
    }
    BOOL needUpdate = ![[FriendsLogic instance].friends isEqualToArray:copy];
    self.friendSearchList  = copy;
    if(needUpdate) {
        if([self.friendsDelegate respondsToSelector:@selector(friendsDidLoad:)]) {
            [self.friendsDelegate performSelector:@selector(friendsDidLoad:) withObject:self.friendList];
        }
    }
    return needUpdate || copy == nil;

}




-(void)initFriends {
    if(self.friends.count == 0) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"offset"] = [NSNumber numberWithInt:self.friends.count];
        params[@"fields"] = @"first_name,last_name,photo_100,can_see_audio";
        params[@"order"] = @"hints";
       // params[@"lang"] = LANG;
        APIData *data = [[APIData alloc] initWithMethod:METHOD_FRIENDS_GET user:[UserLogic instance].currentUser params:params];
        [APIRequest executeRequestWithData:data block:^(NSURLResponse *response, NSData *data, NSError *error) {
            if(error == nil) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                if(error == nil) {
                    for (NSDictionary *f in [json valueForKey:@"response"]) {
                        if([[f valueForKey:@"can_see_audio"] boolValue]) {
                            Friend *friend = [[Friend alloc] init];
                            friend.first_name = [f valueForKey:@"first_name"];
                            friend.last_name = [f valueForKey:@"last_name"];
                            friend.photo = [f valueForKey:@"photo_100"];
                            friend.uid = [[f valueForKey:@"uid"] integerValue];
                            [self.friends addObject:friend];

                        }
                    }
                    if([self.friendsDelegate respondsToSelector:@selector(friendsDidLoad:)]) {
                        [self.friendsDelegate performSelector:@selector(friendsDidLoad:) withObject:self.friends];
                    }
                }
            }
        }];
    }
}

@end
