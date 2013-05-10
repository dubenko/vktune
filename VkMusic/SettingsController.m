//
//  SettingsController.m
//  VkMusic
//
//  Created by keepcoder on 01.04.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "SettingsController.h"

#import "AppDelegate.h"
#import "APIData.h"
#import "APIRequest.h"
#import "ApiURL.h"
#import "BaseViewCell.h"
#import "Consts.h"
#import "UIImage+Extension.h"
#import "UIButton+Extension.h"
#import "SIMenuConfiguration.h"
@interface SettingsController ()

@end

@implementation SettingsController
@synthesize data;
@synthesize footers;
@synthesize broadcast;
@synthesize autosave;
@synthesize onlyWiFi;
@synthesize buttons;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS", nil);
        
        broadcast = [[SettingObject alloc] initWithType:0 cellText:NSLocalizedString(@"SETTINGS_BROADCAST", nil) isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] vkBroadcast] target:self selector:@selector(broadcastHandler)];
       autosave = [[SettingObject alloc] initWithType:0 cellText:NSLocalizedString(@"SETTINGS_AUTOSAVE", nil) isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] autosave] target:self selector:@selector(saveHandler)];
       onlyWiFi = [[SettingObject alloc] initWithType:0 cellText:NSLocalizedString(@"SETTINGS_WIFI", nil) isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] onlyWifi] target:self selector:@selector(wifiHandler)];

        
        SettingObject *exit = [[SettingObject alloc] initWithType:0 cellText:NSLocalizedString(@"SETTINGS_LOGOUT", nil) isAccessory:NO isButton:YES isEnabled:YES target:self selector:@selector(logout:)];
        exit.color = [SIMenuConfiguration redColor];
        SettingObject *author = [[SettingObject alloc] initWithType:0 cellText:NSLocalizedString(@"SETTINGS_ABOUT", nil) isAccessory:NO isButton:YES isEnabled:YES target:self selector:@selector(about:)];
        
        buttons = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:author,exit, nil],nil];
        data = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:broadcast,autosave,onlyWiFi, nil],nil];
    }
    return self;
}

-(void)update {
    broadcast.isEnabled = [[UserLogic instance] vkBroadcast];
    autosave.isEnabled = [[UserLogic instance] autosave];
    onlyWiFi.isEnabled = [[UserLogic instance] onlyWifi];
    [[[UserLogic instance] currentUser] synchronize];
    [self.settingsTable reloadData];
}

-(void)wifiHandler {
    [[[UserLogic instance] currentUser] setBool:![[UserLogic instance] onlyWifi] forKey:@"wifi"];
    [self update];
}

-(void)saveHandler {
    [[[UserLogic instance] currentUser] setBool:![[UserLogic instance] autosave] forKey:@"autosave"];
    [self update];
}

-(void)about:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vk.com/id19139981"]];
}


-(void)broadcastHandler {
    APIData *apiData = [[APIData alloc] initWithMethod:AUDIO_SET_BROADCAST user:[[UserLogic instance] currentUser] queue:nil params:[[NSMutableDictionary alloc] initWithObjectsAndKeys: broadcast.isEnabled ? @"0" : @"1",@"enabled", nil]];
    [APIRequest executeRequestWithData:apiData block:^(NSURLResponse *response, NSData *_data, NSError *error) {
        if(error == nil) {
            NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableLeaves error:&error];
            BOOL current = [[[json valueForKey:@"response"] valueForKey:@"enabled"] boolValue];
            [[[UserLogic instance] currentUser] setBool:current forKey:@"vkbroadcast"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self update];
            });
        }
        
    }];
}

-(void)logout:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate logout];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    SettingObject *setting = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    BaseViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[BaseViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        ImageElement *element = [[ImageElement alloc] initWithFrame:CGRectMake(0, 0, 40, 40) leftOrRight:0 image:@"success_default"];
        [element setBackgroundColor:[SIMenuConfiguration selectionColor]];
        [element setBorderColor:[UIColor clearColor]];
       cell.accessoryView = element;
    }
    
    ImageElement *accessory = (ImageElement *)cell.accessoryView;
    if(!setting.isEnabled) {
        [accessory replaceImage:[UIImage imageWithColor:[UIColor whiteColor] rect:CGRectMake(0, 0, 38, 38)]];
    } else {
        [accessory replaceImage:[UIImage imageNamed:@"success_default"]];
    }
    cell.textLabel.text = setting.cellText;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [accessory addTarget:setting.target selector:setting.selector];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.data count] > section) {
        return [[self.data objectAtIndex:section] count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
     UIView *view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 53*[[buttons objectAtIndex:section] count])];
    view.backgroundColor = [UIColor clearColor];
    for (int i = 0; i < [[buttons objectAtIndex:section] count]; i++) {
        SettingObject *set = [[buttons objectAtIndex:section] objectAtIndex:i];
        if(set.isButton) {
            UIImage *img = [UIImage imageWithColor:set.color rect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 40)];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setBackgroundImage:img forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD size:16];
            btn.frame = CGRectMake( 10, i*53+5, view.bounds.size.width-20, 43);
            [btn setTitle:set.cellText forState:UIControlStateNormal];
            [btn addTarget:set.target action:set.selector
           forControlEvents:UIControlEventTouchUpInside];
           // btn.center = view.center;
            [view addSubview:btn];
        }
 
    }
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 53*[[buttons objectAtIndex:section] count];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settingsTable.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    self.settingsTable.separatorColor = [UIColor colorWithRed:0.913 green:0.913 blue:0.913 alpha:1];
    self.settingsTable.rowHeight = DEFAULT_CELL_SIZE;
    self.settingsTable.dataSource = self;
    self.settingsTable.delegate = self;
    // Do any additional setup after loading the view from its nib.
    UIImage *bi = [UIImage imageNamed:@"arrow_white_back"];
    UIButton *bb = [UIButton buttonWithType:UIButtonTypeCustom];
    [bb setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
    bb.bounds = CGRectMake( 0, 0, bi.size.width*2, bi.size.height);
    [bb setImage:bi forState:UIControlStateNormal];
    [bb addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backView = [[UIBarButtonItem alloc] initWithCustomView:bb];
    self.navigationItem.leftBarButtonItem = backView;

}

-(void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
