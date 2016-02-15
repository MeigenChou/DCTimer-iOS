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
#import "DCTGraphViewController.h"
#import "DCTData.h"
#import "DCTUtils.h"
#import <Social/Social.h>
#import <ACCOUNTS/ACAccount.h>

@interface DCTStatsViewController()
@property (nonatomic, strong) DCTDetailViewController *detailController;
@property (nonatomic, strong) UIPopoverController *popController;
@end

@implementation DCTStatsViewController
@synthesize detailController;
@synthesize popController;
NSMutableArray *stats;
NSMutableArray *statsDetail;
int num;
int graphType;
NSString *alertMsg;
extern bool issChange;
extern int currentSesIdx;
extern NSArray *types;
extern int selScrType;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = [DCTUtils getString:@"stats"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([DCTUtils sysVersion] >= 6.0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareByActivity)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[DCTData dbh] getSessionStats];
    num = [[DCTData dbh] numberOfSolves];
    stats = [[NSMutableArray alloc] init];
    statsDetail = [[NSMutableArray alloc] init];
    if(num > 0) {
        [stats addObject:[DCTUtils getString:@"session_mean"]];
        [statsDetail addObject:[[DCTData dbh] getSessionMeanSD]];
    }
    if(num > 2) {
        [stats addObject:[DCTUtils getString:@"session_avg"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"current_mean"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"best_mean"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
    }
    if(num > 4) {
        [stats addObject:[DCTUtils getString:@"current_avg5"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"best_avg5"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
    }
    if(num > 11) {
        [stats addObject:[DCTUtils getString:@"current_avg12"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"best_avg12"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
    }
    if(num > 49) {
        [stats addObject:[DCTUtils getString:@"current_avg50"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"best_avg50"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
    }
    if(num > 99) {
        [stats addObject:[DCTUtils getString:@"current_avg100"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
        [stats addObject:[DCTUtils getString:@"best_avg100"]];
        [statsDetail addObject:[DCTUtils getString:@"calculating"]];
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

- (void)calcavgs {
    if(num > 2) {
        if(issChange)[[DCTData dbh] getSessionAvg];
        [statsDetail replaceObjectAtIndex:1 withObject:[[DCTData dbh] getSessionAvgSD]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
        if(issChange)[[DCTData dbh] getMean:3];
        [statsDetail replaceObjectAtIndex:2 withObject:[[DCTData dbh] currentMean3]];
        [statsDetail replaceObjectAtIndex:3 withObject:[[DCTData dbh] getBestMean3]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 4) {
        if(issChange)[[DCTData dbh] getAvgs:0];
        [statsDetail replaceObjectAtIndex:4 withObject:[[DCTData dbh] currentAvg:0]];
        [statsDetail replaceObjectAtIndex:5 withObject:[[DCTData dbh] bestAvg:0]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 11) {
        if(issChange)[[DCTData dbh] getAvgs:1];
        [statsDetail replaceObjectAtIndex:6 withObject:[[DCTData dbh] currentAvg:1]];
        [statsDetail replaceObjectAtIndex:7 withObject:[[DCTData dbh] bestAvg:1]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 49) {
        if(issChange)[[DCTData dbh] getAvgs20:2];
        [statsDetail replaceObjectAtIndex:8 withObject:[[DCTData dbh] currentAvg:2]];
        [statsDetail replaceObjectAtIndex:9 withObject:[[DCTData dbh] bestAvg:2]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    if(num > 99) {
        if(issChange)[[DCTData dbh] getAvgs20:3];
        [statsDetail replaceObjectAtIndex:10 withObject:[[DCTData dbh] currentAvg:3]];
        [statsDetail replaceObjectAtIndex:11 withObject:[[DCTData dbh] bestAvg:3]];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    issChange = false;
}

- (void)updateTable {
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
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:[DCTUtils getString:@"close"] otherButtonTitles:[DCTUtils getString:@"copy"], nil];
//    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = alertMsg;
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:[DCTUtils getString:@"copy_success"] delegate:nil cancelButtonTitle:[DCTUtils getString:@"close"] otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)shareByActivity {
    NSURL *url = [NSURL URLWithString:[DCTUtils getString:@"share_url"]];
    CGRect rect = self.view.frame;
    int wid = rect.size.width;
    int hei = rect.size.height;
    int cut = [DCTUtils isOS7] ? 64 : 0;
    UIGraphicsBeginImageContext(CGSizeMake(wid, hei - cut));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSArray *shareItems = @[self, img, url];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    //if([controller respondsToSelector:@selector(popoverPresentationController)]) {
        //controller.popoverPresentationController.sourceView = [self.navigationController.navigationBar.subviews objectAtIndex:2];
        //controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    //}
    if([DCTUtils isPad]) {
        popController = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else [self presentViewController:controller animated:YES completion:nil];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    NSString *lang = [DCTUtils getString:@"language"];
    int type;
    if([lang isEqualToString:@"zh_CN"]) {
        if([activityType isEqualToString:UIActivityTypePostToTwitter]) {
            type = 2;
        } else type = 1;
    } else if([activityType isEqualToString:UIActivityTypePostToWeibo]) {
        type = 1;
    } else type = 2;
    if (type == 1) {
        if(num == 0) return [DCTUtils getString:@"share_weibo0"];
        NSMutableString *cont = [NSMutableString stringWithFormat:[DCTUtils getString:@"share_weibo1"], num, [types objectAtIndex:selScrType>>5], [[DCTData dbh] bestTime]];
        if(num > 1) [cont appendFormat:[DCTUtils getString:@"share_weibo2"], [[DCTData dbh] sessionMean]];
        if(num > 5) [cont appendFormat:[DCTUtils getString:@"share_weibo3"], 5, [[DCTData dbh] bestAvg:0]];
        if(num > 12) [cont appendFormat:[DCTUtils getString:@"share_weibo3"], 12, [[DCTData dbh] bestAvg:1]];
        [cont appendString:[DCTUtils getString:@"share_weibo4"]];
        return cont;
    } else if (type == 2) {
        if(num == 0) return [DCTUtils getString:@"share_cont0"];
        if(num == 1) return [NSString stringWithFormat:[DCTUtils getString:@"share_cont1"], [types objectAtIndex:selScrType>>5], [[DCTData dbh] bestTime]];
        NSMutableString *cont = [NSMutableString stringWithFormat:[DCTUtils getString:@"share_cont2"], num, [types objectAtIndex:selScrType>>5], [[DCTData dbh] bestTime], [[DCTData dbh] sessionMean]];
        if(num > 5) [cont appendFormat:[DCTUtils getString:@"share_cont3"], 5, [[DCTData dbh] bestAvg:0]];
        if(num > 12) [cont appendFormat:[DCTUtils getString:@"share_cont3"], 12, [[DCTData dbh] bestAvg:1]];
        
        [cont appendString:[DCTUtils getString:@"share_cont4"]];
        return cont;
    } else return @"Facebook";
}

- (NSString *)getShareCont {
    if(num == 0) return @"";
    NSMutableString *cont = [NSMutableString string];
    [cont appendFormat:[DCTUtils getString:@"share_cont1"], num, [types objectAtIndex:selScrType>>5], [[DCTData dbh] bestTime], [[DCTData dbh] sessionMean]];
    if(num > 5)
        [cont appendFormat:[DCTUtils getString:@"share_cont2"], 5, [[DCTData dbh] bestAvg:0]];
    if(num > 12)
        [cont appendFormat:[DCTUtils getString:@"share_cont2"], 12, [[DCTData dbh] bestAvg:1]];
    [cont appendString:[DCTUtils getString:@"share_cont3"]];
    return cont;
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (num < 1) return 1;
    if ([[DCTData dbh] getSolved] < 1) return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (num == 0) return 1;
            return 3;
        case 1:
            if (num < 1) return 0;
            if (num < 3) return 1;
            if (num < 5) return 4;
            if (num < 12) return 6;
            if (num < 50) return 8;
            if (num < 100) return 10;
            return 12;
        case 2:
            if ([[DCTData dbh] getSolved] > 1)
                return 2;
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [[DCTData dbh] getSessionName:currentSesIdx];
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    switch (indexPath.section) {
        case 0:
            switch (row) {
                case 0:
                    cell.textLabel.text = [DCTUtils getString:@"cube_solved"];
                    cell.detailTextLabel.text = [[DCTData dbh] cubeSolves];
                    break;
                case 1:
                    cell.textLabel.text = [DCTUtils getString:@"best_time"];
                    cell.detailTextLabel.text = [[DCTData dbh] bestTime];
                    break;
                default:
                    cell.textLabel.text = [DCTUtils getString:@"worst_time"];
                    cell.detailTextLabel.text = [[DCTData dbh] worstTime];
                    break;
            }
            cell.accessoryType = (row != 0) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            cell.selectionStyle = (row != 0) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
            break;
        case 1:
            cell.textLabel.text = [stats objectAtIndex:row];
            cell.detailTextLabel.text = [statsDetail objectAtIndex:row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
        case 2:
            if (row == 0)
                cell.textLabel.text = [DCTUtils getString:@"histogram"];
            else cell.textLabel.text = [DCTUtils getString:@"graph"];
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    switch (indexPath.section) {
        case 0:
            if(row != 0) {
                detailController = [[DCTDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
                detailController.title = [DCTUtils getString:@"detail"];
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
            break;
        case 1:
            if(row < 2) {
                [self showAlertStat:[DCTUtils getString:@"title_ses"] msg:[[DCTData dbh] getSessionMean]];
            } else if(row < 4) {
                [self showAlertStat:[DCTUtils replace:[DCTUtils getString:@"title_mean"] str:@"len" with:@"3"] msg:[[DCTData dbh] getMsgOfMean3:(row==2 ? num-1 : [[DCTData dbh] getBestMeanIdx])]];
            } else if(row < 6) {
                [self showAlertStat:[DCTUtils replace:[DCTUtils getString:@"title_avg"] str:@"len" with:@"5"] msg:[[DCTData dbh] getMsgOfAvg:(row==4 ? num-1 : [[DCTData dbh] bestAvgIdx:0]) num:5]];
            } else if(row < 8) {
                [self showAlertStat:[DCTUtils replace:[DCTUtils getString:@"title_avg"] str:@"len" with:@"12"] msg:[[DCTData dbh] getMsgOfAvg:(row==6 ? num-1 : [[DCTData dbh] bestAvgIdx:1]) num:12]];
            } else if(row < 10) {
                [self showAlertStat:[DCTUtils replace:[DCTUtils getString:@"title_avg"] str:@"len" with:@"50"] msg:[[DCTData dbh] getMsgOfAvg20:(row==8 ? num-1 : [[DCTData dbh] bestAvgIdx:2]) num:50]];
            } else {
                [self showAlertStat:[DCTUtils replace:[DCTUtils getString:@"title_avg"] str:@"len" with:@"100"] msg:[[DCTData dbh] getMsgOfAvg20:(row==10 ? num-1 : [[DCTData dbh] bestAvgIdx:3]) num:100]];
            }
            break;
        case 2:
        {
            DCTGraphViewController *graphController = [[DCTGraphViewController alloc] init];
            graphType = (int)row;
            graphController.title = row==0 ? [DCTUtils getString:@"histogram"] : [DCTUtils getString:@"graph"];
            graphController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:graphController animated:YES];
            break;
        }
    }
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
