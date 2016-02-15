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
#import "Search4.h"
#import "TwoPhaseScrambler.h"
#import <mach/mach_time.h>
#import <AVFoundation/AVFoundation.h>

@interface DCTFirstViewController()
@property (nonatomic, strong) Scrambler *scrambler;
@property (nonatomic, strong) UIColor *textCol;
@property (nonatomic, strong) NSTimer *dctTimer;
@property (nonatomic, strong) NSTimer *fTimer;
@property (nonatomic, strong) NSString *extsol;
@property (nonatomic, strong) DCTScrambleView *scrambleView;
@property (nonatomic) TimerState timerState;
@property (nonatomic, strong) NSString *nextScr;
@end

@implementation DCTFirstViewController
@synthesize scrLabel,timerLabel;
@synthesize btnScrType;
@synthesize scrambler;
@synthesize gestureStartPoint;
@synthesize textCol;
@synthesize dctTimer, fTimer;
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
extern BOOL showImg, switchSession, switchScramble;
extern NSInteger cside, cxe, sqshp;
extern NSInteger minxcs;
extern BOOL tfChanged, imgChanged, svChanged, monoChanged;
int currentSesIdx;  //extern
int selScrType; //extern
int chScrType;  //extern
NSDictionary *scrType;  //extern
NSArray *types; //extern
NSArray *subsets;   //extern
bool esChanged = false; //extern
BOOL sayAlerts; //extern
extern NSInteger tmfont;
extern NSInteger gestures[4];

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [DCTUtils getString:@"timer"];
        self.tabBarItem.image = [UIImage imageNamed:@"img1"];
        self.scrambler = [[Scrambler alloc] init];
        mach_timebase_info(&info);
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        fonts = [[NSArray alloc] initWithObjects:@"Arial", @"Courier New", @"Digiface", @"Georgia", @"Kannada Sangam MN", @"Times New Roman", @"Kannada Sangam MN", nil];
        time1 = 0;
        lowZ = 0.98;
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
    isSwipe = false;
    if(inTime) timerLabel.text = @"IMPORT";
    else if(accuracy == 1) timerLabel.text = @"0.00";
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    isNextScr = false;
    typeChanged = true;
    canScr = true;
    NSString *lang = [DCTUtils getString:@"language"];
    //NSLog(@"language: %@", lang);
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
    selScrType = chScrType = type << 5 | sub;
    if(selScrType != 32) [scrambler getScrString:32];
    currentScr = [scrambler getScrString:selScrType];
    [self extraSolve];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selScrType forKey:@"crntscrtype"];
    
    if ([DCTUtils isOS7]) {
        /*if ([DCTUtils isPad]) {
            scrLabel.frame = CGRectMake(20, 96, 728, 280);
            timerLabel.frame = CGRectMake(20, 430, 728, 200);
        } else {
            scrLabel.frame = CGRectMake(10, 50, 300, 160);
            timerLabel.frame = CGRectMake(10, 186, 300, 100);
        }*/
    } else {
        CGRect rect = CGRectMake(0, 0, btnScrType.frame.size.width, 35);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0].CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [btnScrType setBackgroundImage:image forState:UIControlStateNormal];
        [btnScrType setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    //[NSThread detachNewThreadSelector:@selector(setNextScr) toTarget:self withObject:nil];
    [[DCTData dbh] getSessions];
    int sesnum = [[DCTData dbh] getSessionCount];
    if(currentSesIdx > sesnum) {
        currentSesIdx = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"crntsesidx"];
    }
    [[DCTData dbh] query:currentSesIdx];
    int hei, dlt = [DCTUtils isOS7] ? ([DCTUtils isPad] ? 13 : 20) : 0;
    CGSize frame = [DCTUtils getFrame];
    hei = frame.height; cWid = frame.width;
    //NSLog(@"width %d", cWid);
    if(cWid == 748) {
        hei = frame.width; cWid = frame.height;
    }
    [self setScrLblFont];
    if([DCTUtils isPad]) scrambleView = [[DCTScrambleView alloc] initWithFrame:CGRectMake(cWid-325, hei-294+dlt, 321, 241)];
    else scrambleView = [[DCTScrambleView alloc] initWithFrame:CGRectMake(cWid*0.368, hei-50-(cWid*0.469)+dlt, cWid*0.628, cWid*0.469)];
    scrambleView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    [self.view addSubview:scrambleView];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
    if(showImg) imgChanged = YES;
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
    
    //NSArray *fontl = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
    /*for (NSString *fname in fontl) {
        NSLog(@"family: %s\n", [fname UTF8String]);
        NSArray *fontn = [UIFont fontNamesForFamilyName:fname];
        for(NSString *fn in fontn) {
            NSLog(@" font: %s\n", [fn UTF8String]);
        }
    }*/
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
    if(showImg) {
        if(imgChanged) {
            UIImage *image = [UIImage imageWithContentsOfFile:[DCTUtils getFilePath:@"bg.png"]];
            [imageView setImage:image];
            imgChanged = NO;
        }
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [imageView setAlpha:opacity / 100.0];
    } else {
        if(imgChanged) [imageView setImage:nil];
        int r = (bgcolor>>16)&0xff;
        int g = (bgcolor>>8)&0xff;
        int b = bgcolor&0xff;
        [self.view setBackgroundColor:[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]];
    }
    int r = (textcolor>>16)&0xff;
    int g = (textcolor>>8)&0xff;
    int b = textcolor&0xff;
    textCol = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    self.scrLabel.textColor = textCol;
    timerLabel.textColor = textCol;
    if([DCTUtils isPad]) {
        timerLabel.font = [UIFont fontWithName:[fonts objectAtIndex:tmfont] size:tmSize];
    } else timerLabel.font = [UIFont fontWithName:[fonts objectAtIndex:tmfont] size:65*cWid/320];
    if(tfChanged) {
        if(inTime) {
            timerLabel.text = @"IMPORT";
        } else {
            timerLabel.text = accuracy == 1 ? @"0.00" : @"0.000";
        }
        tfChanged = NO;
    }
    if(esChanged) {
        [self extraSolve];
        esChanged = false;
    }
    if(svChanged) {
        [self.scrambleView setNeedsDisplay];
        svChanged = NO;
    }
    if (monoChanged) {
        [self setScrLblFont];
        monoChanged = NO;
    }
    if(chScrType != -1 && selScrType != chScrType) {
        selScrType = chScrType;
        NSString *select = [types objectAtIndex:chScrType>>5];
        subsets = [scrType objectForKey:select];
        [btnScrType setTitle:[NSString stringWithFormat:@"%@ - %@", select, [subsets objectAtIndex:chScrType&31]] forState:UIControlStateNormal];
        [self newScramble:true];
        [self setScrLblFont];
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setInteger:selScrType forKey:@"crntscrtype"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if(timerState == INSPECTING) {
        [dctTimer invalidate];
        dctTimer = nil;
        timerLabel.textColor = textCol;
    }
    else if(timerState == RUNNING) {
        [dctTimer invalidate];
        dctTimer = nil;
    }
    timerState = STOP;
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
    } else if(type==0 || type==7 || type==13 || type==10) //二阶、金字塔、齿轮、斜转
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 26 : (cWid==375 ? 24 : 20)]];
    else if(type==1 || type==17)    //三阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 24 : (cWid==375 ? 22 : 18)]];
    else if(type==3)    //五阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 21 : (cWid==375 ? 19 : 16)]];
    else if(type==4)    //六阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 20 : (cWid==375 ? 18 : 14)]];
    else if(type==5)    //七阶
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 18 : (cWid==375 ? 16 : 12)]];
    else if(type==6) {   //五魔
        float ssize = cWid==414 ? 17 : (cWid==375 ? 15 : 13.5);
        float msize = cWid==414 ? 15 : (cWid==375 ? 13.5 : 11.5);
        [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:monoFont ? msize : ssize]];
    } else if(type==11) { //MNL
        if(sub==0) [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 26 : (cWid==375 ? 24 : 20)]];
        else if (sub==8)
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 21 : (cWid==375 ? 19 : 16)]];
        else if(sub==9 || sub==10) {
            int ssize = cWid==414 ? 18 : (cWid==375 ? 16 : 13);
            int msize = cWid==414 ? 15.5 : (cWid==375 ? 14 : 12);
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:monoFont ? msize : ssize]];
        }
        else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 22 : (cWid==375 ? 20 : 17)]];
    } else if(type==16) {   //其他
        if (sub==2) //SQ2
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 21 : (cWid==375 ? 19 : 16)]];
        else if(sub==3) //SSQ1
            [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 18 : (cWid==375 ? 16 : 13)]];
        else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 22 : (cWid==375 ? 20 : 17)]];
    } else [self.scrLabel setFont:[UIFont fontWithName:monoFont ? @"Courier" : @"Kannada Sangam MN" size:cWid==414 ? 22 : (cWid==375 ? 20 : 17)]];
}

- (void)newScramble:(bool)tych {
    typeChanged = tych;
    if(tych) isNextScr = false;
    //lastScr = currentScr;
    if(canScr) {
        canScr = false;
        scrLabel.text = [DCTUtils getString:@"scrambling"];
        [NSThread detachNewThreadSelector:@selector(getScramble) toTarget:self withObject:nil];
    }
}

- (void)getScramble {
    btnScrType.enabled = NO;
    int type = selScrType >> 5;
    int sub = selScrType & 31;
    if(!typeChanged && isNextScr) {
        currentScr = nextScr;
        isNextScr = false;
    } else {
        if(type==2 && sub==5) {
            scrLabel.text = [DCTUtils getString:@"initing"];
            //[Search initTable];
            [Search4 initTable];
            [self performSelectorOnMainThread:@selector(setScring) withObject:nil waitUntilDone:YES];
        }
        currentScr = [self.scrambler getScrString:selScrType];
    }
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
    btnScrType.enabled = YES;
    if(type==1 || (type==2&&sub==5) || type==8) {
        [self setNextScr];
        
    }
}

- (void)setNextScr {
    NSLog(@"get next scramble...");
    isNextScr = false;
    nextScr = [self.scrambler getScrString:selScrType];
    NSLog(@"next scramble: %@", nextScr);
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

-(void)setScring {
    scrLabel.text = [DCTUtils getString:@"scrambling"];
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
    currentSesIdx = (int)[defaults integerForKey:@"crntsesidx"];
    selScrType = (int)[defaults integerForKey:@"crntscrtype"];
    
    wcaInsp = [defaults boolForKey:@"wcainsp"];
    timeForm = [defaults integerForKey:@"timeform"];
    timerupd = [defaults integerForKey:@"timerupd"];
    accuracy = [defaults integerForKey:@"accuracy"];
    fTime = [[defaults objectForKey:@"freezeslide"] intValue];
    inTime = [defaults boolForKey:@"intime"];
    dropStop = [defaults boolForKey:@"drops"];
    int sens = (int)[defaults integerForKey:@"sensity"];
    sensity = 0.0176*sens*sens-1.84*sens+50;
    sayAlerts = [defaults boolForKey:@"sayalerts"];
    
    hideScr = [defaults boolForKey:@"hidescr"];
    monoFont = [defaults boolForKey:@"monofont"];
    
    promptTime = [defaults boolForKey:@"prompttime"];
    showScr = [defaults boolForKey:@"showscr"];
    switchSession = [defaults boolForKey:@"changesession"];
    switchScramble = [defaults boolForKey:@"changescramble"];
    
    cxe = [defaults integerForKey:@"cxe"];
    cside = [defaults integerForKey:@"cside"];
    sqshp = [defaults integerForKey:@"sqshape"];
    
    minxcs = [defaults integerForKey:@"minxcs"];
    
    bgcolor = (int)[defaults integerForKey:@"bgcolor"];
    textcolor = (int)[defaults integerForKey:@"textcolor"];
    opacity = [defaults integerForKey:@"opacity"];
    showImg = [defaults boolForKey:@"showimg"];
    tmfont = [defaults integerForKey:@"tmfont"];
    tmSize = [defaults integerForKey:@"tmsize"];
    
    gestures[0] = [defaults integerForKey:@"gestl"];
    gestures[1] = [defaults integerForKey:@"gestr"];
    gestures[2] = [defaults integerForKey:@"gestu"];
    gestures[3] = [defaults integerForKey:@"gestd"];
}

- (void)record:(int)time pen:(int)pen {
    NSDate *date = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:date];
    [[DCTData dbh] addTime:time penalty:pen scramble:currentScr datetime:nowtimeStr];
    [[DCTData dbh] insertTime:time pen:pen scr:currentScr date:nowtimeStr];
    [[DCTData dbh] saveScrambleType:selScrType];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"should ori %ld", (long)interfaceOrientation);
    // Return YES for supported orientations
    if ([DCTUtils isPhone]) {
        //return YES;
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"will ori %ld", (long)interfaceOrientation);
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

- (void)setScr:(NSString *)scr {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSInteger typeOld = [def integerForKey:@"crntscrtype"];
    if(selScrType != typeOld) {
        chScrType = selScrType;
        [btnScrType setTitle:scr forState:UIControlStateNormal];
        [self newScramble:true];
        [self setScrLblFont];
        [def setInteger:selScrType forKey:@"crntscrtype"];
        if(switchSession) { //自动切换分组
            int sesType = [[DCTData dbh] getScrambleType:currentSesIdx];
            if(sesType != -1 && sesType != selScrType) {
                int sessions = [[DCTData dbh] getSessionCount] + 1;
                for(int i=0; i<sessions; i++)
                    if([[DCTData dbh] getScrambleType:i] == selScrType) {
                        currentSesIdx = i;
                        [def setInteger:currentSesIdx forKey:@"crntsesidx"];
                        [[DCTData dbh] query:currentSesIdx];
                        break;
                    }
            }
        }
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
                case 1: //无惩罚
                {
                    int time = inspState==2?resTime+2000:resTime;
                    [self record:time pen:0];
                    inspState = 1;
                    [self newScramble:false];
                    break;
                }
                case 2: //记录DNF成绩
                    [self record:resTime pen:2];
                    inspState = 1;
                    [self newScramble:false];
                    break;
                case 3: //删除上次成绩
                    [[DCTData dbh] deleteTimeAtIndex:[[DCTData dbh] numberOfSolves]-1];
                    [[DCTData dbh] deleteTime:[[DCTData dbh] numberOfSolves]];
                    if(!inTime) {
                        if([[DCTData dbh] numberOfSolves] == 0) timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                        else timerLabel.text = [DCTData distimeAtIndex:[[DCTData dbh] numberOfSolves]-1 dt:false];
                    }
                    break;
                case 4: //手动输入时间
                {
                    UITextField *tf = [alertView textFieldAtIndex:0];
                    NSString *time = [DCTUtils convStr:[DCTUtils replace:tf.text str:@"：" with:@":"]];
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:[DCTUtils getString:@"invalid_input"] delegate:self cancelButtonTitle:[DCTUtils getString:@"close"] otherButtonTitles:nil];
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
                case 5: //清空分组成绩
                    [[DCTData dbh] clearSession:currentSesIdx];
                    timerLabel.text = accuracy==0 ? @"0.000" : @"0.00";
                    break;
                case 6: //修改上次成绩：无惩罚
                    [self change:[[DCTData dbh] numberOfSolves]-1 pen:0];
                    break;
            }
            break;
        case 2:
        {
            if(alertView.tag==6) {  //修改上次成绩：+2
                [self change:[[DCTData dbh] numberOfSolves]-1 pen:1];
            } else {    //+2
                int time = inspState==2 ? resTime+2000 : resTime;
                [self record:time pen:1];
                inspState = 1;
                [self newScramble:false];
            }
            break;
        }
        case 3:
        {
            if(alertView.tag==6) {  //修改上次成绩：DNF
                [self change:[[DCTData dbh] numberOfSolves]-1 pen:2];
            } else {    //DNF
                int time = inspState==2 ? resTime+2000 : resTime;
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

- (void)change:(int)idx pen:(int)pen {
    [[DCTData dbh] setPenalty:pen atIndex:idx];
    [[DCTData dbh] updateTime:idx pen:pen];
    if(!inTime) self.timerLabel.text = [DCTData distimeAtIndex:idx dt:false];
}

- (void)updateTime {
    if(timerState != RUNNING) return;
    uint64_t timeNow = mach_absolute_time();
    time1 = (int) ((timeNow - timeStart) * info.numer / info.denom / 1000000);
    if(timerupd == 0) timerLabel.text = [DCTUtils distime:time1];
    else if(timerupd == 1) timerLabel.text = [DCTUtils distimeSec:time1];
    else timerLabel.text = [DCTUtils getString:@"solving"];
}

- (void)updateInspTime {
    if(timerState != INSPECTING) return;
    uint64_t timeNow = mach_absolute_time();
    int time = (int) ((timeNow - timeStart) * info.numer / info.denom / 1000000000);
    if(time < 15) {
        if(timerupd < 3) timerLabel.text = [NSString stringWithFormat:@"%d", time];
        else timerLabel.text = [DCTUtils getString:@"inspecting"];
        inspState = 1;
        if(sayAlerts && [DCTUtils isOS7] && time == 8 && !is8Sec) {
            is8Sec = YES;
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[DCTUtils getString:@"eight_second"]];
            utterance.rate = 0.4;
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            [synth speakUtterance:utterance];
        }
        if(sayAlerts && [DCTUtils isOS7] && time == 12 && !is12Sec) {
            is12Sec = YES;
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[DCTUtils getString:@"twelve_second"]];
            utterance.rate = 0.4;
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            [synth speakUtterance:utterance];
        }
    } else if(time < 17) {
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
    dctTimer = nil;
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
    int time = inspState==2 ? resTime+2000 : resTime;
    if(promptTime) {
        if(inspState==3) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@: DNF (%@)", [DCTUtils getString:@"time"], [DCTUtils distime:time]] message:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"save"], nil];
            [alert setTag:2];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@: %@", [DCTUtils getString:@"time"], [DCTUtils distime:time]] message:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"no_penalty"], @"+2", @"DNF", nil];
            [alert setTag:1];
            [alert show];
        }
    } else {
        int pen = inspState==3 ? 2 : 0;
        [self record:time pen:pen];
        inspState = 1;
        [self newScramble:false];
    }
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    gestureStartPoint = [touch locationInView:self.view];
    switch (timerState) {
        case STOP:
            if(dctTimer != nil) {
                //NSLog(@"timer != nil");
                [dctTimer invalidate];
            }
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
            dctTimer = nil;
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
    timerState = STOP;
    inspState = 1;
    swipeType = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    timerLabel.textColor = textCol;
    if(isSwipe) {
        [fTimer invalidate];
        isSwipe = false;
        switch (swipeType) {
            case 1: //删除上一次成绩
                if([[DCTData dbh] numberOfSolves] > 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[DCTUtils getString:@"delete_last"] message:nil delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"ok"], nil];
                    [alert setTag:3];
                    [alert show];
                }
                break;
            case 2: //生成新打乱
                [self newScramble:false];
                break;
            case 4: //删除所有成绩
                if([[DCTData dbh] numberOfSolves]>0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[DCTUtils getString:@"confirm_clear"] message:nil delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"ok"], nil];
                    [alert setTag:5];
                    [alert show];
                }
                break;
            case 3: //上一次成绩
                if([[DCTData dbh] numberOfSolves] > 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@%@", [DCTUtils getString:@"last_solve"], [DCTData distimeAtIndex:[[DCTData dbh] numberOfSolves]-1 dt:true]] message:nil delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"no_penalty"], @"+2", @"DNF", nil];
                    [alert setTag:6];
                    [alert show];
                }
                break;
            case 5: //手动输入成绩
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[DCTUtils getString:@"input_time"] message:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"done"], nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [alert textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                [alert setTag:4];
                [alert show];
                break;
            }
        }
    } else switch (self.timerState) {
        case STOP:
            if(inTime) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[DCTUtils getString:@"input_time"] message:@"" delegate:self cancelButtonTitle:[DCTUtils getString:@"cancel"] otherButtonTitles:[DCTUtils getString:@"done"], nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *tf = [alert textFieldAtIndex:0];
                tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                tf.clearButtonMode = UITextFieldViewModeWhileEditing;
                [alert setTag:4];
                [alert show];
            } else if(canStart) {
                time1 = 0;
                timeStart = mach_absolute_time();
                if(wcaInsp) {
                    is8Sec = is12Sec = NO;
                    timerLabel.textColor = [UIColor redColor];
                    dctTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateInspTime) userInfo:nil repeats:YES];
                    self.timerState = INSPECTING;
                } else {
                    dctTimer = [NSTimer scheduledTimerWithTimeInterval:(timerupd==0 ? 0.023 : 0.1) target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
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
            timerState = STOP;
            [self confirmSave];
            break;
        case INSPECTING:
            if(canStart) {
                [dctTimer invalidate];
                time1 = 0;
                timeStart = mach_absolute_time();
                dctTimer = [NSTimer scheduledTimerWithTimeInterval:0.017 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                self.timerState = RUNNING;
            } else {
                [fTimer invalidate];
                timerLabel.textColor = [UIColor redColor];
            }
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(timerState == STOP) {
        UITouch *touch = [touches anyObject];
        CGPoint currentPo = [touch locationInView:self.view];
        CGFloat deltaX = currentPo.x - gestureStartPoint.x;
        CGFloat deltaY = currentPo.y - gestureStartPoint.y;
        if(fabsf((float)deltaY) <= 8) {
            if(deltaX > 30) {
                swipeType = gestures[1];
                if(!isSwipe) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    //[self newScramble:false];
                    isSwipe = true;
                }
            }
            else if(deltaX < -30) {
                swipeType = gestures[0];
                if(!isSwipe) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isSwipe = true;
                }
            }
        }
        if(fabsf((float)deltaX) <= 8) {
            if(deltaY > 30) {
                swipeType = gestures[3];
                if(!isSwipe) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isSwipe = true;
                }
            } else if(deltaY < -30) {
                swipeType = gestures[2];
                if(!isSwipe) {
                    timerLabel.textColor = textCol;
                    [fTimer invalidate];
                    isSwipe = true;
                }
            }
        }
    }
}
@end
