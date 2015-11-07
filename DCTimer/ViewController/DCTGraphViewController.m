//
//  DCTGraphViewController.m
//  DCTimer
//
//  Created by meigen on 15-1-6.
//
//

#import "DCTGraphViewController.h"
#import "DCTGraphView.h"
#import "DCTUtils.h"

@interface DCTGraphViewController ()
@property (nonatomic, strong) DCTGraphView *graphView;
@end

@implementation DCTGraphViewController
@synthesize graphView;

- (void)viewDidLoad {
    [super viewDidLoad];
    graphView = [[DCTGraphView alloc] init];
    graphView.backgroundColor = [UIColor whiteColor];
    self.view = graphView;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [graphView setNeedsDisplay];
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
