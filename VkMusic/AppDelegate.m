//
//  AppDelegate.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthViewController.h"
#import "MainViewController.h"
#import "UIImage+Extension.h"
#import "Consts.h"
#import "TestFlight.h"
#import "SIMenuConfiguration.h"
@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize navigationController;
@synthesize mainViewController;
@synthesize authViewController;

@synthesize backgroudTaskIndetifier;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"f2a5747c-6766-463a-89a6-3c336187c24d"];
    UIViewController *rootController = nil;
   
    
    
 
    if([[UserLogic instance] isAuth]) {
        rootController = [self returnOrCreateMainViewController];
    } else {
        rootController = [self returnOrCreateAuthViewController];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[SIMenuConfiguration selectionColor]] forBarMetrics:UIBarMetricsDefault]; // 90 154 168
    
    self.navigationController = [[NavigationController alloc] initWithRootViewController:rootController];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageWithColor:[SIMenuConfiguration selectionColor]] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
   
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:FONT_BOLD size:17.0], UITextAttributeFont,
      nil]];

     
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor grayColor], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIFont fontWithName:FONT_BOLD size:10.0], UITextAttributeFont,
      nil] forState:UIControlStateNormal];
    
    
    self.window.rootViewController = navigationController;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
   
    
    // Set itself as the first responder
    //[self becomeFirstResponder];
    
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[self returnOrCreateMainViewController] playerDidPlayOrPause];
                 
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
            [[self returnOrCreateMainViewController] needPrevToPlay];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[self returnOrCreateMainViewController] needAudioToPlay];
                break;
                
            default:
                break;
        }
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}



-(MainViewController *)returnOrCreateMainViewController {
    if(mainViewController == nil) {
        mainViewController = [[MainViewController alloc] initWithNibName:nil bundle:NULL];
    }
    
    return mainViewController;
};
-(WebAuthViewController *)returnOrCreateAuthViewController {
    if(authViewController == nil) {
        authViewController = [[WebAuthViewController alloc] initWithNibName:nil bundle:NULL];
    }
    return authViewController;
};

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



-(void)endBackgroundTask {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        AppDelegate *strongSelf = weakSelf;
        if(strongSelf != nil) {
            [[UIApplication sharedApplication] endBackgroundTask:backgroudTaskIndetifier];
            strongSelf.backgroudTaskIndetifier = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if([self isMultitaskingSupported] == NO) {
        return;
    }
    self.backgroudTaskIndetifier = [application beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

-(BOOL) isMultitaskingSupported {
    BOOL result = NO;
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self endBackgroundTask];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(NSManagedObjectContext *) managedObjectContext
{
    
    NSThread * thisThread = [NSThread currentThread];
    if (thisThread == [NSThread mainThread])
    {
        //Main thread just return default context
        if(_managedObjectContext != nil) {
            return _managedObjectContext;
        } else {
            NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
            if (coordinator != nil) {
                _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            }
            return _managedObjectContext;
        }
        
    }
    else
    {
        //Thread safe trickery
        NSManagedObjectContext * threadManagedObjectContext = [[thisThread threadDictionary] objectForKey:@"NSManagedObjectContext"];
        if (threadManagedObjectContext == nil)
        {
            threadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [threadManagedObjectContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
            [[thisThread threadDictionary] setObject:threadManagedObjectContext forKey:@"NSManagedObjectContext"];
        }
        
        return threadManagedObjectContext;
    }
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
/*- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}*/

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VkMusic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"VkMusic.sqlite"];
    
    NSError *error = nil;
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
    */
       // @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

/*
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"VkMusic.sqlite"]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"VkMusic.sqlite"];
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Handle error
    }
    
    return _persistentStoreCoordinator;
}
 */
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
