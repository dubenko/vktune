//
//  BaseViewList.h
//  VkMusic
//
//  Created by keepcoder on 08.05.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewList : UITableView
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) NSIndexPath *editingPath;
-(BOOL)needShowDeleteForIndexPath:(NSIndexPath *)path;

@end
