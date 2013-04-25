//
//  AuthViewController.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AuthViewController.h"
#import "WebAuthViewController.h"
#import "UserLogic.h"
#import "QuartzCore/QuartzCore.h"
@interface AuthViewController ()

@end

@implementation AuthViewController
@synthesize authButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Музыка";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleDone target:nil action:nil];
    [item setBackButtonBackgroundImage:[UIImage imageNamed:@"Header_Button.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *bg = [UIImage imageNamed:@"Background.png"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:bg];
    
    
    
    

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     if([[UserLogic instance] logout]) {
     
     }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authClick:(id)sender {
    WebAuthViewController *webViewController = [[WebAuthViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}
@end
