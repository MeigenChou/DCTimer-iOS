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
#import "DCTData.h"

@implementation DCTGraphViewController
@synthesize graphView;
@synthesize segment;
extern int graphType;
int graphLength;

- (void)viewDidLoad {
    [super viewDidLoad];
    graphView = [[DCTGraphView alloc] init];
    graphView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:graphView];
    self.view = graphView;
    if(graphType == 1) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        int nSolve = [[DCTData dbh] getSolved];
        graphLength = nSolve > 5 ? 5 : nSolve;
        //NSLog(@"%d", graphLength);
        if(nSolve > 5) [array addObject:[DCTUtils getString:@"last5"]];
        if(nSolve > 12) [array addObject:[DCTUtils getString:@"last12"]];
        if(nSolve > 50) [array addObject:[DCTUtils getString:@"last50"]];
        if(nSolve > 100) [array addObject:[DCTUtils getString:@"last100"]];
        [array addObject:[DCTUtils getString:@"all"]];
        segment = [[UISegmentedControl alloc] initWithItems:array];
        int ios7delta = [DCTUtils isOS7] ? 64 : 0;
        int wid = [DCTUtils getFrame].width;
        int hei = [DCTUtils getFrame].height;
        int segWid = hei==1024 ? 1004 : wid - 20;
        int segHei = [DCTUtils isOS7] ? 29 : 34;
        segment.frame = CGRectMake(10, 10+ios7delta, segWid, segHei);
        [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segment];
        [segment setSelectedSegmentIndex:0];
    }
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

- (void)segmentAction:(UISegmentedControl *)seg {
    NSInteger index = seg.selectedSegmentIndex;
    int nSolve = [[DCTData dbh] getSolved];
    if(index == seg.numberOfSegments - 1) {
        graphLength = nSolve;
    } else if(index == 0) {
        graphLength = nSolve > 5 ? 5 : nSolve;
    } else if(index == 1) {
        graphLength = nSolve > 12 ? 12 : nSolve;
    } else if(index == 2) {
        graphLength = nSolve > 50 ? 50 : nSolve;
    } else {
        graphLength = nSolve > 100 ? 100 : nSolve;
    }
    [graphView setNeedsDisplay];
}
@end
