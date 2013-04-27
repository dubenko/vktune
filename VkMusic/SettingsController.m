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
#import "AudioViewCell.h"
#import "Consts.h"
#import "UIImage+Extension.h"
#import "SIMenuConfiguration.h"
@interface SettingsController ()

@end

@implementation SettingsController
@synthesize data;
@synthesize footers;
@synthesize broadcast;
@synthesize autosave;
@synthesize onlyWiFi;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Настройки";
        
        broadcast = [[SettingObject alloc] initWithType:0 cellText:@"Трансляция" isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] vkBroadcast] target:self selector:@selector(broadcastHandler)];
       autosave = [[SettingObject alloc] initWithType:0 cellText:@"Автосохранение" isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] autosave] target:self selector:@selector(saveHandler)];
       onlyWiFi = [[SettingObject alloc] initWithType:0 cellText:@"Загрузка по Wi-Fi" isAccessory:YES isButton:NO isEnabled:[[UserLogic instance] onlyWifi] target:self selector:@selector(wifiHandler)];

        
        SettingObject *exit = [[SettingObject alloc] initWithType:0 cellText:@"Выход" isAccessory:NO isButton:YES isEnabled:YES target:self selector:@selector(logout:)];
        data = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:broadcast,autosave,onlyWiFi,exit, nil],nil];
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
    [[delegate returnOrCreateMainViewController] stop];
   [[delegate navigationController] setRootViewController:[delegate returnOrCreateAuthViewController]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    SettingObject *setting = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    AudioViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[AudioViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
        return [[self.data objectAtIndex:section] count]-1;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    SettingObject *set = [[data objectAtIndex:section] objectAtIndex:[self tableView:self.settingsTable numberOfRowsInSection:section]];
    UIView *view;
    if(set.isButton) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        view.backgroundColor = [UIColor clearColor];
        
        
        UIImage *img = [UIImage imageWithColor:[SIMenuConfiguration selectionColor] rect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 40)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD size:16];
        btn.frame = CGRectMake(0, 0, view.bounds.size.width-20, 43);
        [btn setTitle:set.cellText forState:UIControlStateNormal];
        [btn addTarget:set.target action:set.selector
      forControlEvents:UIControlEventTouchUpInside];
        btn.center = view.center;
        [view addSubview:btn];
    }
    
    
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 60.0f;
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
    bb.bounds = CGRectMake( 0, 0, bi.size.width*3, bi.size.height*2);
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
