//
//  DCTStatDetailController.m
//  DCTimer
//
//  Created by MeigenChou on 14-2-17.
//
//

#import "DCTStatDetailController.h"
#import "DCTUtils.h"

@interface DCTStatDetailController ()

@end

@implementation DCTStatDetailController
@synthesize textView;
@synthesize sdContent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([DCTUtils isOS7]) {
        CGSize bounds = [DCTUtils getBounds];
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    } else {
        CGSize frame = [DCTUtils getFrame];
        textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.width, frame.height)];
    }
    if([DCTUtils isPhone])
        textView.font = [UIFont fontWithName:@"Arial" size:15.0];
    else textView.font = [UIFont fontWithName:@"Arial" size:16.0];
    //textView.scrollEnabled = YES;
	[textView setAutoresizesSubviews:YES];
    [textView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:textView];
    //[self.view setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
    [textView setEditable:NO];
    [textView setText:sdContent];
    //[textView setBackgroundColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"copy"] style:UIBarButtonItemStylePlain target:self action:@selector(copyStats)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)copyStats {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = sdContent;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:[DCTUtils getString:@"copy_success"] delegate:nil cancelButtonTitle:[DCTUtils getString:@"close"] otherButtonTitles:nil];
    [alertView show];
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
