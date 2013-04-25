//
//  FullListTableView.m
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "FullListTableView.h"
#import "AudioViewCell.h"
#import "MainViewController.h"
#import "Consts.h"
#import "CachedAudio.h"
#import "SIMenuConfiguration.h"
#import "QuartzCore/QuartzCore.h"
#import "UIColor+Extension.h"
#import "SVPullToRefresh.h"
#import "CachedAudioLogic.h"
#import "CryptoUtils.h"
#import "MBHUDView.h"
#import "UIImage+Extension.h"
#import "UserLogic.h"
@interface FullListTableView ()
@property (nonatomic, strong) MainViewController *controller;
@end

@implementation FullListTableView
@synthesize logic;
@synthesize tableViewRecognizer;
@synthesize controller;
@synthesize playerView;
@synthesize search;
@synthesize searchResult;

- (id)initWithFrame:(CGRect)frame andLogic:(id<ILogicController>)logicController
{
    self = [super initWithFrame:frame];
    if (self) {
        
        searchResult = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.backgroundColor = [UIColor clearColor];
        
        
        UIView *searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 32)];
        searchContainer.backgroundColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
        
        search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, (searchContainer.frame.size.height-30)/2, self.frame.size.width, 30)];
        search.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
        search.delegate = self;
        [search setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] rect:CGRectMake(0, 0, 1, 26)]  forState:UIControlStateNormal];
        [search setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(-4, 0)];
        UITextField *field = [search valueForKey:@"_searchField"];
        [field setNeedsLayout];
        field.layer.cornerRadius = 4;
        field.layer.borderColor = [UIColor clearColor].CGColor;
        [field setTextColor:[UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha:1]];
        [field setFont:[UIFont fontWithName:FONT_BOLD size:13]];
        [field setBorderStyle:UITextBorderStyleNone];

        
       
        self.logic = logicController;
        self.logic.delegate = self;
        self.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
        self.separatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
        self.rowHeight       = DEFAULT_CELL_SIZE;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.dataSource = self;
        self.delegate = self;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //seconds
        [self addGestureRecognizer:lpgr];
        
        [searchContainer addSubview:search];
        [self setTableHeaderView:searchContainer];
        [self scrollRectToVisible:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height) animated:NO];
        
        
    }
    return self;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self];
        NSIndexPath *indexPath = [self indexPathForRowAtPoint:p];
        Audio *audio =[logic findAudioByRow:indexPath.row];
        if(audio.state == AUDIO_SAVED || [audio isKindOfClass:[CachedAudio class]]) {
            [controller toAlbums:^(NSInteger album) {
                Audio *linkForAlbum = [logic findAudioByRow:indexPath.row];
                [logic setAlbum:linkForAlbum albumId:album];
            }];
        }
    }
   
}


-(void)didDeleteRowAtIndex:(NSNumber *)index {
  //  [MBHUDView hudWithBody:@"Ошибка, попробуй еще." type:MBAlertViewHUDTypeExclamationMark hidesAfter:2.0 show:YES];
}


-(void)reloadTable {
    [self reloadWithAnimation:UITableViewRowAnimationFade];
}


-(void)reloadWithAnimation:(UITableViewRowAnimation)animation {
    [self beginUpdates];
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
    [self endUpdates];
    
    NSIndexPath *select = [logic findRowIndex:[playerView currentAudio]];
    if(select.row != -1) {
        [self selectRowAtIndexPath:[logic findRowIndex:[playerView currentAudio]] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


-(void)setMainController:(UIViewController *)_controller {
    self.controller = (MainViewController *)_controller;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[logic list] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(Audio *)findAudioByRow:(NSInteger)row {
    return [logic findAudioByRow:row];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Audio *audio = [logic findAudioByRow:indexPath.row];
    static NSString *cellIdentifier = @"AudioCell";
    AudioViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AudioViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [cell setState:audio.state];
    
    
    cell.textLabel.text = [CryptoUtils textToHtml:audio.title];
    cell.detailTextLabel.text = [CryptoUtils textToHtml:audio.artist];
    
    return cell;
}



-(void)didChangeContent:(NSNumber *)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(![animated boolValue]) {
            [self reloadData];
        } else {
            [self reloadTable];
        }
        
        NSIndexPath *select = [logic findRowIndex:[playerView currentAudio]];
        if(select.row != -1) {
            [self selectRowAtIndexPath:[logic findRowIndex:[playerView currentAudio]] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    });
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == ([[logic list] count]-15)) {
        if([logic isKindOfClass:[AudioLogic class]]) {
            [logic loadMore];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [logic isKindOfClass:[CachedAudioLogic class]];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Audio *current = [logic findAudioByRow:indexPath.row];
  
    [logic deleteAudio:current callback:^{
        NSIndexPath *position = [NSIndexPath indexPathForRow:[logic findRowIndex:current].row-1 inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            if([playerView isShowed] && [[playerView currentAudio].aid integerValue] == [current.aid integerValue]) {
                if([[playerView player] isPlay] && [logic list].count > 1) {
                    [self prevOrNext:1 position:position needRepeat:NO];
                } else {
                    [playerView stop];
                }
            }
                
        });
        
    }];
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reloadTable];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [controller tableDidPlay:[logic findAudioByRow:indexPath.row]];
}

-(void)needNextAudio {
    [self prevOrNextPath:1];
}

-(void)prevOrNextPath:(NSInteger)next {
    if([logic list].count == 0 ) {
        [playerView stop];
         return;
    }
    NSIndexPath *path = [logic findRowIndex:[playerView currentAudio]];
    [self prevOrNext:next position:path needRepeat:YES];
    

}

-(void)prevOrNext:(NSInteger)next position:(NSIndexPath *)position needRepeat:(BOOL)needRepeat {
    if(needRepeat) {
        if([[[UserLogic instance] currentUser] boolForKey:@"repeat"]) {
            next = 0;
        }
    }
    NSInteger forCheck = next == -1 ? 0 : [[logic list] count]-1;
    NSInteger reset = next == -1 ? [[logic list] count]-1 : 0;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:(position.row == forCheck) ? reset : (position.row+next ) inSection:position.section];
    [self scrollToRowAtIndexPath:newPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [controller tryPlay:[logic findAudioByRow:newPath.row]];
}

-(void)needPrevAudio {
    NSInteger next = CMTimeGetSeconds([[[self.playerView player] player] currentTime]) > 10 ? 0 : -1;
    [self prevOrNextPath:next];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([[self search] isFirstResponder]) 
        [self.search resignFirstResponder];
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if([[self search] isFirstResponder]) {
        [self.search resignFirstResponder];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}


-(void)handleKeyboardWillShow:(NSNotification *) notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0, 0, 0, 0);
    
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    [UIView beginAnimations:@"changeTableViewContentInset" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect intersectionOfkeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardEndRect);
    
    CGFloat bottomInset = intersectionOfkeyboardRectAndWindowRect.size.height;
    
    self.contentInset = UIEdgeInsetsMake([self.playerView isShowed] ? self.playerView.frame.size.height :0 , 0, bottomInset, 0.0f);
    
    [UIView commitAnimations];
    
}



-(void)handleKeyboardWillHide:(NSNotification *) notification {
    if(UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero)) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndRectObject = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0, 0, 0, 0);
    
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    [self convertRect:keyboardEndRect fromView:self];
    
    [UIView beginAnimations:@"changeTableViewContentInset" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.contentInset =  UIEdgeInsetsMake([self.playerView isShowed] ? self.playerView.frame.size.height :0 , 0, 0, 0.0f);
    [UIView commitAnimations];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([logic search:searchText])
        [self reloadWithAnimation:UITableViewRowAnimationFade];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.search resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self.search resignFirstResponder];
}

@end
