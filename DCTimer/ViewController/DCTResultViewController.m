//
//  DCTResultViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-19.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTResultViewController.h"
#import "DCTData.h"
#import "DCTAppDelegate.h"
#import "DCTDetailViewController.h"
#import "DCTStatsViewController.h"
#import "DCTSessionViewController.h"
#import "DCTUtils.h"

@interface DCTResultViewController ()
@property (nonatomic, strong) DCTDetailViewController *detailController;
@end

@implementation DCTResultViewController
@synthesize detailController;
BOOL newestTop;
int numberSolves;
extern NSInteger subTitle;
extern NSInteger dateForm;
extern int currentSesIdx;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = [DCTUtils getString:@"results"];
        self.tabBarItem.image = [UIImage imageNamed:@"img2"];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.title = [DCTUtils getString:@"results"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"session"] style:UIBarButtonItemStylePlain target:self action:@selector(selSessionView)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"stats"] style:UIBarButtonItemStylePlain target:self action:@selector(statsView)];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.detailController = nil;
    [[DCTData dbh] closeDB];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *name = [[DCTData dbh] getSessionName:currentSesIdx];
    if([name isEqualToString:@""])
        self.navigationItem.title = [DCTUtils getString:@"results"];
    else self.navigationItem.title = name;
}

- (void)viewDidAppear:(BOOL)animated
{
    numberSolves = [[DCTData dbh] numberOfSolves];
    [self.tableView reloadData];
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int bgcolor = (int)[defaults integerForKey:@"bgcolor"];
    int r = (bgcolor>>16)&0xff;
    int g = (bgcolor>>8)&0xff;
    int b = bgcolor&0xff;
    if([DCTUtils isOS7]) self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    else self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    newestTop = [defaults boolForKey:@"newtop"];
    subTitle = (int)[defaults integerForKey:@"subtitle"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([DCTUtils isPhone]) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (numberSolves = [[DCTData dbh] numberOfSolves]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    if(newestTop) row = numberSolves-1-row;
    cell.textLabel.text = [DCTData distimeAtIndex:(int)row dt:false];
    if(subTitle == 0) cell.detailTextLabel.text = [DCTUtils getDateFormat:[[DCTData dbh] getDateAtIndex:(int)row] ty:dateForm];
    else if(subTitle == 1) cell.detailTextLabel.text = [[DCTData dbh] getScrambleAtIndex:(int)row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    detailController = [[DCTDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailController.title = [DCTUtils getString:@"detail"];
    NSUInteger row = [indexPath row];
    if(row >= numberSolves) row = numberSolves-1;
    if(newestTop) row = numberSolves-1-row;
    NSString *selectedTime = [DCTData distimeAtIndex:(int)row dt:true];
    NSString *time = [NSString stringWithFormat:@"(%@)", [DCTUtils getDateFormat:[[DCTData dbh] getDateAtIndex:(int)row] ty:dateForm]];
    NSString *scr = [[DCTData dbh] getScrambleAtIndex:(int)row];
    detailController.rest = selectedTime;
    detailController.time = time;
    detailController.scramble = scr;
    [detailController setDetail:(int)row];
    detailController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        if(row >= numberSolves) row = numberSolves-1;
        if(newestTop) row = numberSolves-1-row;
        [[DCTData dbh] deleteTimeAtIndex:(int)row];
        [[DCTData dbh] deleteTime:(int)row];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

- (void)selSessionView {
    DCTSessionViewController *sesView = [[DCTSessionViewController alloc] initWithStyle:UITableViewStyleGrouped];
    sesView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sesView animated:YES];
    //[sesView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    //[self presentViewController:sesView animated:YES completion:NULL];
}

- (void)statsView {
    [self.navigationController pushViewController:[[DCTStatsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
}

@end
