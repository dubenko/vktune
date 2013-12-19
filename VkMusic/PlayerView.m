//
//  PlayerView.m
//  VkMusic
//
//  Created by keepcoder on 24.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "PlayerView.h"
#import "SVPullToRefresh.h"
#import "SIMenuConfiguration.h"
#import "Consts.h"
#import "UserLogic.h"
#import "CryptoUtils.h"
@implementation PlayerView
@synthesize progress;
@synthesize progressBackground;
@synthesize artistField;
@synthesize titleField;
@synthesize currentAudio;
@synthesize delegate;
@synthesize tableView;
@synthesize timeLeft;
@synthesize player;
@synthesize updateLocked;
@synthesize playView;
@synthesize repeatView;
@synthesize timeLost;
- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        
        updateLocked = NO;
        
        
        
        playView = [[ImageElement alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_CELL_SIZE, DEFAULT_CELL_SIZE) leftOrRight:1 image:@"pause"];
        [playView setBackgroundColor:[SIMenuConfiguration playColor]]; //[UIColor colorWithRed:0.4 green:0.6 blue:0.6 alpha:1] // 87 153 169
        [playView setBorderColor:[UIColor clearColor]];
        
        
        repeatView = [[ImageElement alloc] initWithFrame:CGRectMake(self.frame.size.width-DEFAULT_CELL_SIZE, 0, DEFAULT_CELL_SIZE, DEFAULT_CELL_SIZE) leftOrRight:0 image:[[[UserLogic instance] currentUser] boolForKey:@"repeat"] ? @"repeat_small_selected" : @"repeat_small"];
        [self repeatTap:nil];
        [repeatView setBackgroundColor:[UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1]]; // 90 154 168
        
        
        UITapGestureRecognizer *repeatTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(repeatTap:)];
        [repeatView addGestureRecognizer:repeatTap];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                action:@selector(handleSingleTap:)];
        [playView addGestureRecognizer:singleFingerTap];
        
        progressBackground = [[UIView alloc] initWithFrame:CGRectMake(60, 0, self.frame.size.width-playView.frame.size.width-repeatView.frame.size.width, self.frame.size.height)];
        progressBackground.backgroundColor = [UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
        
        progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, progressBackground.frame.size.height)];
        progress.backgroundColor = [UIColor colorWithRed:(28.0/255.0) green:(74.0/255.0) blue:(99.0/255.0) alpha:1]; //63 95 102
        [progressBackground addSubview:progress];
        
        [self addSubview:progressBackground];
        [self addSubview:playView];
        [self addSubview:repeatView];
        
        
        
        [self setBackgroundColor:[UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1]]; 
        
        
        self.timeLeft = [[UITextField alloc] initWithFrame:CGRectMake(progressBackground.frame.size.width-65, progressBackground.frame.size.height-18, 60, 17)];
        [self.timeLeft setFont:[UIFont fontWithName:FONT_BOLD size:10]];
        [self.timeLeft setUserInteractionEnabled:NO];
        self.timeLeft.backgroundColor = [UIColor clearColor];
        self.timeLeft.textColor = [UIColor whiteColor];
        timeLeft.textAlignment = NSTextAlignmentRight;
        
        
        self.timeLost = [[UITextField alloc] initWithFrame:CGRectMake(7, progressBackground.frame.size.height-16, 60, 17)];
        [self.timeLost setFont:[UIFont fontWithName:FONT_BOLD size:10]];
        [self.timeLost setUserInteractionEnabled:NO];
        self.timeLost.backgroundColor = [UIColor clearColor];
        self.timeLost.textColor = [UIColor whiteColor];
        timeLost.textAlignment = NSTextAlignmentLeft;
        
        [progressBackground addSubview:timeLeft];
        [progressBackground addSubview:timeLost];
        
        
        self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, progressBackground.frame.size.width-30, 30)];
        self.artistField = [[UITextField alloc] initWithFrame:CGRectMake(15, 25, progressBackground.frame.size.width-30, 20)];
       
        [self.artistField setFont:[UIFont fontWithName:FONT_REGULAR size:12]];
        [self.titleField setFont:[UIFont fontWithName:FONT_BOLD size:15]];
        
        [self.artistField setUserInteractionEnabled:NO];
        [self.titleField setUserInteractionEnabled:NO];
       

        titleField.textAlignment = NSTextAlignmentCenter;
        artistField.textAlignment = NSTextAlignmentCenter;
        
        
        self.titleField.backgroundColor = [UIColor clearColor];
        self.artistField.backgroundColor = [UIColor clearColor];
        
        self.artistField.textColor = [UIColor whiteColor];
        self.titleField.textColor = [UIColor whiteColor];
        
        
        [progressBackground addSubview:titleField];
        [progressBackground addSubview:artistField];
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapRecogizner:)];
        longPress.minimumPressDuration = 0.1f;
        [progressBackground addGestureRecognizer:longPress];
        
        UISwipeGestureRecognizer* swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpFrom:)];
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        
        UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        
        UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        
        
        [self addGestureRecognizer:swipeUpGestureRecognizer];
        [self addGestureRecognizer:swipeRight];
        [self addGestureRecognizer:swipeLeft];
        
    }
    return self;
}




-(void)handleSingleTap:(UISwipeGestureRecognizer *)touch {
    if(touch.state == UIGestureRecognizerStateEnded) {
        if([delegate respondsToSelector:@selector(playerDidPlayOrPause)]) {
            [delegate performSelector:@selector(playerDidPlayOrPause)];
        }
    }
}

-(void)repeatTap:(UISwipeGestureRecognizer *)touch {
    if(touch.state == UIGestureRecognizerStateEnded) {
        BOOL needRepeat = [[[UserLogic instance] currentUser] boolForKey:@"repeat"];
        [repeatView replaceImage:needRepeat ? [UIImage imageNamed:@"repeat_small"]  : [UIImage imageNamed:@"repeat_small_selected"]];
            [[[UserLogic instance] currentUser] setBool:!needRepeat forKey:@"repeat"];
            [[[UserLogic instance] currentUser] synchronize];
    }
}


-(void)handleSwipeRight:(UISwipeGestureRecognizer *)swipe {
    if([delegate respondsToSelector:@selector(needAudioToPlay:)]) {
        [delegate performSelector:@selector(needAudioToPlay:) withObject:[NSNumber numberWithBool:YES]];
    }
}


-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipe {
    if([delegate respondsToSelector:@selector(needPrevToPlay:)]) {
        [delegate performSelector:@selector(needPrevToPlay:) withObject:[NSNumber numberWithBool:YES]];
    }
}

-(void)handleSwipeUpFrom:(UISwipeGestureRecognizer *)swipe {
    [self showWithDuration:0.2 show:NO];
    if([delegate respondsToSelector:@selector(playeDidStop)]) {
        [delegate performSelector:@selector(playeDidStop)];
    }
}

-(void)stop {
    [self handleSwipeUpFrom:nil];
}

-(void)longTapRecogizner:(UILongPressGestureRecognizer *)press {
    CGPoint point = [press locationOfTouch:0 inView:progressBackground];
    updateLocked = YES;
    float width = point.x > 0 ? (point.x < progressBackground.frame.size.width ? point.x : progressBackground.frame.size.width ) : 0;
    progress.frame = CGRectMake(0, 0, point.x > 0 ? point.x : width , progress.frame.size.height);
    [self updateTimerField: [currentAudio.duration integerValue]-(point.x/progressBackground.frame.size.width*[currentAudio.duration integerValue]) field:timeLeft prefix:@"-"];
    [self updateTimerField: (point.x/progressBackground.frame.size.width*[currentAudio.duration integerValue]) field:timeLost prefix:@""];
    if(press.state == UIGestureRecognizerStateEnded) {
        updateLocked = NO;//currentTime*CMTimeGetSeconds([[player currentItem]duration])-1
        [player seekTo: (point.x/progressBackground.frame.size.width)*CMTimeGetSeconds([[[player player] currentItem]duration])];
    }
    
}

-(void)updateCurrentTime:(float)currentTime duration:(float)duration {
    
    if(updateLocked) return;
    
    [UIView beginAnimations:@"currentTime" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    
     progress.frame = CGRectMake(0, 0, (currentTime/duration)*progressBackground.frame.size.width, progressBackground.frame.size.height);
    
    [self updateTimerField:(int)(duration-currentTime) field:timeLeft prefix:@"-"];
    [self updateTimerField:(int)currentTime field:timeLost prefix:@""];
    [UIView commitAnimations];
    
}

-(void)setAndUpdateTableView:(UITableView *)table {
    self.tableView = table;
    if([self isShowed]) {
        [self showWithDuration:0.2f show:YES];
    }
}

-(void)updateTimerField:(int)duration field:(UITextField *)field prefix:(NSString *)prefix {
    duration = duration >= 0 ? duration : 0;
    int seconds = duration % 60;
    int minutes = duration/60 % 60;
    int hour = duration/60/60 % 60;
    NSString *sec = [NSString stringWithFormat:@"%@",seconds < 10 ? [NSString stringWithFormat:@"%d%d",0,seconds] : [NSString stringWithFormat:@"%d",seconds]];
    NSString *min = [NSString stringWithFormat:@"%@",minutes < 10 ? [NSString stringWithFormat:@"%d%d",0,minutes] : [NSString stringWithFormat:@"%d",minutes]];
    if(hour > 0) {
        field.text = [NSString stringWithFormat:@"%@%d:%@:%@",prefix,hour,min,sec];
    } else {
        field.text = [NSString stringWithFormat:@"%@%@:%@",prefix,min,sec];
    }
}


-(BOOL)isShowed {
    return  self.frame.origin.y == 0;
}


-(void)setCurrentPlaying:(Audio *)audio {
    self.currentAudio = audio;
    [[AVAudioSession sharedInstance]  setCategory:AVAudioSessionCategoryPlayback error:nil];
    [UIView animateWithDuration:0.2 animations:^{
        progress.frame = CGRectMake(0, 0, 0, progress.frame.size.height);
    }];
    
    self.artistField.text = [CryptoUtils textToHtml:audio.artist];
    self.titleField.text = [CryptoUtils textToHtml:audio.title];
    
    [self updateTimerField:[audio.duration integerValue] field:timeLeft prefix:@"-"];
    [self updateTimerField:0 field:timeLost prefix:@""];
}

-(void)updatePlayIcon:(BOOL)play {
    [playView replaceImage:play ? [UIImage imageNamed:@"pause"] : [UIImage imageNamed:@"play"]];
    
}

-(void)showWithDuration:(float)duration show:(BOOL)show{
    if(show) {
          [[AVAudioSession sharedInstance]  setCategory:AVAudioSessionCategoryPlayback error:nil];
    } else {
     //    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    }
    
    [UIView beginAnimations:@"showPlayer" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    self.frame = CGRectMake(0, !show ? -self.frame.size.height : 0, 320, 60);
    tableView.contentInset = UIEdgeInsetsMake(show ? self.frame.size.height: 0, 0, 0, 0);
    tableView.scrollIndicatorInsets = UIEdgeInsetsMake(show ? self.frame.size.height: 0, 0, 0, 0);
    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];
    
    /*
     self.frame = CGRectMake(0, !show ? self.superview.frame.size.height : (self.superview.frame.size.height-60), 320, 60);
     tableView.contentInset = UIEdgeInsetsMake(0, 0, show ? self.frame.size.height : 0, 0);
     tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, show ? self.frame.size.height: 0, 0);
     [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];
     */
    [tableView updateTopInset];
    [UIView commitAnimations];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
