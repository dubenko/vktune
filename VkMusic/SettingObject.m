//
//  SettingObject.m
//  VkMusic
//
//  Created by keepcoder on 01.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SettingObject.h"
#import "SIMenuConfiguration.h"
@implementation SettingObject
@synthesize isAccessory;
@synthesize isButton;
@synthesize headerText;
@synthesize cellText;
@synthesize selector = _selector;
@synthesize target = _target;
@synthesize color;
-(id) initWithType:(NSInteger)type cellText:(NSString *)text isAccessory:(BOOL)accessory isButton:(BOOL)button isEnabled:(BOOL)enabled target:(id)target selector:(SEL)selector {
    if(self =[super init]) {
        self.cellText = text;
        self.isAccessory = accessory;
        self.isButton = button;
        self.isEnabled = enabled;
        self.target = target;
        self.selector = selector;
        color = [SIMenuConfiguration selectionColor];
    }
    
    return self;
}
@end
