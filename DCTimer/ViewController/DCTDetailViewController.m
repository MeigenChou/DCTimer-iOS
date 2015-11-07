//
//  DCTDetailViewController.m
//  DCTimer
//
//  Created by MeigenChou on 14-1-8.
//
//

#import "DCTDetailViewController.h"
#import "DCTData.h"
#import "DCTUtils.h"

@interface DCTDetailViewController ()
@property (nonatomic, strong) UILabel *lbResult;
@property (nonatomic, strong) UITextField *tvComment;
@end

@implementation DCTDetailViewController
@synthesize lbResult;
@synthesize rest;
@synthesize time;
@synthesize scramble;
@synthesize tvComment;
int resIdx;
int resPen;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        
    }
    return self;
}

- (void)setDetail:(int)idx {
    resIdx = idx;
    resPen = [[DCTData dbh] getPenaltyAtIndex:idx];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"title_more.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayActionSheet)];
    tvComment = [[UITextField alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    switch (indexPath.row) {
        case 0:
        {
            self.lbResult = cell.textLabel;
            self.lbResult.text = rest;
            self.lbResult.font = [UIFont boldSystemFontOfSize:24];
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 1:
            cell.textLabel.text = time;
            cell.textLabel.font = [UIFont systemFontOfSize:24];
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 2:
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = scramble;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
//        case 3:
//            cell.textLabel.text = [DCTUtils getString:@"penalty"];
//            cell.textLabel.font = [DCTUtils isOS7] ? [UIFont systemFontOfSize:17] : [UIFont boldSystemFontOfSize:17];
//            cell.detailTextLabel.text = @"";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            break;
        case 3:
            cell.textLabel.text = [DCTUtils getString:@"comment"];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            tvComment.text = @"-";
            cell.accessoryView = tvComment;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Get the text so we can measure it
    NSString *text;
    switch (indexPath.row) {
        case 0:
            return 44.0;
        case 1:
            return 44.0;
        case 2:
            text = scramble;
            return [DCTUtils heightForString:text fontSize:15];
        default:
            return 44.0;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) displayActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"option", @"") delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                  destructiveButtonTitle:NSLocalizedString(@"delete", @"")
                                  otherButtonTitles:NSLocalizedString(@"nopen", @""), @"+2", @"DNF", NSLocalizedString(@"copyscr", @""), nil];
    if ([DCTUtils isPad]) {
        [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    }
    else [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"%d %@", idx, pena);
    switch (buttonIndex) {
        case 0: //delete
            [[DCTData dbh] deleteTimeAtIndex:resIdx];
            [[DCTData dbh] deleteTime:resIdx];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 1: //no penalty
        case 2: //+2
        case 3: //DNF
            if(resPen != buttonIndex-1) {
                [self change:resIdx pen:buttonIndex-1];
                resPen = buttonIndex-1;
            }
            break;
        case 4: //copy scr
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = scramble;
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"copysuccess", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"close", @"") otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default:
            break;
    }
}

- (void) change:(int)idx pen:(int)pen {
    [[DCTData dbh] setPenalty:pen atIndex:idx];
    [[DCTData dbh] updateTime:idx pen:pen];
    self.lbResult.text = [DCTData distimeAtIndex:idx dt:true];
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
/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
