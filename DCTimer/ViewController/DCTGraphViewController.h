//
//  DCTGraphViewController.h
//  DCTimer
//
//  Created by meigen on 15-1-6.
//
//

#import <UIKit/UIKit.h>
#import "DCTGraphView.h"

@interface DCTGraphViewController : UIViewController

@property (nonatomic, strong) DCTGraphView *graphView;
@property (nonatomic, strong) UISegmentedControl *segment;

@end
