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
@end

@implementation DCTSessionViewController
NSMutableArray *session;
NSMutableArray *sesCount;
extern int currentSesIdx;
int selectedSesIdx;
bool isDefSes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"session", @"");
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"new_session"] style:UIBarButtonItemStylePlain target:self action:@selector(newSes)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defname = [defaults objectForKey:@"defsesname"];
    session = [[NSMutableArray alloc] initWithObjects:defname, nil];
    [[DCTData dbh] getSessionName:session];
    sesCount = [[NSMutableArray alloc] init];
    NSInteger count = session.count;
    for(int i=0; i<count; i++) {
        [sesCount addObject:@([[DCTData dbh] getSessionCount:i])];
    }
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)newSes {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[DCTUtils getString:@"new_session"] message:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"done"], nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert setTag:0];
    [alert show];
}

- (int)getSesCount:(NSUInteger)row {
    if(row >= sesCount.count) {
        [sesCount addObject:@(0)];
        return 0;
    }
    return [[sesCount objectAtIndex:row] intValue];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        switch (alertView.tag) {
            case 0:
            {
                NSString *name = tf.text;
                [session addObject:name];
                [[DCTData dbh] addSession:name];
                currentSesIdx = (int)session.count - 1;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:currentSesIdx forKey:@"crntsesidx"];
                [[DCTData dbh] query:currentSesIdx];
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
                else [[DCTData dbh] updateSession:selectedSesIdx name:name];
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
            [[DCTData dbh] clearSession:selectedSesIdx];
            [[DCTData dbh] deleteSession:selectedSesIdx];
            [session removeObjectAtIndex:selectedSesIdx];
            [sesCount removeObjectAtIndex:selectedSesIdx];
            if(selectedSesIdx == currentSesIdx) {
                currentSesIdx = 0;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:0 forKey:@"crntsesidx"];
                [[DCTData dbh] query:currentSesIdx];
            }
            [self.tableView reloadData];
            break;
        }
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"rename", @"") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"done", @""), nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *tf = [alert textFieldAtIndex:0];
            tf.clearButtonMode = UITextFieldViewModeWhileEditing;
            [tf setText:[session objectAtIndex:selectedSesIdx]];
            [alert setTag:1];
            [alert show];
            break;
        }
        case 2:
            [[DCTData dbh] clearSession:selectedSesIdx];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%d", (row==currentSesIdx) ? [DCTUtils getString:@"selected"]:@"", [DCTUtils getString:@"num_of_solve"], [self getSesCount:row]];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if(row!=currentSesIdx) {
        currentSesIdx = (int)row;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:currentSesIdx forKey:@"crntsesidx"];
        [[DCTData dbh] query:currentSesIdx];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedSesIdx = (int)row;
    isDefSes = row==0;
    UIActionSheet *actionSheet;
    if(isDefSes) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:[DCTUtils getString:@"rename"], [DCTUtils getString:@"clear_session"], nil];
        [actionSheet setTag:1];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] destructiveButtonTitle:[DCTUtils getString:@"delete_session"] otherButtonTitles:[DCTUtils getString:@"rename"], [DCTUtils getString:@"clear_session"], nil];
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
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
@end
