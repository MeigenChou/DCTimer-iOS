//
//  DCTStatDetailViewController.m
//  DCTimer
//
//  Created by MeigenChou on 14-2-17.
//
//

#import "DCTStatDetailViewController.h"
#import "DCTUtils.h"

@interface DCTStatDetailViewController ()

@end

@implementation DCTStatDetailViewController
@synthesize textView;
@synthesize content;

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
	// Do any additional setup after loading the view.
    if([DCTUtils isOS7]) {
        CGSize bounds = [DCTUtils getBounds];
        textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, bounds.width-10, bounds.height-10)];
    } else {
        CGSize frame = [DCTUtils getFrame];
        textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, frame.width-10, frame.height-10)];
    }
    [textView setAutoresizesSubviews:YES];
    [textView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:textView];
    [textView setEditable:NO];
    [textView setText:content];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
