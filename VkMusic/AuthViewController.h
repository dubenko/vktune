//
//  AuthViewController.h
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController
- (IBAction)authClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *authButton;

@end
