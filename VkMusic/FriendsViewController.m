//
//  FriendsViewController.m
//  VkMusic
//
//  Created by keepcoder on 25.08.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "FriendsViewController.h"
#import "MainViewController.h"
#import "Consts.h"
#import "FriendCell.h"
#import "UIImage+Extension.h"
@interface FriendsViewController ()
@property (nonatomic,strong) MainViewController *controller;
@property (nonatomic,strong) NSArray *friendsList;
@end

@implementation FriendsViewController
@synthesize menu;
@synthesize toolbar;


-(void)setMainController:(UIViewController *)controller {
    self.controller = (MainViewController *)controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0f;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
    [self.view addSubview:self.tableView];
    

    
    
    UIView *searchContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 32)];
    searchContainer.backgroundColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];

    
    self.search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, (searchContainer.frame.size.height-30)/2, self.tableView.frame.size.width, 30)];
    self.search.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
 //   self.search.delegate = self;
    [self.search setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] rect:CGRectMake(0, 0, 1, 26)]  forState:UIControlStateNormal];
    [self.search setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(-4, 0)];
    UITextField *field = [self.search valueForKey:@"_searchField"];
    self.search.delegate = self;
    [field setNeedsLayout];
    field.layer.cornerRadius = 4;
    field.layer.borderColor = [UIColor clearColor].CGColor;
    [field setTextColor:[UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha:1]];
    [field setFont:[UIFont fontWithName:FONT_BOLD size:13]];
    [field setBorderStyle:UITextBorderStyleNone];

    
    [searchContainer addSubview:self.search];
    [self.tableView setTableHeaderView:searchContainer];
    [self.tableView scrollRectToVisible:CGRectMake(0, 30, self.tableView.frame.size.width, self.tableView.frame.size.height) animated:NO];
    
    self.friendsList = [FriendsLogic instance].friendList;
    [self.tableView reloadData];
    menu = [[SINavigationMenuView alloc] initWithFrame:CGRectMake(-10, 0, 200, self.navigationController.view.frame.size.height) title:NSLocalizedString(@"FRIENDS", nil)];
    [menu displayMenuInView:self.view];
    menu.tableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    menu.items = @[NSLocalizedString(@"ALL", nil), NSLocalizedString(@"DOWNLOADS", nil),NSLocalizedString(@"RECOMMENDS", nil),NSLocalizedString(@"ALBUMS", nil),NSLocalizedString(@"FRIENDS", nil)];
    
    if([Consts access] == NO) {
        menu.items = @[NSLocalizedString(@"ALL", nil),NSLocalizedString(@"RECOMMENDS", nil),NSLocalizedString(@"ALBUMS", nil),NSLocalizedString(@"FRIENDS", nil)];
    }
    
    
    menu.delegate = self.controller;

    [FriendsLogic instance].friendsDelegate = self;
    self.navigationItem.titleView = menu;  
}

-(void)friendsDidLoad:(NSArray *)friends {
    self.friendsList = friends;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[FriendsLogic instance] initFriends];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //[self clearSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Friend *friend = [self.friendsList objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    return cell;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([[self search] isFirstResponder])
        [self.search resignFirstResponder];
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if([[self search] isFirstResponder]) {
        [self.search resignFirstResponder];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)clearSearch {
    self.search.text = @"";
    if([[self search] isFirstResponder]) {
        [self.search resignFirstResponder];
    }
}


-(void)handleKeyboardWillShow:(NSNotification *) notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0, 0, 0, 0);
    
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    [UIView beginAnimations:@"changeTableViewContentInset" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect intersectionOfkeyboardRectAndWindowRect = CGRectIntersection(window.frame, keyboardEndRect);
    
    CGFloat bottomInset = intersectionOfkeyboardRectAndWindowRect.size.height;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0 , 0, bottomInset, 0.0f);
    
    [UIView commitAnimations];
    
}



-(void)handleKeyboardWillHide:(NSNotification *) notification {
    if(UIEdgeInsetsEqualToEdgeInsets(self.tableView.contentInset, UIEdgeInsetsZero)) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndRectObject = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0, 0, 0, 0);
    
    [animationCurveObject getValue:&animationCurve];
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    [self.tableView convertRect:keyboardEndRect fromView:self.tableView];
    
    [UIView beginAnimations:@"changeTableViewContentInset" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [UIView commitAnimations];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
      // [self.tableView reloadWithAnimation:UITableViewRowAnimationFade];
    [[FriendsLogic instance] searchFriends:searchText];
      // [self.tableView reloadData];
   // }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.search resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self.search resignFirstResponder];
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _handler([self.friendsList objectAtIndex:indexPath.row]);
    
  //  [[FriendsLogic instance] loadFriendAudio:;
    
}

@end
