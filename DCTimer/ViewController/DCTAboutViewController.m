//
//  DCTAboutViewController.m
//  DCTimer
//
//  Created by MeigenChou on 14-1-6.
//
//

#import "DCTAboutViewController.h"
#import "DCTUtils.h"

@interface DCTAboutViewController ()

@end

@implementation DCTAboutViewController
@synthesize webView;

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
    self.navigationItem.title = NSLocalizedString(@"about", @"");
    if([DCTUtils isOS7]) {
        CGSize bounds = [DCTUtils getBounds];
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    } else {
        CGSize frame = [DCTUtils getFrame];
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.width, frame.height)];
    }
    [webView setAutoresizesSubviews:YES];
    [webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"] isDirectory:NO]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
