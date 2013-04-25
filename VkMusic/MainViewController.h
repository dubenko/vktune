//
//  MainViewController.h
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTransformableTableViewCell.h"
#import "JTTableViewGestureRecognizer.h"
#import "AudioPlayer.h"
#import "PlayerView.h"
#import "AudioPlayerViewDelegate.h"
#import "AudioLogicDelegate.h"
#import "AudioLogic.h"
#import "SINavigationMenuView.h"
#import "FullListTableView.h"
#import "SettingsController.h"
#import "AlbumViewController.h"
@interface MainViewController : UIViewController<SINavigationMenuDelegate,AudioPlayerViewDelegate,AudioPlayerDelegate>
@property (nonatomic,strong) FullListTableView *fullList;
@property(nonatomic,strong) AudioPlayer *player;
@property (nonatomic,strong) PlayerView *playerView;
@property (nonatomic,strong) SINavigationMenuView *menu;
@property (nonatomic,strong) SettingsController *settings;
@property (nonatomic,strong) NSMutableArray *controllers;
@property (nonatomic,strong) AlbumViewController *albums;
@property (nonatomic,strong) NSMutableArray *history; 
-(void)tableDidPlay:(Audio*)audio;
-(void)tryPlay:(Audio *)current;
-(void)stop;
-(void)playerDidPlayOrPause;
-(void)toAlbums:(void (^)(NSInteger))handler;
-(void)back;
@end
