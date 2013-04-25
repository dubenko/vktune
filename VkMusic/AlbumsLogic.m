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
-(id)init {
    if(self = [super init]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:[[self appDelegate] managedObjectContext]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"album_id" ascending:YES]];
        
        controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[self appDelegate] managedObjectContext] sectionNameKeyPath:nil cacheName:@"Album"];
        
        if([controller performFetch:nil]) {
            NSLog(@"success");
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
    return self.searchList != nil ? self.searchList : self.fullList;
}



-(AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)deleteAlbum:(NSInteger)index {
    Album *current = [self findAlbumByRow:index];
    for (CachedAudio *audio in [CachedAudioLogic instance].controller.fetchedObjects) {
        if([audio.album_id integerValue] == [current.album_id integerValue]) {
            [audio willChangeValueForKey:@"album_id"];
            audio.album_id = [NSNumber numberWithInt:-1];
            [audio didChangeValueForKey:@"album_id"];
        }
    }
    [[[self appDelegate] managedObjectContext] deleteObject:current];
    [[[self appDelegate] managedObjectContext] save:nil];
    
}

-(NSInteger)maxAlbumId {
    NSInteger current = 0;
    NSArray *copy = [self albumList];
    if(copy.count == 0) return 0;
    for(int i = 0; i < copy.count-1; i++) {
        Album *first = copy[i];
        Album *second = copy[i+1];
        if([first.album_id integerValue] < [second.album_id integerValue] ) {
            current = [second.album_id integerValue];
        }
    }
    return ++current;
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
    if(album == -1) {
        return [CachedAudioLogic instance].controller.fetchedObjects.count;
    }
    int count = 0;
    for (CachedAudio *current in [CachedAudioLogic instance].controller.fetchedObjects) {
        if([current.album_id integerValue] == album) {
            count++;
        }
    }
    
    return count;
}

+(AlbumsLogic *)instance {
    static AlbumsLogic *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlbumsLogic alloc] init];
    });
    return instance;
}



-(void)setAlbum:(Audio *)audio albumId:(NSInteger)albumId {
    [[CachedAudioLogic instance] setAlbum:audio albumId:albumId];
}


-(void)updateAlbum:(NSInteger)album {
    [super updateAlbum:album];
    NSArray *current = [[CachedAudioLogic instance] list];
    self.fullList = [[NSMutableArray alloc] init];
    for (CachedAudio *audio in current) {
        if([audio.album_id integerValue] == self.album) {
            [self.fullList addObject:audio];
        }
    }
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
    
    album.album_id = [NSNumber numberWithInt:[self maxAlbumId]];
    
    [[[self appDelegate] managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
    
    return [album.album_id integerValue];
}

@end
