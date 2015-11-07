//
//  DCTSecondLevelViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-20.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTSecondLevelViewController.h"
#import "DCTFirstViewController.h"
#import "DCTUtils.h"

@implementation DCTSecondLevelViewController
@synthesize array;
@synthesize selIndex;
@synthesize key;
extern bool tfChanged;
extern bool esChanged;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark =
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sti = @"CheckMarkCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sti];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sti];
    }
    NSUInteger row = [indexPath row];
    int oldRow = [selIndex intValue];
    cell.textLabel.text = [array objectAtIndex:row];
    cell.accessoryType = (row==oldRow)?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = [indexPath row];
    if(row != [selIndex intValue]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:row forKey:key];
        if([key isEqualToString:@"accuracy"]) {
            tfChanged = true;
        }
        if([key isEqualToString:@"cxe"] || [key isEqualToString:@"cside"] || [key isEqualToString:@"sqshape"] ) {
            esChanged = true;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
