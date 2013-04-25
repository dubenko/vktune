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
@property (nonatomic,strong)NSMutableArray *searchList;
@property (nonatomic,strong) NSMutableArray *fullList;
-(BOOL)search:(NSString *)input fullList:(NSArray *)fullList;
@property (nonatomic,strong) NSTimer *searchTimer;
@property (nonatomic,strong) NSMutableArray *globalResult;
-(void)updateContent:(BOOL)animated;
-(void)updateFullList:(NSMutableArray *)newList;
-(BOOL)needGlobalLoad;
@end
