//
//  SettingObject.h
//  VkMusic
//
//  Created by keepcoder on 01.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingObject : NSObject
@property (nonatomic,strong) NSString *headerText;
@property (nonatomic,strong) NSString *cellText;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic, assign) BOOL isAccessory;
@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic, assign) BOOL isButton;
@property (nonatomic, assign) BOOL isEnabled;
-(id)initWithType:(NSInteger)type cellText:(NSString *)text isAccessory:(BOOL)accessory isButton:(BOOL)button isEnabled:(BOOL)enabled target:(id)target selector:(SEL)selector;
@end
