//
//  AlbumsLogic.h
//  VkMusic
//
//  Created by keepcoder on 11.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseLogicController.h"
#import "Album.h"
#import "AudioLogicDelegate.h"
@interface AlbumsLogic : BaseLogicController
@property (nonatomic,strong)NSFetchedResultsController *controller;
-(NSArray *)albumList;
-(int)createAlbumWithName:(NSString *)name;
-(Album *)findAlbumByRow:(NSInteger)row;
-(Album *)findAlbumById:(NSInteger)albumId;
+(AlbumsLogic *)instance;
-(void)deleteAlbum:(NSInteger)index;
-(NSInteger)albumCount:(NSInteger)album;
@end
