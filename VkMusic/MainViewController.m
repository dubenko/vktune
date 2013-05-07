//
//  FullListViewController.m
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "MainViewController.h"

#import "Audio.h"
#import "AppDelegate.h"

#import "AudioPlayerDelegate.h"
#import "AudioViewCell.h"
#import "CachedAudio.h"
#import "CachedAudioLogic.h"
#import "Consts.h"
#import <QuartzCore/QuartzCore.h>
#import "FullListTableView.h"
#import "SVPullToRefresh.h"
#import "UIImage+Extension.h"
#import "RecommendsAudio.h"
#import "TestFlight.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize player;
@synthesize playerView;
@synthesize fullList;
@synthesize menu;
@synthesize settings;
@synthesize controllers;
@synthesize albums;
@synthesize history;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor]; 
    history = [[NSMutableArray alloc] init];
    
    
    
    
    
    fullList = [[FullListTableView alloc] initWithFrame:self.view.frame andLogic:[[[CachedAudioLogic instance] list] count] > 0 ? [CachedAudioLogic instance] : [AudioLogic instance]];
    [history addObject:[NSNumber numberWithInt:[[[CachedAudioLogic instance] list] count] > 0 ? 1 :0]];
    
    controllers = [[NSMutableArray alloc] initWithObjects:[AudioLogic instance], [CachedAudioLogic instance], [RecommendsAudio instance], [AlbumsLogic instance], nil];
    for (BaseLogicController *def in controllers) {
        def.delegate = fullList;
    }
    
    self.player = [[AudioPlayer alloc] init];
    playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, -DEFAULT_CELL_SIZE, self.view.bounds.size.width,DEFAULT_CELL_SIZE)];
    
    fullList.playerView = playerView;

    UIImage *ai = [UIImage imageNamed:@"icon_settings.png"];
    UIButton *ab = [UIButton buttonWithType:UIButtonTypeCustom];
    ab.bounds = CGRectMake( 0, 0, 30, ai.size.height*2 );
    [ab setImage:ai forState:UIControlStateNormal];
    [ab addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsView = [[UIBarButtonItem alloc] initWithCustomView:ab];
    [self.navigationItem setLeftBarButtonItem:settingsView];
    
    
    UIImage *si = [UIImage imageNamed:@"shuffle"];
    UIButton *sb = [UIButton buttonWithType:UIButtonTypeCustom];
    sb.bounds = CGRectMake( 0, 0, 27, si.size.height*2 );
    [sb setImage:si forState:UIControlStateNormal];
    [sb addTarget:self action:@selector(shuffle:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shuffleView = [[UIBarButtonItem alloc] initWithCustomView:sb];
    [self.navigationItem setRightBarButtonItem:shuffleView];

    
     
     CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
    
     NSString *title = [[[CachedAudioLogic instance] list] count] > 0 ? NSLocalizedString(@"DOWNLOADS", nil) : NSLocalizedString(@"ALL", nil);
    
     menu = [[SINavigationMenuView alloc] initWithFrame:frame title:title];
     [menu displayMenuInView:self.view];
     menu.items = @[NSLocalizedString(@"ALL", nil), NSLocalizedString(@"DOWNLOADS", nil),NSLocalizedString(@"RECOMMENDS", nil),NSLocalizedString(@"ALBUMS", nil)];
     menu.delegate = self;
    
    
     
     self.navigationItem.titleView = menu;
    
    player.delegate = self;
    
    [self.view addSubview:fullList];
    [self.view addSubview:playerView];
    
     [playerView setPlayer:player];
     
     
     self.playerView.delegate = self;
     self.playerView.tableView = fullList;
    
    [self.fullList setMainController:self];
    
    
    __block MainViewController *strong = self;
    
    [self.fullList addPullToRefreshWithActionHandler:^{
        [[AudioLogic instance] firstRequest:strong selector:@selector(pulled)];
    }];
    
     
     fullList.playerView = playerView;
    
    
     [[AudioLogic instance] firstRequest:nil selector:nil];
}

-(void)playerDidPauseOrPlay:(NSNumber *)play {
    [playerView updatePlayIcon:[play boolValue]];
}

-(void)pulled {
     [fullList.pullToRefreshView stopAnimating];
}

-(void)toAlbums:(void (^)(NSInteger))handler {
    if(albums == nil) {
        albums = [[AlbumViewController alloc] initWithNibName:nil bundle:NULL];
    }
    [albums setMainController:self];
    albums.handler = handler;
    [albums.viewList reloadData];
    [albums setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:albums animated:YES completion:^{
       
    }];
    
}

-(void)back {
    for (int i = history.count-1; i >= 0; i--) {
         NSInteger last = [[history objectAtIndex:i] integerValue];
        if(![[controllers objectAtIndex:last] isKindOfClass:[AlbumsLogic class]]) {
            [self didSelectItemAtIndex:last];
            return;
        }
    }
}





- (void)didSelectItemAtIndex:(NSUInteger)index
{
    if([controllers objectAtIndex:index] == [AlbumsLogic instance] && albums && self.modalViewController == albums) {
        return;
    }
    
    [fullList clearSearch];
    
    if(albums && self.modalViewController == albums) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    [menu setTitle:[menu.items objectAtIndex:index]];
    
    fullList.logic = [controllers objectAtIndex:index];
    [fullList reloadTable];
    [fullList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
   
    if([fullList.logic isKindOfClass:[AlbumsLogic class]] ) {
        [self toAlbums:^(NSInteger album) {
            [menu setTitle:[[AlbumsLogic instance] findAlbumById:album].title];
            [fullList.logic updateAlbum:album];
        }];
    }
    
    [history addObject:[NSNumber numberWithInt:index]];
}

-(void)logout:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.settings == nil) {
            settings = [[SettingsController alloc] init];
        }
        [settings update];
        [self.navigationController pushViewController:settings animated:YES];
    });
    
}

-(void)shuffle:(id)sender {
    [fullList.logic shuffle];
}


-(void)playerDidPlayOrPause {
    if([player isPlay]) {
        [player pause];
    } else {
        [player play];
    }
}

-(void)playeDidStop {
    [fullList deselectRowAtIndexPath:[fullList indexPathForSelectedRow] animated:YES];
    [player stop];
    [playerView setCurrentAudio:nil];
}




-(AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)tableDidPlay:(Audio*)audio {
    if([player.audio.aid integerValue] == [audio.aid integerValue])  {
        if ([player isPlay]) {
            [player pause];
        } else {
            [player play];
        }
    } else {
        [self tryPlay:audio];
    }
}

-(void)tryPlay:(Audio *)current {
     [playerView setCurrentPlaying:current];
    [self.playerView showWithDuration:0.2 show:YES];
    Audio *cached = [[CachedAudioLogic instance] findAudio:[current.aid integerValue] ownerId:[current.owner_id integerValue]];
    if(cached == nil) {
        if([[UserLogic instance] autosave]) {
             [[SaveQueue instance] addAudioToQueue:current];
        }
        [[AudioLogic instance] loadUrlWithAudio:current target:self selector:@selector(audioForPlay:) waitTime:0.5];
    } else {
        NSString *path = [NSString stringWithFormat:@"%@/%d_%d.mp3", DOCUMENTS_FOLDER,[cached.owner_id integerValue] ,[cached.aid integerValue]];
        [self audioForPlay:[[NSURL alloc] initFileURLWithPath:path]];
    }
   
}



-(void)audioForPlay:(NSURL *)url {
    NSIndexPath *path = [fullList indexPathForSelectedRow];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.playerView setCurrentPlaying:[fullList findAudioByRow:path.row]];
        [self.playerView showWithDuration:0.2 show:YES];
    } completion:^(BOOL finished){
        [player playWithUrl:url audio:[fullList findAudioByRow:path.row]];
    }];
    
}


-(void)needPrevToPlay:(NSNumber *)physic {
   [fullList needPrevAudio:[physic boolValue]];
}


-(void)needAudioToPlay:(NSNumber *)physic {
    [fullList needNextAudio:[physic boolValue]];
}

-(void)didUpdateCurrentTime:(NSNumber *)currentTime duration:(NSNumber *)duration {
    [playerView updateCurrentTime:[currentTime floatValue] duration:[duration floatValue]];
}


-(void)stop {
    [fullList deselectRowAtIndexPath:[fullList indexPathForSelectedRow] animated:YES];
    [player stop];
    [playerView setCurrentAudio:nil];
    [self.playerView showWithDuration:0.1 show:NO];
}



@end
