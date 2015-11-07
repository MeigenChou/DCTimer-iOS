//
//  DCTColorPickerController.h
//  DCTimer
//
//  Created by MeigenChou on 14-3-10.
//
//

#import <UIKit/UIKit.h>

@protocol DCTColorPickerControllerDelegate;

@interface DCTColorPickerController : UIViewController

+ (DCTColorPickerController *)colorPickerViewController;
+ (CGSize) idealSizeForViewInPopover;

@property (nonatomic) UIColor *sourceColor;
@property (nonatomic) UIColor *resultColor;
@property (nonatomic, strong) NSNumber *crntColor;
@property (nonatomic, strong) NSString *defkey;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) NSMutableArray *colorList;

@property (weak, nonatomic) id <DCTColorPickerControllerDelegate> delegate;

@end

@protocol DCTColorPickerControllerDelegate

@optional

- (void) colorPickerControllerDidFinish: (DCTColorPickerController *)controller;
// This is only called when the color picker is presented modally.

- (void) colorPickerControllerDidChangeColor: (DCTColorPickerController *)controller;

@end