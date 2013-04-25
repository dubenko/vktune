//
//  UserData.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserLogic : NSObject

@property (nonatomic,strong) NSUserDefaults *currentUser;


-(BOOL) logout;
-(BOOL) isAuth;

-(void)createUserWithToken:(NSString *) accessToken secret: (NSString *) secret uid:(int)uid;
-(void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName photo:(NSString *)photo broadcast:(BOOL)broadcast;
-(void)clearCookie;
+(UserLogic*) instance;

-(BOOL)vkBroadcast;
-(BOOL)autosave;
@end
