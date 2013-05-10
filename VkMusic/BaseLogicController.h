//
//  BaseLogicController.h
//  VkMusic
//
//  Created by keepcoder on 04.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILogicController.h"
@interface BaseLogicController : NSObject<ILogicController> {
    NSString * q;
}
@property (nonatomic) BOOL fullLoaded;
@property (nonatomic,assign) BOOL global;
@property (nonatomic,assign) BOOL shuffled;
@property (nonatomic,strong) NSString *loadMethod;
@property (nonatomic,strong)NSMutableArray *searchList;
@property (nonatomic,strong)NSMutableDictionary *audioMap;
@property (nonatomic,strong) NSMutableArray *fullList;
-(BOOL)search:(NSString *)input fullList:(NSArray *)fullList;
@property (nonatomic,strong) NSTimer *searchTimer;
@property (nonatomic,strong) NSMutableArray *globalResult;
-(void)updateContent:(BOOL)animated;
-(void)updateFullList:(NSMutableArray *)newList;
-(BOOL)needGlobalLoad;
-(void)deleteFromSearch:(Audio *)audio;
-(void)updateAudioMap;
-(Audio *)findAudio:(NSInteger)aid ownerId:(NSInteger)owner_id;

@end
