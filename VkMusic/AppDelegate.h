//
//  AppDelegate.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserLogic.h"
#import "AuthViewController.h"
#import "NavigationController.h"
#import "AudioLogic.h"
#import "MainViewController.h"
#import "WebAuthViewController.h"
#import "ILogicController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) NavigationController *navigationController;
@property (nonatomic,strong) MainViewController *mainViewController;
@property (nonatomic,strong) WebAuthViewController *authViewController;
@property(nonatomic,unsafe_unretained) UIBackgroundTaskIdentifier backgroudTaskIndetifier;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(MainViewController *)returnOrCreateMainViewController;
-(WebAuthViewController *)returnOrCreateAuthViewController;
+(id <ILogicController>)currentLogic;
-(void)logout;
@end
