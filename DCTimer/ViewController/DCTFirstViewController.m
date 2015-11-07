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
@property (nonatomic, strong) UIColor *textCol;
@property (nonatomic, strong) NSTimer *dctTimer;
@property (nonatomic, strong) NSTimer *fTimer;
@property (nonatomic, strong) NSTimer *inspTimer;
@property (nonatomic, strong) NSString *extsol;
@property (nonatomic, strong) DCTScrambleView *scrambleView;
@property (nonatomic) TimerState timerState;
//@property (nonatomic, strong) NSString *lastScr;
@property (nonatomic, strong) NSString *nextScr;
@end

@implementation DCTFirstViewController
@synthesize scrLabel,timerLabel;
@synthesize btnScrType;
@synthesize scrambler;
@synthesize gestureStartPoint;
@synthesize textCol;
@synthesize dctTimer, fTimer, inspTimer;
@synthesize extsol;
@synthesize imageView;
@synthesize scrambleView;
@synthesize timerState;
@synthesize nextScr;

NSString *currentScr;   //extern
mach_timebase_info_data_t info;

NSDateFormatter *formatter;
int fTime;
BOOL wcaInsp, hideScr, inTime, dropStop, promptTime, showScr;
extern NSInteger timerupd, accuracy, timeForm;
extern BOOL showImg;
extern NSInteger cside, cxe, sqshp;
extern bool tfChanged, imgChanged, svChanged, monoChanged;
int currentSesIdx;  //extern
int selScrType; //extern
NSDictionary *scrType;  //extern
NSArray *types; //extern
NSArray *subsets;   //extern
bool esChanged = false; //extern
double lowZ = 0.98;
NSArray *fonts;
extern NSInteger tmfont;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"timer", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"img1"];
        self.scrambler = [[Scrambler alloc] init];
        mach_timebase_info(&info);
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        fonts = [[NSArray alloc] initWithObjects:@"Arial", @"Courier New", @"Digiface", @"Georgia", @"Helvetica", @"Times New Roman", @"Verdana", nil];
        time1 = 0;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaults];
    isChange = true;
    if(inTime) timerLabel.text = @"IMPORT";
    else if(accuracy == 1) timerLabel.text = @"0.00";
    //[self.scrambler getScrString:32];
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    isNextScr = false;
    typeChanged = true;
    canScr = true;
    //lastScr = currentScr;
    NSString *lang = NSLocalizedString(@"language", @"");
    NSLog(@"language %@", lang);
    NSString *scrList = [lang isEqualToString:@"zh_CN"] ? @"scrambleCN" : ([lang isEqualToString:@"zh_HK"] ? @"scrambleHK" : @"scramble");
    NSURL *plistURL = [[NSBundle mainBundle] URLForResource:scrList withExtension:@"plist"];
    scrType = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    types = [DCTUtils getScrType];
    if(type >= types.count) type = 1;
    NSString *select = [types objectAtIndex:type];
    subsets = [scrType objectForKey:select];
    if(sub >= subsets.count) sub = 0;
    if(type == 2 && sub == 5) sub = 0;
    [btnScrType setTitle:[NSString stringWithFormat:@"%@ - %@", select, [subsets objectAtIndex:sub]] forState:UIControlStateNormal];
    selScrType = type << 5 | sub;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selScrType forKey:@"crntscrtype"];
    currentScr = [scrambler getScrString:selScrType];
    [self setScrLblFont];
    [self extraSolve];
    //[self newScramble:true];
    
    if ([DCTUtils isOS7]) {
        /*if ([DCTUtils isPad]) {
            scrLabel.frame = CGRectMake(20, 96, 728, 280);
            timerLabel.frame = CGRectMake(20, 430, 728, 200);
        } else {
            scrLabel.frame = CGRectMake(10, 50, 300, 160);
            timerLabel.frame = CGRectMake(10, 186, 300, 100);
        }*/
    } else {
        UIImage *btnImageNormal = [UIImage imageNamed:@"whiteButton.png"];
        UIImage *sbtnImageNormal = [btnImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [btnScrType setBackgroundImage:sbtnImageNormal forState:UIControlStateNormal];
        btnImageNormal = [UIImage imageNamed:@"blueButton.png"];
        sbtnImageNormal = [btnImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [btnScrType setBackgroundImage:sbtnImageNormal forState:UIControlStateHighlighted];
    }
    //[NSThread detachNewThreadSelector:@selector(setNextScr) toTarget:self withObject:nil];
    [[DCTData dbh] getSessions];
    int sesnum = [[DCTData dbh] getSessionCount];
    NSLog(@"%d %d", [[DCTData dbh] getSessionCount], currentSesIdx);
    if(currentSesIdx > sesnum) {
        currentSesIdx = sesnum - 1;
        [[NSUserDefaults standardUserDefaults] setInteger:currentSesIdx forKey:@"crntsesidx"];
    }
    [[DCTData dbh] query:currentSesIdx];
    int hei, wid, dlt = [DCTUtils isOS7] ? ([DCTUtils isPad] ? 13 : 20) : 0;
    CGSize frame = [DCTUtils getFrame];
    hei = frame.height; wid = frame.width;
    if(wid == 748) {
        hei = frame.width; wid = frame.height;
    }
    if([DCTUtils isPad]) scrambleView = [[DCTScrambleView alloc] initWithFrame:CGRectMake(wid-325, hei-294+dlt, 321, 241)];
    else scrambleView = [[DCTScrambleView alloc] initWithFrame:CGRectMake(wid-203, hei-201+dlt, 201, 150)];
    scrambleView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    [self.view addSubview:scrambleView];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    if(showImg) imgChanged = true;
    // Do any additional setup after loading the view, typically from a nib.
    self.motionMag = [[CMMotionManager alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if(self.motionMag.accelerometerAvailable) {
        self.motionMag.accelerometerUpdateInterval = 0.1;
        [self.motionMag startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if(!error && dropStop) {
                double az = accelerometerData.acceleration.z;
                lowZ = lowZ * 0.8 + az * 0.2;
                double highZ = az - lowZ;
                if(self.timerState==RUNNING && time1>200 && highZ*100>sensity) {
                    self.timerState = STOP;
                    [NSThread detachNewThreadSelector:@selector(stopTimer) toTarget:self withObject:nil];
                    //[self confirmSave];
                }
            }
        }];
    }
    NSArray *fontl = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *fname in fontl) {
        NSLog(@"family: %s\n", [fname UTF8String]);
//        NSArray *fontn = [UIFont fontNamesForFamilyName:fname];
//        for(NSString *fn in fontn) {
//            NSLog(@" font: %s\n", [fn UTF8String]);
//        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrLabel = nil;
    self.timerLabel = nil;
    self.btnScrType = nil;
    self.imageView = nil;
    self.scrambleView = nil;
    [[DCTData dbh] closeDB];
}

- (void)viewWillAppear:(BOOL)animated {
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
    if([DCTUtils isPad]) {
        timerLabel.font = [UIFont fontWithName:[fonts objectAtIndex:tmfont] size:tmSize];
    } else timerLabel.font = [UIFont fontWithName:[fonts objectAtIndex:tmfont] size:65];
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
    if(!showImg) {
        if(imgChanged) [imageView setImage:nil];
    }
    else if(imgChanged) {
        UIImage *image = [UIImage imageWithContentsOfFile:[DCTUtils getFilePath:@"bg.png"]];
        [imageView setImage:image];
        imgChanged = false;
    }
    if(svChanged) {
        [self.scrambleView setNeedsDisplay];
        svChanged = false;
    }
    if(showImg) [imageView setAlpha:opacity / 100.0];
    if (monoChanged) {
        [self setScrLblFont];
        monoChanged = false;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if(self.timerState == INSPECTING) {
        [inspTimer invalidate];
        timerLabel.textColor = textCol;
    }
    else if(self.timerState == RUNNING) {
        [dctTimer invalidate];
    }
    self.timerState = STOP;
    btnScrType.hidden = NO;
    scrambleView.hidden = NO;
    if(hideScr) scrLabel.hidden = NO;
    if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:NO];
    else {
        [self hideTabBar:NO];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void) setScrLblFont {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if ([DCTUtils isPad]) {
        if(type==0 || type==7 || type==13 || type==10)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:32]];
        else if(type==1)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:30]];
        else if(type==2)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:28]];
        else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:26]];
    }
    else if(type==0 || type==7 || type==13 || type==10) //二阶、金字塔、齿轮、斜转
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:20]];
    else if(type==1 || type==17)    //三阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:18]];
    else if(type==3)    //五阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:15]];
    else if(type==4)    //六阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:14]];
    else if(type==5)    //七阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:13]];
    else if(type==6)    //五魔
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:monoFont ? 11.5 : 13]];
    else if(type==11) { //MNL
        if(sub==0) [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:20]];
        else if (sub==8)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:16]];
        else if(sub==9 || sub==10)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:monoFont ? 12 : 13]];
        else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:17]];
    } else if(type==16) {
        if (sub==2)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:16]];
        else if(sub==3)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:13]];
        else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:17]];
    }
    else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Arial" size:17]];
}

- (void) newScramble:(bool)tych {
    typeChanged = tych;
    if(tych) isNextScr = false;
    //lastScr = currentScr;
    if(canScr) {
        canScr = false;
        scrLabel.text = NSLocalizedString(@"scrambling", @"");
        [NSThread detachNewThreadSelector:@selector(getScramble) toTarget:self withObject:nil];
    }
}

- (void) getScramble {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if(!typeChanged && isNextScr) {
        currentScr = nextScr;
        isNextScr = false;
    }
    else currentScr = [self.scrambler getScrString:selScrType];
    if(type==1 && sub<2 && cxe != 0) {
        if(cxe==1)
            extsol = [self.scrambler solveCross:currentScr side:(int)cside];
        else if(cxe==2)
            extsol = [self.scrambler solveXcross:currentScr side:(int)cside];
        else if(cxe==3)
            extsol = [self.scrambler solveEoline:currentScr side:(int)cside];
        isExts = true;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    } else if(type==8 && sub<3 && sqshp!=0) {
        extsol = [self.scrambler solveSqShape:currentScr m:(int)sqshp];
        isExts = true;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    } else {
        isExts = false;
        [self performSelectorOnMainThread:@selector(showScramble) withObject:nil waitUntilDone:YES];
    }
    if(type==1 || type==8)
        [self setNextScr];
}

- (void)setNextScr {
    isNextScr = false;
    nextScr = [self.scrambler getScrString:selScrType];
    NSLog(@"next scr: %@", nextScr);
    isNextScr = true;
}

- (void)showScramble {
    canScr = true;
    if(isExts) {
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else scrLabel.text = currentScr;
    [self.scrambleView setNeedsDisplay];
}

- (void)extraSolve {
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if(type==1 && sub<2 && cxe != 0) {
        if(cxe==1)
            extsol = [self.scrambler solveCross:currentScr side:(int)cside];
        else if(cxe==2)
            extsol = [self.scrambler solveXcross:currentScr side:(int)cside];
        else if(cxe==3)
            extsol = [self.scrambler solveEoline:currentScr side:(int)cside];
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else if(type==8 && sqshp!=0) {
        extsol = [self.scrambler solveSqShape:currentScr m:(int)sqshp];
        scrLabel.text = [NSString stringWithFormat:@"%@\n%@", currentScr, extsol];
    }
    else scrLabel.text = currentScr;
}

- (void) loadDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    fTime = [[defaults objectForKey:@"freezeslide"] intValue];
    wcaInsp = [defaults boolForKey:@"wcainsp"];
    timerupd = [defaults integerForKey:@"timerupd"];
    timeForm = [defaults integerForKey:@"timeform"];
    accuracy = [defaults integerForKey:@"accuracy"];
    hideScr = [defaults boolForKey:@"hidescr"];
    promptTime = [defaults boolForKey:@"prompttime"];
    cxe = [defaults integerForKey:@"cxe"];
    cside = [defaults integerForKey:@"cside"];
    sqshp = [defaults integerForKey:@"sqshape"];
    currentSesIdx = (int)[defaults integerForKey:@"crntsesidx"];
    selScrType = (int)[defaults integerForKey:@"crntscrtype"];
    bgcolor = (int)[defaults integerForKey:@"bgcolor"];
    textcolor = (int)[defaults integerForKey:@"textcolor"];
    inTime = [defaults boolForKey:@"intime"];
    dropStop = [defaults boolForKey:@"drops"];
    showImg = [defaults boolForKey:@"showimg"];
    opacity = [defaults integerForKey:@"opacity"];
    int sens = (int)[defaults integerForKey:@"sensity"];
    sensity = 0.0176*sens*sens-1.84*sens+50;
    showScr = [defaults boolForKey:@"showscr"];
    tmSize = [defaults integerForKey:@"tmsize"];
    tmfont = [defaults integerForKey:@"tmfont"];
    monoFont = [defaults boolForKey:@"monofont"];
}

- (void)record:(int)time pen:(int)pen {
    NSDate *date = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:date];
    [[DCTData dbh] addTime:time penalty:pen scramble:currentScr datetime:nowtimeStr];
    [[DCTData dbh] insertTime:time pen:pen scr:currentScr date:nowtimeStr];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    int hei, wid, dlt = [DCTUtils isOS7] ? ([DCTUtils isPad] ? 13 : 20) : 0;
    CGSize frame = [DCTUtils getFrame];
    hei = frame.height; wid = frame.width;
    if(wid == 748) {
        hei = frame.width; wid = frame.height;
    }
    if([DCTUtils isPad]) [scrambleView setFrame:CGRectMake(wid-325, hei-294+dlt, 321, 241)];
    else [scrambleView setFrame:CGRectMake(wid-223, hei-216+dlt, 221, 165)];
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
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger typeOld = [def integerForKey:@"crntscrtype"];
    if(selScrType != typeOld) {
        [btnScrType setTitle:scr forState:UIControlStateNormal];
        [self newScramble:true];
        [self setScrLblFont];
        [def setInteger:selScrType forKey:@"crntscrtype"];
    }
    [scrPop dismissPopoverAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if(alertView.tag!=0)
                inspState = 1;
            if(alertView.tag == 1)
                [self newScramble:false];
            break;
        case 1:
            switch (alertView.tag) {
                case 1:
                {
                    int time = inspState==2?resTime+2000:resTime;
                    [self record:time pen:0];
                    inspState = 1;
                    [self newScramble:false];
                    break;
                }
                case 2:
                    [self record:resTime pen:2];
                    inspState = 1;
                    [self newScramble:false];
                    break;
                case 3:
                    [[DCTData dbh] deleteTimeAtIndex:[[DCTData dbh] numberOfSolves]-1];
                    [[DCTData dbh] deleteTime:[[DCTData dbh] numberOfSolves]];
                    if(!inTime) {
                        if([[DCTData dbh] numberOfSolves] == 0) timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                        else timerLabel.text = [DCTData distimeAtIndex:[[DCTData dbh] numberOfSolves]-1 dt:false];
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
                    [self newScramble:false];
                    break;
                }
                case 5:
                    [[DCTData dbh] clearSession:currentSesIdx];
                    timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                    break;
                case 6:
                    [self change:[[DCTData dbh] numberOfSolves]-1 pen:0];
                    break;
            }
            break;
        case 2:
        {
            if(alertView.tag==6) {
                [self change:[[DCTData dbh] numberOfSolves]-1 pen:1];
            } else {
                int time = inspState==2?resTime+2000:resTime;
                [self record:time pen:1];
                inspState = 1;
                [self newScramble:false];
            }
            break;
        }
        case 3:
        {
            if(alertView.tag==6) {
                [self change:[[DCTData dbh] numberOfSolves]-1 pen:2];
            } else {
                int time = inspState==2?resTime+2000:resTime;
                [self record:time pen:2];
                inspState = 1;
                [self newScramble:false];
            }
            break;
        }
        default:
            break;
    }
}

- (void) change:(int)idx pen:(int)pen {
    [[DCTData dbh] setPenalty:pen atIndex:idx];
    [[DCTData dbh] updateTime:idx pen:pen];
    if(!inTime) self.timerLabel.text = [DCTData distimeAtIndex:idx dt:false];
}

- (NSString *)contime:(int)i {
    bool m = i<0;
    if(m)i = -i;
    i/=1000;
    int sec = i;
    int min = 0, hour = 0;
    if(timeForm < 2) {
        min = sec / 60;
        sec %= 60;
        if(timeForm < 1) {
            hour = min / 60;
            min %= 60;
        }
    }
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
    time1 = (int) ((timeNow - timeStart) * info.numer / info.denom / 1000000);
    if(timerupd == 0) timerLabel.text = [DCTUtils distime:time1];
    else if(timerupd == 1) timerLabel.text = [self contime:time1];
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

- (void)stopTimer {
    uint64_t timeEnd = mach_absolute_time();
    [dctTimer invalidate];
    resTime = (int) ((timeEnd - timeStart) * info.numer / info.denom / 1000000);
    timerLabel.text = [DCTUtils distime:resTime];
    btnScrType.hidden = NO;
    scrambleView.hidden = NO;
    if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:NO];
    else [self hideTabBar:NO];
    if(hideScr) scrLabel.hidden = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self performSelectorOnMainThread:@selector(confirmSave) withObject:nil waitUntilDone:YES];
}

- (void)confirmSave {
    self.timerState = STOP;
    if(promptTime) {
        int time = (inspState==2)?resTime+2000:resTime;
        if(inspState==3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@: DNF", NSLocalizedString(@"time", @"")] message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"save", @""), nil];
            [alert setTag:2];
            [alert show];
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
        [self newScramble:false];
    }
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
    switch (self.timerState) {
        case STOP:
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
        case RUNNING:
        {
            uint64_t timeEnd = mach_absolute_time();
            [dctTimer invalidate];
            resTime = (int) ((timeEnd - timeStart) * info.numer / info.denom / 1000000);
            timerLabel.text = [DCTUtils distime:resTime];
            btnScrType.hidden = NO;
            scrambleView.hidden = NO;
            if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:NO];
            else [self hideTabBar:NO];
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
    self.timerState = STOP;
    inspState = 1;
    swipeType = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    timerLabel.textColor = textCol;
    if(swipeType > 0) {
        isChange = true;
        [fTimer invalidate];
        switch (swipeType) {
            case 2:
                if([[DCTData dbh] numberOfSolves]>0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"deletelast", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
                    [alert setTag:3];
                    [alert show];
                }
                break;
            case 3:
                if([[DCTData dbh] numberOfSolves]>0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"conf_delses", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
                    [alert setTag:5];
                    [alert show];
                }
                break;
            case 4:
                if([[DCTData dbh] numberOfSolves]>0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"last_solve", @""), [DCTData distimeAtIndex:[[DCTData dbh] numberOfSolves]-1 dt:true]] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"") otherButtonTitles:NSLocalizedString(@"nopen", @""), @"+2", @"DNF", nil];
                    [alert setTag:6];
                    [alert show];
                }
                break;
            default:
                break;
        }
    }
    else {
        switch (self.timerState) {
            case STOP:
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
                    time1 = 0;
                    timeStart = mach_absolute_time();
                    if(wcaInsp) {
                        timerLabel.textColor = [UIColor redColor];
                        inspTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateInspTime) userInfo:nil repeats:YES];
                        self.timerState = INSPECTING;
                    } else {
                        dctTimer = [NSTimer scheduledTimerWithTimeInterval:(timerupd==0 ? 0.017 : 0.1) target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                        self.timerState = RUNNING;
                    }
                    btnScrType.hidden = YES;
                    scrambleView.hidden = YES;
                    if([DCTUtils isOS7]) [self.tabBarController.tabBar setHidden:YES];
                    else {
                        [self hideTabBar:YES];
                    }
                    if(hideScr) scrLabel.hidden = YES;
                    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                } else {
                    [fTimer invalidate];
                    timerLabel.textColor = textCol;
                }
                break;
            case RUNNING:
            {
                [self confirmSave];
                break;
            }
            case INSPECTING:
                if(canStart) {
                    time1 = 0;
                    timeStart = mach_absolute_time();
                    [inspTimer invalidate];
                    dctTimer = [NSTimer scheduledTimerWithTimeInterval:0.017 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    self.timerState = RUNNING;
                } else {
                    [fTimer invalidate];
                    timerLabel.textColor = [UIColor redColor];
                }
                break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(timerState == STOP) {
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
                    [self newScramble:false];
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
