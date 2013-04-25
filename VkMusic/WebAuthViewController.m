//
//  WebAuthViewController.m
//  VkMusic
//
//  Created by keepcoder on 19.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "WebAuthViewController.h"
#import "ApiURL.h"
#import "URLParser.h"
#import "AppDelegate.h"
@interface WebAuthViewController ()

@end

@implementation WebAuthViewController
@synthesize webAuthView;
@synthesize indicator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Авторизация";
    }
    return self;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)webViewDidStartLoad:(UIWebView *)webView {
    [indicator startAnimating];
}

-(void)loaded {
    [[[self appDelegate] navigationController] setRootViewController:[[self appDelegate] returnOrCreateMainViewController]];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [indicator stopAnimating];
    NSString *currentURL = [webView.request.URL absoluteString];
    [self.webAuthView removeFromSuperview];
    NSRange range = [currentURL rangeOfString:SUCCESS_URL];
    
    if(range.location != NSNotFound) {
        currentURL = [currentURL stringByReplacingCharactersInRange:range withString:@""];
        URLParser *parser = [[URLParser alloc] initWithURLString:currentURL];
        if([parser valueForVariable:@"error"] == nil) {
            [[UserLogic instance] createUserWithToken:[parser valueForVariable:@"access_token"] secret:[parser valueForVariable:@"secret"] uid:[[parser valueForVariable:@"user_id"] integerValue]];
            [[AudioLogic instance] firstRequest:self selector:@selector(loaded)];
        } else {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:AUTH_URL]];
            [self.webAuthView loadRequest:request];
        }
        
    } else {
        [self.view addSubview:webView];
    }
}


-(AppDelegate *) appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webAuthView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webAuthView.delegate = self;
    self.view.frame = self.view.bounds;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *barIndicator = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    [self.navigationItem setRightBarButtonItem:barIndicator];
    [indicator setColor:[UIColor grayColor]];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([[UserLogic instance] logout]) {
        
    }
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:AUTH_URL]];
    [self.webAuthView loadRequest:request];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [indicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
