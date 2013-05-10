//
//  AlbumsLogic.m
//  VkMusic
//
//  Created by keepcoder on 11.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AlbumsLogic.h"
#import "AppDelegate.h"
#import "Album.h"
#import "UserLogic.h"
#import "CachedAudioLogic.h"
#import "CachedAudio.h"
#import "NSMutableArray+Shuffler.h"
@implementation AlbumsLogic
@synthesize controller;
@synthesize albumMap;
-(id)init {
    if(self = [super init]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:[[self appDelegate] managedObjectContext]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"album_id" ascending:YES]];
        
        controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[self appDelegate] managedObjectContext] sectionNameKeyPath:nil cacheName:@"Album"];
        
        if([controller performFetch:nil]) {
            [self updateAudioMap];
        }
    }
    return self;
}

-(NSArray *)albumList {
    return [controller.fetchedObjects copy];
}

-(BOOL) search:(NSString *)input {
    return [super search:input fullList:self.fullList];
}

-(NSArray *)list {
    NSArray *full = self.searchList != nil ? self.searchList : self.fullList;
    return full;
}

-(void)updateAudioMap {
    self.albumMap = [[NSMutableDictionary alloc] init];
    for (CachedAudio *current in [CachedAudioLogic instance].controller.fetchedObjects) {
        NSString *key = [NSString stringWithFormat:@"%d",[current.album_id integerValue] ];
        NSNumber *value = [albumMap objectForKey:key];
        [albumMap setObject:[NSNumber numberWithInteger:[value integerValue]+1] forKey:key];
    }
}



-(AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)deleteAlbum:(NSInteger)index {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[self appDelegate] managedObjectContext]];

     Album *current = [self findAlbumByRow:index];
    [[[self appDelegate] managedObjectContext] deleteObject:current];
    [[[self appDelegate] managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
}



-(Album *)findAlbumById:(NSInteger)albumId {
    NSArray *copy = [self albumList];
    for (Album *album in copy) {
        if([album.album_id integerValue] == albumId) {
            return album;
        }
    }
    
    return nil;
}

-(NSInteger)albumCount:(NSInteger)album {
     return [[albumMap objectForKey:[NSString stringWithFormat:@"%d", album]] integerValue];
}

+(AlbumsLogic *)instance {
    static AlbumsLogic *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlbumsLogic alloc] init];
        instance.global = NO;
    });
    return instance;
}



-(void)setAlbum:(Audio *)audio albumId:(NSInteger)albumId {
    [[CachedAudioLogic instance] setAlbum:audio albumId:albumId];
}


-(void)updateAlbum:(NSInteger)album {
    [super updateAlbum:album];
    self.fullList = [[NSMutableArray alloc] init];
    for (CachedAudio *audio in [[CachedAudioLogic instance] list]) {
        if([audio.album_id integerValue] == self.album) {
            [self.fullList addObject:audio];
        }
    }
    [self updateAudioMap];
    [self updateContent:YES];
}

-(Album *)findAlbumByRow:(NSInteger)row {
    return [[self albumList] objectAtIndex:row];
}


-(void)contextDidSave:(NSNotification*)saveNotification {
    NSManagedObjectContext *context = [controller managedObjectContext];
    [context mergeChangesFromContextDidSaveNotification:saveNotification];
}

-(int)createAlbumWithName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[self appDelegate] managedObjectContext]];
    Album *album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:[[self appDelegate] managedObjectContext]];
    album.title = name;
    album.owner_id = [NSNumber numberWithInt:[[[UserLogic instance] currentUser] integerForKey:@"uid"]];
    
    album.album_id = [NSNumber numberWithInt:[[UserLogic instance] maxAlbumId]];
    [[UserLogic instance] setAlbumId:[[UserLogic instance] maxAlbumId]+1];
    
    [[[self appDelegate] managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
    
    return [album.album_id integerValue];
}

@end
