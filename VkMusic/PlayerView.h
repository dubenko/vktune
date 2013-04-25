//
//  PlayerView.h
//  VkMusic
//
//  Created by keepcoder on 24.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Audio.h"
#import "AudioPlayerViewDelegate.h"
#import "AudioPlayer.h"
#import "ImageElement.h"
@interface PlayerView : UIView
@property (nonatomic,strong) UIView *progress;
@property (nonatomic,strong) UIView *progressBackground;
@property (nonatomic,strong) ImageElement *playView;
@property (nonatomic,strong) ImageElement *repeatView;
@property (nonatomic,strong) UITextField *artistField;
@property (nonatomic,strong)UITextField *titleField;
@property (nonatomic,strong) Audio *currentAudio;
@property (nonatomic,strong) id <AudioPlayerViewDelegate> delegate;
@property (nonatomic,strong) UITextField *timeLeft;
@property (nonatomic,strong) UITextField *timeLost;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) AudioPlayer *player;
@property (nonatomic,assign) BOOL updateLocked;
-(void)setCurrentPlaying:(Audio *) audio;
-(void)showWithDuration:(float)duration show:(BOOL)show;
-(void)updateCurrentTime:(float)currentTime duration:(float)duration;
-(BOOL)isShowed;
-(void)stop;
-(void)setAndUpdateTableView:(UITableView *)table;
-(void)updatePlayIcon:(BOOL)play;
@end
