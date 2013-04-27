//
//  ILogicController.h
//  VkMusic
//
//  Created by keepcoder on 31.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "AudioLogicDelegate.h"
@protocol ILogicController <NSObject>
@property (nonatomic,strong) id <AudioLogicDelegate> delegate;
@property (nonatomic,assign) NSInteger album;
-(NSIndexPath *)findRowIndex:(Audio*)rowAudio;
-(Audio *)findAudioByRow:(NSInteger)row;
-(NSArray *)list;
-(void)loadMore;
-(BOOL)search:(NSString *)input;
typedef void (^voidCallback)(void);
-(void)deleteAudio:(Audio*)audio callback:(voidCallback)callback;
@optional
-(void)setAlbum:(Audio *)audio albumId:(NSInteger)albumId;
-(void)updateAlbum:(NSInteger)album;
-(NSInteger)albumCount:(NSInteger)album;
-(void)shuffle;
-(void)updateAudioState:(Audio *)audio state:(AudioState)state;

@end
