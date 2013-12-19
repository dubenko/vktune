//
//  FriendsViewController.h
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SINavigationMenuView.h"
#import "FriendsLogic.h"
#import "BaseViewList.h"
@interface FriendsViewController : UIViewController<IFriendsController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) SINavigationMenuView *menu;
@property (nonatomic,strong) UIToolbar *toolbar;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UISearchBar *search;
@property (copy) void (^handler)(Friend *friend);
-(void)setMainController:(UIViewController *)controller;
@end
