//
//  WebAuthViewController.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebAuthViewController : UIViewController<UIWebViewDelegate>
@property(nonatomic,strong) UIWebView *webAuthView;
@property(nonatomic,strong) UIActivityIndicatorView* indicator;
@end
