//
//  UserData.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "UserLogic.h"
#import "AppDelegate.h"
#import "AudioLogic.h"
@implementation UserLogic
@synthesize currentUser;


NSInteger const SETTING_BROADCAST = 2;


static UserLogic *instance_;

-(BOOL)isAuth {
    return [currentUser boolForKey:@"auth"];
}

+(UserLogic*)instance {
    if(instance_ == nil) {
        instance_ = [[UserLogic alloc] init];
        instance_.currentUser = [NSUserDefaults standardUserDefaults];
    }
    return instance_;
}

-(BOOL)vkBroadcast {
    return [currentUser boolForKey:@"vkbroadcast"];
}
-(BOOL)autosave {
    return [currentUser boolForKey:@"autosave"];
}
-(BOOL)onlyWifi {
    return [currentUser boolForKey:@"wifi"];
}

-(BOOL)logout {
    if([self isAuth]) {
        [self clearCookie];
        [currentUser removeObjectForKey:@"auth"];
        [currentUser removeObjectForKey:@"vkbroadcast"];
        [currentUser removeObjectForKey:@"autosave"];
        [currentUser removeObjectForKey:@"repeat"];
        [currentUser removeObjectForKey:@"wifi"];
        [currentUser synchronize];
    }
    return false;
}



-(void)clearCookie {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }}



-(void)createUserWithToken:(NSString *)accessToken secret:(NSString *)secret uid:(int)uid {
    [currentUser setInteger:uid forKey:@"uid"];
    [currentUser setObject:accessToken forKey:@"access_token"];
    [currentUser setObject:secret forKey:@"secret"];
    [currentUser setBool:YES forKey:@"auth"];
    [currentUser setBool:NO forKey:@"repeat"];
    [currentUser setBool:NO forKey:@"autosave"];
    [currentUser setBool:NO forKey:@"wifi"];
    [currentUser synchronize];
}

-(void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName photo:(NSString *)photo broadcast:(BOOL)broadcast {
    [currentUser setObject:firstName forKey:@"firstName"];
    [currentUser setObject:lastName forKey:@"lastName"];
    [currentUser setObject:photo forKey:@"photo"];
    [currentUser setBool:broadcast forKey:@"vkbroadcast"];
    [currentUser synchronize];
}


@end

/*
 
 -(BOOL)setSetting:(NSInteger)stg {
 NSInteger full = [currentUser integerForKey:@"settings"];
 full+=(full & stg) == stg ? -stg : stg;
 [currentUser setInteger:full forKey:@"settings"];
 [currentUser synchronize];
 return (full & stg) == stg;
 }
 
 -(BOOL)settingEnabled:(NSInteger)stg {
 NSInteger full = [currentUser integerForKey:@"settings"];
 return (full & stg) == stg;
 }
 */
