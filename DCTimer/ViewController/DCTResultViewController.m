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
@property (nonatomic, strong) DCTData *mi;
@property (nonatomic, strong) DCTDetailViewController *detailController;
@end

@implementation DCTResultViewController
@synthesize listData;
@synthesize mi = _mi;
@synthesize detailController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"results", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"img2"];
    }
    return self;
}

- (DCTData *)mi {
    if(!_mi) 
        _mi = [[DCTData alloc] init];
    return _mi;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.listData = [[NSMutableArray alloc] init];
    self.navigationItem.title = NSLocalizedString(@"results", @"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"session", @"") style:UIBarButtonItemStylePlain target:self action:@selector(selSessionView)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"stats", @"") style:UIBarButtonItemStylePlain target:self action:@selector(statsView)];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.listData = nil;
    self.mi = nil;
    self.detailController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"will appear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"did appear");
    int num = [self.mi numberOfSolves];
    [listData removeAllObjects];
    if(num!=0) 
        for(int i = 0; i<num; i++) {
            [listData insertObject:[DCTData distimeAtIndex:i dt:false] atIndex:0];
            //[listData addObject:[self.datap getTimeAtIndex:i]];
        }
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([DCTUtils isPhone]) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    int num = [self.mi numberOfSolves];
    cell.textLabel.text = [listData objectAtIndex:row];
    cell.detailTextLabel.text = [self.mi getDateAtIndex:num-1-row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    detailController = [[DCTDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailController.title = NSLocalizedString(@"detail", @"");
    NSUInteger row = [indexPath row];
    int num = [self.mi numberOfSolves];
    if(row >= num) row = num-1;
    NSString *selectedTime = [DCTData distimeAtIndex:num-1-row dt:true];
    NSString *time = [NSString stringWithFormat:@"(%@)", [self.mi getDateAtIndex:num-1-row]];
    NSString *scr = [self.mi getScrambleAtIndex:num-1-row];
    detailController.rest = selectedTime;
    detailController.time = time;
    detailController.scramble = scr;
    [detailController setDetail:num-1-row penalty:[self.mi getPenaltyAtIndex:num-1-row]];
    detailController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailController animated:YES];
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
