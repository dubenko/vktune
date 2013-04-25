//
//  NavigationViewController.h
//  VkMusic
//
//  Created by keepcoder on 20.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NavigationController : UINavigationController {
    UIViewController *fakeRootViewController;
}

@property(nonatomic, retain) UIViewController *fakeRootViewController;

-(void)setRootViewController:(UIViewController *)rootViewController;
@end
