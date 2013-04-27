//
//  AlbumViewController.h
//  VkMusic
//
//  Created by keepcoder on 12.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumsLogic.h"
#import "Album.h"
#import "AudioLogicDelegate.h"
@interface AlbumViewController : UIViewController<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,AudioLogicDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic,strong) IBOutlet UIToolbar *toolbar;

@property (nonatomic,strong) IBOutlet UITableView *viewList;
@property (nonatomic,strong) AlbumsLogic *logic;
@property (copy) void (^handler)(NSInteger);
-(void)setMainController:(UIViewController *)controller;
@end
