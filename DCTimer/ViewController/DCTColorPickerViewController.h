//
//  DCTColorPickerViewController.h
//  DCTimer
//
//  Created by MeigenChou on 13-4-9.
//
//

#import <UIKit/UIKit.h>

@interface DCTColorPickerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISlider *c1slider;
@property (strong, nonatomic) IBOutlet UISlider *c2slider;
@property (strong, nonatomic) IBOutlet UISlider *c3slider;
@property (strong, nonatomic) IBOutlet UILabel *c1label;
@property (strong, nonatomic) IBOutlet UILabel *c2label;
@property (strong, nonatomic) IBOutlet UILabel *c3label;
@property (nonatomic, strong) NSNumber *crntColor;
@property (nonatomic, strong) NSString *defkey;
- (IBAction)segChanged:(UISegmentedControl *)sender;
- (IBAction)sliderChanged:(UISlider *)sender;

@end
