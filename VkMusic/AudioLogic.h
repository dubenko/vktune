//
//  SoundLogic.h
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Audio.h"
#import "AudioLogicDelegate.h"
#import "BaseLogicController.h"
@interface AudioLogic : BaseLogicController
@property (nonatomic) NSInteger lastId;
@property (nonatomic) BOOL fullLoaded;
@property (nonatomic) BOOL firstInit;
@property (nonatomic,strong) NSOperationQueue *requestQueue;
@property (nonatomic,strong) NSMutableArray *queue;
@property (nonatomic,strong) NSFetchRequest *fetchRequest;
-(Audio *)createNewAudio:(BOOL)save aid:(NSInteger)aid ownerId:(NSInteger)ownerId artist:(NSString *)artist title:(NSString *)title duration:(NSInteger)duration;
-(void)clear;
-(void)setBroadcast:(Audio *)audio;
-(Audio *)findAudio:(NSInteger)aid ownerId:(NSInteger)owner_id;
-(void)loadUrlWithAudio:(Audio *)audio target:(id) target selector:(SEL)selector queue:(NSMutableArray *)queue;
-(void)loadUrlWithAudio:(Audio *)audio target:(id) target selector:(SEL)selector;
-(void)firstRequest:(id)target selector:(SEL)selector;
+(AudioLogic*) instance;
-(void)updateView;
@end
