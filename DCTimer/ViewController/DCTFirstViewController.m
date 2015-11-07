//
//  DCTFirstViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTFirstViewController.h"
#import "Scrambler.h"
#import "DCTData.h"
#import "DCTScrambleView.h"
#import "QuartzCore/QuartzCore.h"
//#import "FPPopoverController.h"
#import "DCTPickerViewController.h"
#import "DCTUtils.h"
#import <mach/mach_time.h>

@interface DCTFirstViewController()
@property (nonatomic, strong) Scrambler *scrambler;
@property (nonatomic, strong) DCTData *dbh;
@property (nonatomic, strong) UIColor *textCol;
@property (nonatomic, strong) NSTimer *dctTimer;
@property (nonatomic, strong) NSTimer *fTimer;
@property (nonatomic, strong) NSTimer *inspTimer;
@property (nonatomic, strong) NSString *extsol;
@end

@implementation DCTFirstViewController
@synthesize scrLabel,timerLabel;
@synthesize btnScrType, btnScrView;
@synthesize scrambler;
@synthesize dbh;
@synthesize gestureStartPoint;
@synthesize textCol;
@synthesize dctTimer, fTimer, inspTimer;
@synthesize extsol;

NSString *currentScr;
int timerState; //0-停止 1-计时中 2-观察中
int inspState;  //2-观察 2-+2 3-DNF
mach_timebase_info_data_t info;
uint64_t timeStart;
uint64_t timeEnd;
int resTime;
NSDateFormatter *formatter;
bool canStart;
int fTime;
bool wcaInsp, wcaInst;
extern int timerupd, accuracy;
extern bool clkFormat, hideScr;
extern bool promTime;
extern int cside, cxe, sqshp;
extern bool prntScr, inTime;
extern bool tfChanged;
extern int viewType;
int currentSesIdx;
NSString *lastScr = @"";
int selScrType;
int bgcolor, textcolor;
bool isExts;
NSDictionary *scrType;
NSArray *types;
NSArray *subsets;

bool esChanged = false;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"timer", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"img1"];
        self.scrambler = [[Scrambler alloc] init];
        self.dbh = [[DCTData alloc] init];
        mach_timebase_info(&info);
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return self;
}

//- (Scrambler *)scrambler {
//    if(!self.scrambler)
//        self.scrambler = [[Scrambler alloc] init];
//    return self.scrambler;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void) setScrLblFont {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if ([DCTUtils isPad]) {
        if(type==0 || type==7 || type==13 || type==10)
            [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:30]];
        else if(type==1 || type==2)
            [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:28]];
        else [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:25]];
    }
    else if(type==0 || type==7 || type==13 || type==10)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:19]];
    else if(type==3)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
    else if(type==4)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
    else if(type==5)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
    else if(type==6)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:12.5]];
    else if(type==11) {
        if(sub==0) [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:19]];
        else if(sub==9 || sub==10) [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
        else [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:17]];
    } else if(type==16 && sub==3)
        [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
    else [self.scrLabel setFont:[UIFont fontWithName:@"Arial" size:17]];
}

- (void) newScramble {
    lastScr = currentScr;
    scrLabel.text = NSLocalizedString(@"scrambling", @"");
    [NSThread detachNewThreadSelector:@selector(getScramble) toTarget:self withObject:nil];
}

- (void) getScramble {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    currentScr = [self.scrambler getScrString:selScrType];
    if(type==1 && sub<2 && cxe != 0) {
        if(cxe==1)
            extsol = [self.scrambler solveCross:currentScr side:cside];
        else if(cxe==2)
            extsol = [self.scrambler solveXcross:currentScr side:cside];
        else if(cxe==3)
            extsol = [self.scrambler solveEoline:currentScr side:cside];
        isExts = true;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    } else if(type==8 && sqshp!=0) {
        extsol = [self.scrambler solveSqShape:currentScr m:sqshp];
        isExts = true;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    } else {
        isExts = false;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    }
}

- (void)showScramble {
    if(isExts) {
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else scrLabel.text = currentScr;
}


- (void)extraSolve {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if(type==1 && sub<2 && cxe != 0) {
        if(cxe==1)
            extsol = [self.scrambler solveCross:currentScr side:cside];
        else if(cxe==2)
            extsol = [self.scrambler solveXcross:currentScr side:cside];
        else if(cxe==3)
            extsol = [self.scrambler solveEoline:currentScr side:cside];
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else if(type==8 && sqshp!=0) {
        extsol = [self.scrambler solveSqShape:currentScr m:sqshp];
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else scrLabel.text = currentScr;
}

- (void) loadDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    fTime = [[defaults objectForKey:@"freezeslide"] intValue];
    wcaInst = [defaults boolForKey:@"wcainsp"];
    if(timerState == 0)wcaInsp = wcaInst;
    timerupd = [defaults integerForKey:@"timerupd"];
    clkFormat = [defaults boolForKey:@"clockform"];
    accuracy = [defaults integerForKey:@"accuracy"];
    hideScr = [defaults boolForKey:@"hidescr"];
    promTime = [defaults boolForKey:@"prompttime"];
    cxe = [defaults integerForKey:@"cxe"];
    cside = [defaults integerForKey:@"cside"];
    sqshp = [defaults integerForKey:@"sqshape"];
    prntScr = [defaults boolForKey:@"printscr"];
    currentSesIdx = [defaults integerForKey:@"crntsesidx"];
    selScrType = [defaults integerForKey:@"crntscrtype"];
    bgcolor = [defaults integerForKey:@"bgcolor"];
    textcolor = [defaults integerForKey:@"textcolor"];
    inTime = [defaults boolForKey:@"intime"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadDefaults];
    isChange = true;
    if(inTime)timerLabel.text = @"IMPORT";
    else if(accuracy == 1)timerLabel.text = @"0.00";
    [btnScrView setTitle:NSLocalizedString(@"scramble_view", @"") forState:UIControlStateNormal];
    [self.scrambler getScrString:32];
    [self.scrambler initSq1];
    int type = selScrType>>5;
    int sub = selScrType&31;
    currentScr = [self.scrambler getScrString:selScrType];
    [self extraSolve];
    lastScr = currentScr;
    NSString *scrList = [NSLocalizedString(@"language", @"") isEqualToString:@"zh_CN"] ? @"scrambleCN" : ([NSLocalizedString(@"language", @"") isEqualToString:@"zh_HK"] ? @"scrambleHK" : @"scramble");
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:scrList withExtension:@"plist"];
    scrType = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    types = [DCTUtils getScrType];
    NSString *select = [types objectAtIndex:type];
    subsets = [scrType objectForKey:select];
    [btnScrType setTitle:[NSString stringWithFormat:@"%@ - %@", select, [subsets objectAtIndex:sub]] forState:UIControlStateNormal];
    [self setScrLblFont];
    if ([DCTUtils isOS7]) {
        if ([DCTUtils isPad]) {
            btnScrType.frame = CGRectMake(20, 40, 420, 37);
            btnScrView.frame = CGRectMake(458, 40, 290, 37);
            scrLabel.frame = CGRectMake(20, 96, 728, 280);
        } else {
            btnScrType.frame = CGRectMake(10, 30, 185, 35);
            btnScrView.frame = CGRectMake(205, 30, 105, 35);
            scrLabel.frame = CGRectMake(10, 50, 300, 160);
            timerLabel.frame = CGRectMake(10, 194, 300, 120);
        }
    } else {
        UIImage *btnImageNormal = [UIImage imageNamed:@"whiteButton.png"];
        UIImage *sbtnImageNormal = [btnImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [btnScrType setBackgroundImage:sbtnImageNormal forState:UIControlStateNormal];
        [btnScrView setBackgroundImage:sbtnImageNormal forState:UIControlStateNormal];
        btnImageNormal = [UIImage imageNamed:@"blueButton.png"];
        sbtnImageNormal = [btnImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [btnScrType setBackgroundImage:sbtnImageNormal forState:UIControlStateHighlighted];
        [btnScrView setBackgroundImage:sbtnImageNormal forState:UIControlStateHighlighted];
    }
    [self.dbh getSessions];
    [self.dbh query:currentSesIdx];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setScrLabel:nil];
    [self setBtnScrType:nil];
    [self setBtnScrView:nil];
    [self setTimerLabel:nil];
    [self.dbh closeDB];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadDefaults];
    int r = (bgcolor>>16)&0xff;
    int g = (bgcolor>>8)&0xff;
    int b = bgcolor&0xff;
    [self.view setBackgroundColor:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]];
    r = (textcolor>>16)&0xff;
    g = (textcolor>>8)&0xff;
    b = textcolor&0xff;
    textCol = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    self.scrLabel.textColor = textCol;
    timerLabel.textColor = textCol;
    if(tfChanged) {
        if(inTime) {
            timerLabel.text = @"IMPORT";
        } else {
            timerLabel.text = accuracy == 1 ? @"0.00" : @"0.000";
        }
        tfChanged = false;
    }
    if(esChanged) {
        [self extraSolve];
        esChanged = false;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if(timerState == 2) {
        [inspTimer invalidate];
        timerLabel.textColor = textCol;
    }
    else if(timerState == 1) {
        [dctTimer invalidate];
    }
    timerState = 0;
    btnScrType.hidden = NO;
    btnScrView.hidden = NO;
    if(hideScr) scrLabel.hidden = NO;
    if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:NO];
    else {
        [self hideTabBar:NO];
    }
    wcaInsp = wcaInst;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)record:(int)time pen:(int)pen {
    NSDate *date = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:date];
    [self.dbh addTime:time penalty:pen scramble:lastScr datetime:nowtimeStr];
    [self.dbh insertTime:time pen:pen scr:lastScr date:nowtimeStr];
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

- (IBAction)selScrambleType:(id)sender {
    DCTPickerViewController *viewController = [[DCTPickerViewController alloc] init];
    viewController.delegate = self;
    scrPop = [[FPPopoverController alloc] initWithViewController:viewController];
    scrPop.contentSize = CGSizeMake(310, 300);
    scrPop.arrowDirection = FPPopoverArrowDirectionAny;
    [scrPop presentPopoverFromView:sender];
}

- (void)setScr: (NSString *)scr {
    [btnScrType setTitle:scr forState:UIControlStateNormal];
    [self newScramble];
    [self setScrLblFont];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:selScrType forKey:@"crntscrtype"];
    [scrPop dismissPopoverAnimated:YES];
}

- (IBAction)drawScrView:(id)sender {
    if(viewType!=0) {
        UIViewController *viewController = [[UIViewController alloc] init];
        DCTScrambleView *view;
        if([DCTUtils isPad]) view = [[DCTScrambleView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
        else view = [[DCTScrambleView alloc] initWithFrame:CGRectMake(0, 0, 240, 200)];
        view.backgroundColor = [UIColor colorWithRed:0.92 green:0.91 blue:0.84 alpha:0.66];
        viewController.view = view;
        SAFE_ARC_RELEASE(popover); popover=nil;
        popover = [[FPPopoverController alloc] initWithViewController:viewController];
        if([DCTUtils isPad]) popover.contentSize = CGSizeMake(340, 280);
        //else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)popover.contentSize = CGSizeMake(260, 200);
        else popover.contentSize = CGSizeMake(261, 220);
        popover.arrowDirection = FPPopoverArrowDirectionAny;
        [popover presentPopoverFromView:sender];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"scramble_view", @"")
                              message:NSLocalizedString(@"not_support", @"")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"close", @"")
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if(alertView.tag!=0)
                inspState = 1;
            break;
        case 1:
            switch (alertView.tag) {
                case 1:
                {
                    int time = inspState==2?resTime+2000:resTime;
                    [self record:time pen:0];
                    inspState = 1;
                    break;
                }
                case 2:
                    [self record:resTime pen:2];
                    inspState = 1;
                    break;
                case 3:
                    [self.dbh deleteTimeAtIndex:[self.dbh numberOfSolves]-1];
                    [self.dbh deleteTime:[self.dbh numberOfSolves]];
                    if(!inTime) {
                        if([self.dbh numberOfSolves] == 0) timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                        else timerLabel.text = [DCTData distimeAtIndex:[self.dbh numberOfSolves]-1 dt:false];
                    }
                    break;
                case 4:
                {
                    UITextField *tf = [alertView textFieldAtIndex:0];
                    NSString *time = [DCTUtils convStr:[DCTUtils replace:tf.text str:@"：" with:@":"]];
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"invalid_in", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"close", @"") otherButtonTitles:nil];
                    if([time hasPrefix:@"Err"]) [alertView show];
                    else {
                        int tm = [DCTUtils convTime:time];
                        if(tm == 0) [alertView show];
                        else {
                            [self record:tm pen:0];
                        }
                    }
                    [tf setText:@""];
                    [self newScramble];
                    break;
                }
                case 5:
                    [self.dbh clearSession:currentSesIdx];
                    timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                    break;
                case 6:
                    [self change:[self.dbh numberOfSolves]-1 pen:0];
                    break;
            }
            break;
        case 2:
        {
            if(alertView.tag==6) {
                [self change:[self.dbh numberOfSolves]-1 pen:1];
            } else {
                int time = inspState==2?resTime+2000:resTime;
                [self record:time pen:1];
                inspState = 1;
            }
            break;
        }
        case 3:
        {
            if(alertView.tag==6) {
                [self change:[self.dbh numberOfSolves]-1 pen:2];
            } else {
                int time = inspState==2?resTime+2000:resTime;
                [self record:time pen:2];
                inspState = 1;
            }
            break;
        }
        default:
            break;
    }
}

- (void) change:(int)idx pen:(int)pen {
    [self.dbh setPenalty:pen atIndex:idx];
    [self.dbh updateTime:idx pen:pen];
    if(!inTime) self.timerLabel.text = [DCTData distimeAtIndex:idx dt:false];
}

- (NSString *)contime:(int)i {
    bool m = i<0;
    if(m)i = -i;
    i/=1000;
    int sec=clkFormat?i%60:i;
    int min=clkFormat?(i/60)%60:0;
    int hour=clkFormat?i/3600:0;
    NSMutableString *s = [NSMutableString string];
    if(hour==0) {
        if(min==0) [s appendFormat:@"%d", sec];
        else {
            if(sec<10) [s appendFormat:@"%d:0%d", min, sec];
            else [s appendFormat:@"%d:%d", min, sec];
        }
    } else {
        [s appendFormat:@"%d", hour];
        if(min<10) [s appendFormat:@":0%d", min];
        else [s appendFormat:@":%d", min];
        if(sec<10) [s appendFormat:@":0%d", sec];
        else [s appendFormat:@":%d", sec];
    }
    return s;
}

- (void)updateTime {
    uint64_t timeNow = mach_absolute_time();
    int time = (int) ((timeNow - timeStart) * info.numer / info.denom / 1000000);
    if(timerupd == 0) timerLabel.text = [DCTUtils distime:time];
    else if(timerupd == 1) timerLabel.text = [self contime:time];
    else timerLabel.text = NSLocalizedString(@"solve", @"");
}

- (void)updateInspTime {
    uint64_t timeNow = mach_absolute_time();
    int time = (int) ((timeNow - timeStart) * info.numer / info.denom / 1000000);
    if(time/1000<15) {
        int sec = (15 - time/1000);
        if(timerupd < 3) timerLabel.text = [NSString stringWithFormat:@"%d", sec];
        else timerLabel.text = NSLocalizedString(@"inspect", @"");
        inspState = 1;
    } else if(time/1000<17) {
        if(timerupd < 3) timerLabel.text = @"+2";
        inspState = 2;
    } else {
        if(timerupd < 3) timerLabel.text = @"DNF";
        inspState = 3;
    }
}

- (void)setCanStart {
    canStart = true;
    timerLabel.textColor = [UIColor greenColor];
}

- (void) hideTabBar:(BOOL) hidden {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    int height = [DCTUtils getFrame].height;
    if(height == 1024) height = 768;
    else height += 20;
    for(UIView *view in self.tabBarController.view.subviews) {
        if([view isKindOfClass:[UITabBar class]]) {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, height, view.frame.size.width, view.frame.size.height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, height - 49, view.frame.size.width, view.frame.size.height)];
            }
        }
        else {
            if (hidden) {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height)];
            } else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height - 49)];
            }
        }
    }
    [UIView commitAnimations];
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
    switch (timerState) {
        case 0:
            if(inTime) {
                timerLabel.textColor = [UIColor greenColor];
            }
            else if(fTime == 0 || wcaInsp) {
                canStart = true;
                timerLabel.textColor = [UIColor greenColor];
            } else {
                canStart = false;
                timerLabel.textColor = [UIColor redColor];
                fTimer = [NSTimer scheduledTimerWithTimeInterval:fTime*0.05 target:self selector:@selector(setCanStart) userInfo:nil repeats:NO];
            }
            break;
        case 1:
        {
            timeEnd = mach_absolute_time();
            [dctTimer invalidate];
            resTime = (int) ((timeEnd - timeStart) * info.numer / info.denom / 1000000);
            timerLabel.text = [DCTUtils distime:resTime];
            btnScrType.hidden = NO;
            btnScrView.hidden = NO;
            if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:NO];
            else {
                [self hideTabBar:NO];
            }
            if(hideScr) scrLabel.hidden = NO;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
        }
        default:
            if(fTime == 0) {
                canStart = true;
                timerLabel.textColor = [UIColor greenColor];
            } else {
                canStart = false;
                timerLabel.textColor = [UIColor yellowColor];
                fTimer = [NSTimer scheduledTimerWithTimeInterval:fTime*0.05 target:self selector:@selector(setCanStart) userInfo:nil repeats:NO];
            }
            break;
    }
    swipeType = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    timerLabel.textColor = textCol;
    timerState = 0;
    inspState = 1;
    swipeType = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    timerLabel.textColor = textCol;
    if(swipeType == 1) {
        isChange = true;
        [fTimer invalidate];
    } else if(swipeType == 2) {
        isChange = true;
        [fTimer invalidate];
        if([self.dbh numberOfSolves]>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletelast", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
            [alert setTag:3];
            [alert show];
        }
    } else if(swipeType == 4) {
        isChange = true;
        [fTimer invalidate];
        if([self.dbh numberOfSolves]>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"last_solve", @""), [DCTData distimeAtIndex:[self.dbh numberOfSolves]-1 dt:true]] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nopen", @""), @"+2", @"DNF", nil];
            [alert setTag:6];
            [alert show];
        }
    } else if(swipeType == 3) {
        isChange = true;
        [fTimer invalidate];
        if([self.dbh numberOfSolves]>0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"conf_delses", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
            [alert setTag:5];
            [alert show];
        }
    }
    else {
        switch (timerState) {
            case 0:
                if(inTime) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"intime", @"") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"done", @""), nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *tf = [alert textFieldAtIndex:0];
                    tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                    [alert setTag:4];
                    [alert show];
                }
                else if(canStart) {
                    timeStart = mach_absolute_time();
                    if(wcaInsp) {
                        timerLabel.textColor = [UIColor redColor];
                        inspTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateInspTime) userInfo:nil repeats:YES];
                        timerState = 2;
                    } else {
                        dctTimer = [NSTimer scheduledTimerWithTimeInterval:(timerupd==0 ? 0.017 : 0.1) target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                        timerState = 1;
                    }
                    btnScrType.hidden = YES;
                    btnScrView.hidden = YES;
                    if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:YES];
                    else {
                        [self hideTabBar:YES];
                    }
                    if(hideScr) scrLabel.hidden = YES;
                    [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
                } else {
                    [fTimer invalidate];
                    timerLabel.textColor = textCol;
                }
                break;
            case 1:
            {
                [self newScramble];
                timerState = 0;
                wcaInsp = wcaInst;
                if(promTime) {
                    int time = (inspState==2)?resTime+2000:resTime;
                    if(inspState==3) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@: DNF", NSLocalizedString(@"time", @"")] message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"save", @""), nil];
                        [alert setTag:2];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"time", @""), [DCTUtils distime:time]] message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nopen", @""), @"+2", @"DNF", nil];
                        [alert setTag:1];
                        [alert show];
                    }
                } else {
                    int time = inspState==2?resTime+2000:resTime;
                    int pen = inspState==3?2:0;
                    [self record:time pen:pen];
                    inspState = 1;
                }
                break;
            }
            case 2:
                if(canStart) {
                    timeStart = mach_absolute_time();
                    [inspTimer invalidate];
                    dctTimer = [NSTimer scheduledTimerWithTimeInterval:0.017 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    timerState = 1;
                } else {
                    [fTimer invalidate];
                    timerLabel.textColor = [UIColor redColor];
                }
                break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //timerLabel.textColor = [UIColor blackColor];
    if(timerState == 0) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPo = [touch locationInView:self.view];
        CGFloat deltaX = currentPo.x - gestureStartPoint.x;
        CGFloat deltaY = currentPo.y - gestureStartPoint.y;
        if(fabsf(deltaY) <= 8) {
            if(deltaX >= 25) {
                swipeType = 1;
                if(isChange) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    [self newScramble];
                    isChange = false;
                }
            }
            else if(deltaX <= -25) {
                swipeType = 2;
                if(isChange) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isChange = false;
                }
            }
        }
        if(fabsf(deltaX) <= 8) {
            if(deltaY >= 25) {
                swipeType = 3;
                if(isChange) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isChange = false;
                }
            } else if(deltaY <= -25) {
                swipeType = 4;
                if(isChange) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isChange = false;
                }
            }
        }
    }
}
@end
