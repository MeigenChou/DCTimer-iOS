//
//  DCTFirstViewController.h
//  DCTimer
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "FPPopoverController.h"
#import "ARCMacros.h"
#import "FPPopoverController.h"

typedef enum timerState {
    STOP = 0,
    RUNNING = 1,
    INSPECTING = 2,
} TimerState;

@interface DCTFirstViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, FPPopoverControllerDelegate> {
    FPPopoverController *popover;
    FPPopoverController *scrPop;
    int inspState;  //2-观察 2-+2 3-DNF
    int resTime;
    int time1;
    uint64_t timeStart;
    NSInteger swipeType;
    bool isChange;
    bool canStart, isNextScr;
    int bgcolor, textcolor;
    bool isExts;
    double sensity;
    NSInteger tmSize;
    bool typeChanged;
    bool canScr;
    NSInteger opacity;
    BOOL monoFont;
}
@property (strong, nonatomic) IBOutlet UILabel *scrLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnScrType;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property CGPoint gestureStartPoint;
@property (strong, nonatomic) CMMotionManager *motionMag;
- (IBAction)selScrambleType:(id)sender;

//- (void)selectedTableRow: (NSUInteger)rowNum;
- (void)setScr: (NSString *)scr;
@end
