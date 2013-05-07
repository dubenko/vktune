//
//  SettingsController.h
//  VkMusic
//
//  Created by keepcoder on 01.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingObject.h"
@interface SettingsController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *settingsTable;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) NSMutableArray *buttons;
@property (nonatomic,strong) NSMutableArray *footers;
@property (nonatomic,strong) SettingObject *broadcast;
@property (nonatomic,strong) SettingObject *autosave;
@property (nonatomic,strong) SettingObject *onlyWiFi;
-(void)update;
@end
