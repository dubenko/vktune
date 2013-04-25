//
//  AudioLogicDelegate.h
//  VkMusic
//
//  Created by keepcoder on 21.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AudioLogicDelegate <NSObject>

@optional
-(void)didChangeContent:(NSNumber *)animated;

-(void)didDeleteRowAtIndex:(NSNumber *)index;
@end
