//
//  DCTStatsViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTStatsViewController.h"
#import "DCTStatDetailController.h"
#import "DCTDetailViewController.h"
#import "DCTData.h"
#import "DCTUtils.h"

@interface DCTStatsViewController()
@property (nonatomic, strong) DCTDetailViewController *detailController;
@end

@implementation DCTStatsViewController
@synthesize detailController;
NSMutableArray *stats;
NSMutableArray *statsDetail;
int num;
NSString *alertMsg;
extern bool issChange;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"stats", @"");
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[DCTData dbh] getSessionStats];
    num = [[DCTData dbh] numberOfSolves];
    stats = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"numbercube", @""), nil];
    statsDetail = [[NSMutableArray alloc] initWithObjects:[[DCTData dbh] cubeSolves], nil];
    if(num>0) {
        [stats addObject:NSLocalizedString(@"besttime", @"")];
        [statsDetail addObject:[[DCTData dbh] bestTime]];
        [stats addObject:NSLocalizedString(@"worsttime", @"")];
        [statsDetail addObject:[[DCTData dbh] worstTime]];
    }
    if(num>2) {
        [stats addObject:NSLocalizedString(@"currentmean3", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
        [stats addObject:NSLocalizedString(@"bestmean3", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    if(num>4) {
        [stats addObject:NSLocalizedString(@"currentavg5", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
        [stats addObject:NSLocalizedString(@"bestavg5", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    if(num>11) {
        [stats addObject:NSLocalizedString(@"currentavg12", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
        [stats addObject:NSLocalizedString(@"bestavg12", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    if(num>49) {
        [stats addObject:NSLocalizedString(@"currentavg50", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
        [stats addObject:NSLocalizedString(@"bestavg50", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    if(num>99) {
        [stats addObject:NSLocalizedString(@"currentavg100", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
        [stats addObject:NSLocalizedString(@"bestavg100", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    if(num>0) {
        [stats addObject:NSLocalizedString(@"sesmean", @"")];
        [statsDetail addObject:[[DCTData dbh] getSessionMeanSD]];
    }
    if(num>2) {
        [stats addObject:NSLocalizedString(@"sesavg", @"")];
        [statsDetail addObject:NSLocalizedString(@"calcing", @"")];
    }
    [self.tableView reloadData];
    [NSThread detachNewThreadSelector:@selector(calcavgs) toTarget:self withObject:nil];
    //NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(calcavgs:) object:nil];
    //[myThread start];
}

- (void)viewDidUnload {
    self.detailController = nil;
    [super viewDidUnload];
}

- (void) calcavgs {
    if(num > 2) {
        if(issChange)[[DCTData dbh] getMean:3];
        [statsDetail replaceObjectAtIndex:3 withObject:[[DCTData dbh] currentMean3]];
        [statsDetail replaceObjectAtIndex:4 withObject:[[DCTData dbh] getBestMean3]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 4) {
        if(issChange)[[DCTData dbh] getAvgs:0];
        [statsDetail replaceObjectAtIndex:5 withObject:[[DCTData dbh] currentAvg:0]];
        [statsDetail replaceObjectAtIndex:6 withObject:[[DCTData dbh] bestAvg:0]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 11) {
        if(issChange)[[DCTData dbh] getAvgs:1];
        [statsDetail replaceObjectAtIndex:7 withObject:[[DCTData dbh] currentAvg:1]];
        [statsDetail replaceObjectAtIndex:8 withObject:[[DCTData dbh] bestAvg:1]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 2) {
        if(issChange)[[DCTData dbh] getSessionAvg];
        [statsDetail replaceObjectAtIndex:statsDetail.count-1 withObject:[[DCTData dbh] getSessionAvgSD]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 49) {
        if(issChange)[[DCTData dbh] getAvgs20:2];
        [statsDetail replaceObjectAtIndex:9 withObject:[[DCTData dbh] currentAvg:2]];
        [statsDetail replaceObjectAtIndex:10 withObject:[[DCTData dbh] bestAvg:2]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 99) {
        if(issChange)[[DCTData dbh] getAvgs20:3];
        [statsDetail replaceObjectAtIndex:11 withObject:[[DCTData dbh] currentAvg:3]];
        [statsDetail replaceObjectAtIndex:12 withObject:[[DCTData dbh] bestAvg:3]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    issChange = false;
}

- (void) updateTable {
    [self.tableView reloadData];
}

- (void)showAlertStat:(NSString *)title msg:(NSString *)msg {
    DCTStatDetailController *sdController = [[DCTStatDetailController alloc] init];
    sdController.title = title;
    sdController.sdContent = msg;
    //[sdController.textView setText:msg];
    sdController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sdController animated:YES];
//    alertMsg = msg;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"close", @"") otherButtonTitles:NSLocalizedString(@"copy", @""), nil];
//    [alert show];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    int intFlg=0;
    for(UIView *view in alertView.subviews) {
        if([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            if(intFlg==1) {
                label.textAlignment = UITextAlignmentLeft;
            }
            intFlg=1;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = alertMsg;
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"copysuccess", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"close", @"") otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark =
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [stats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [stats objectAtIndex:row];
    cell.detailTextLabel.text = [statsDetail objectAtIndex:row];
    cell.accessoryType = (row != 0) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = (row != 0) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    int num = [[DCTData dbh] numberOfSolves];
    if(row == 0);
    else if(row < 3) {
        detailController = [[DCTDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        detailController.title = NSLocalizedString(@"detail", @"");
        int idx = (row == 1)?[[DCTData dbh] getMinIndex]:[[DCTData dbh] getMaxIndex];
        NSString *selectedTime = [DCTData distimeAtIndex:idx dt:false];
        NSString *time = [NSString stringWithFormat:@"(%@)", [[DCTData dbh] getDateAtIndex:idx]];
        NSString *scr = [[DCTData dbh] getScrambleAtIndex:idx];
        detailController.rest = selectedTime;
        detailController.time = time;
        detailController.scramble = scr;
        [detailController setDetail:idx];
        detailController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailController animated:YES];
    }
    else if(row < 5) {
        if(num < 3) [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
        else if(row==3)
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_mean", @"") str:@"len" with:@"3"] msg:[[DCTData dbh] getMsgOfMean3:num-1]];
        else {
            NSString *msg = [[DCTData dbh] getMsgOfMean3:[[DCTData dbh] getBestMeanIdx]];
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_mean", @"") str:@"len" with:@"3"] msg:msg];
        }
    }
    else if(row < 7) {
        if(num < 5) [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
        else if(row==5) 
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"5"] msg:[[DCTData dbh] getMsgOfAvg:num-1 num:5]];
        else {
            NSString *msg = [[DCTData dbh] getMsgOfAvg:[[DCTData dbh] bestAvgIdx:0] num:5];
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"5"] msg:msg];
        }
    }
    else if(row < 9) {
        if(num < 12) [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
        else if(row==7)
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"12"] msg:[[DCTData dbh] getMsgOfAvg:num-1 num:12]];
        else {
            NSString *msg = [[DCTData dbh] getMsgOfAvg:[[DCTData dbh] bestAvgIdx:1] num:12];
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"12"] msg:msg];
        }
    }
    else if(row < 11) {
        if(num < 50) [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
        else if(row==9)
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"50"] msg:[[DCTData dbh] getMsgOfAvg20:num-1 num:50]];
        else {
            NSString *msg = [[DCTData dbh] getMsgOfAvg20:[[DCTData dbh] bestAvgIdx:2] num:50];
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"50"] msg:msg];
        }
    }
    else if(row < 13) {
        if(num < 100) [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
        else if(row==11)
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"100"] msg:[[DCTData dbh] getMsgOfAvg20:num-1 num:100]];
        else {
            NSString *msg = [[DCTData dbh] getMsgOfAvg20:[[DCTData dbh] bestAvgIdx:3] num:100];
            [self showAlertStat:[DCTUtils replace:NSLocalizedString(@"title_avg", @"") str:@"len" with:@"100"] msg:msg];
        }
    }
    else [self showAlertStat:NSLocalizedString(@"title_ses", @"") msg:[[DCTData dbh] getSessionMean]];
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
@end
