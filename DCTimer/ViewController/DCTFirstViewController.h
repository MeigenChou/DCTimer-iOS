//
//  DCTFirstViewController.h
//  DCTimer
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "ARCMacros.h"
#import "FPPopoverController.h"

@interface DCTFirstViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, FPPopoverControllerDelegate> {
    FPPopoverController *popover;
    FPPopoverController *scrPop;
    int swipeType;
    bool isChange;
}
@property (strong, nonatomic) IBOutlet UIButton *btnScrView;
@property (strong, nonatomic) IBOutlet UILabel *scrLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnScrType;
@property CGPoint gestureStartPoint;

- (IBAction)selScrambleType:(id)sender;
- (IBAction)drawScrView:(id)sender;

//- (void)selectedTableRow: (NSUInteger)rowNum;
- (void)setScr: (NSString *)scr;
@end
