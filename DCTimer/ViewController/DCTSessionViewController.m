//
//  DCTSessionViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-29.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTSessionViewController.h"
#import "DCTData.h"
#import "DCTUtils.h"

@interface DCTSessionViewController()
@property (nonatomic, strong) DCTData *dbh;
@end

@implementation DCTSessionViewController
@synthesize dbh = _dbh;
NSMutableArray *session;
extern int currentSesIdx;
int selectedSesIdx;
bool isDefSes;

- (DCTData *)dbh {
    if(!_dbh)
        _dbh = [[DCTData alloc] init];
    return _dbh;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"session", @"");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"newses", @"") style:UIBarButtonItemStylePlain target:self action:@selector(newSes)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defname = [defaults objectForKey:@"defsesname"];
    session = [[NSMutableArray alloc] initWithObjects:defname, nil];
    [self.dbh getSessionName:session];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    self.dbh = nil;
    [super viewDidUnload];
}

- (void)newSes {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"newses", @"") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"done", @""), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:0];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        switch (alertView.tag) {
            case 0:
            {
                NSString *name = tf.text;
                [session addObject:name];
                [self.dbh addSession:name];
                currentSesIdx = session.count - 1;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:currentSesIdx forKey:@"crntsesidx"];
                [self.dbh query:currentSesIdx];
                [self.tableView reloadData];
                break;
            }
            case 1:
            {
                NSString *name = tf.text;
                [session replaceObjectAtIndex:selectedSesIdx withObject:name];
                if(isDefSes) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:name forKey:@"defsesname"];
                }
                else [self.dbh updateSession:selectedSesIdx name:name];
                [self.tableView reloadData];
                break;
            }
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag + buttonIndex) {
        case 0:
        {
            [self.dbh clearSession:selectedSesIdx];
            [self.dbh deleteSession:selectedSesIdx];
            [session removeObjectAtIndex:selectedSesIdx];
            currentSesIdx = 0;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:0 forKey:@"crntsesidx"];
            [self.dbh query:0];
            [self.tableView reloadData];
            break;
        }
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"rename", @"") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"done", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0] setText:[session objectAtIndex:selectedSesIdx]];
            [alert setTag:1];
            [alert show];
            break;
        }
        case 2:
            [self.dbh clearSession:selectedSesIdx];
            break;
    }
}

#pragma mark =
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [session count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [session objectAtIndex:row];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.detailTextLabel.text = (row==currentSesIdx)?NSLocalizedString(@"selected", @""):@"";
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if(row!=currentSesIdx) {
        currentSesIdx = row;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:currentSesIdx forKey:@"crntsesidx"];
        [self.dbh query:currentSesIdx];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedSesIdx = row;
    isDefSes = row==0;
    UIActionSheet *actionSheet;
    if(isDefSes) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"rename", @""), NSLocalizedString(@"clearses", @""), nil];
        [actionSheet setTag:1];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") destructiveButtonTitle:NSLocalizedString(@"deleteses", @"") otherButtonTitles:NSLocalizedString(@"rename", @""), NSLocalizedString(@"clearses", @""), nil];
        [actionSheet setTag:0];
    }
    if ([DCTUtils isPad]) {
        [actionSheet showFromRect:cell.bounds inView:cell animated:YES];
        //[actionSheet showFromRect:cell.bounds inView:cell.accessoryView animated:YES];
        //[actionSheet showInView:cell.accessoryView];
    }
    else [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
@end
