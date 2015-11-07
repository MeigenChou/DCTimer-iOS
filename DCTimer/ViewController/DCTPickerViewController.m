//
//  DCTPickerViewController.m
//  DCTimer
//
//  Created by MeigenChou on 14-1-1.
//
//

#import "DCTPickerViewController.h"
#import "DCTFirstViewController.h"
#import "DCTUtils.h"
#define typeComponentWidth 128
#define subsetComponentWidth 138

@interface DCTPickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UIToolbar *pickerToolBar;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;
@property (nonatomic, strong) UIPickerView *picker;
@end

@implementation DCTPickerViewController
@synthesize delegate = _delegate;
NSUInteger selectedType;
NSUInteger selectedSubset;
extern int selScrType;
NSString *selScrName;
extern NSArray *types;
extern NSArray *subsets;
extern NSDictionary *scrType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 290, 44)];
    [self.view addSubview:_pickerToolBar];
    _doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _pickerToolBar.items = @[flexibleSpace, _doneButtonItem];
    
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, 290, 216)];
    if([DCTUtils isOS7]) [_picker setBackgroundColor:[UIColor whiteColor]];
    else {
        _picker.showsSelectionIndicator = YES;
    }
    _picker.opaque = YES;
    [_picker setDelegate:self];
    [_picker setDataSource:self];
    [self.view addSubview:_picker];
    selectedType = selScrType >> 5;
    selectedSubset = selScrType & 31;
    [_picker selectRow:selectedType inComponent:0 animated:YES];
    [_picker selectRow:selectedSubset inComponent:1 animated:YES];
    selScrName = [NSString stringWithFormat:@"%@ - %@", [types objectAtIndex:selectedType], [subsets objectAtIndex:selectedSubset]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    if ([self.delegate respondsToSelector:@selector(setScr:)]) {
        [self.delegate setScr:selScrName];
    }
}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    if (component == 0) {
        return [types count];
    } else {
        return [subsets count];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return typeComponentWidth;
    } else {
        return subsetComponentWidth;
    }
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        NSString *selType = [types objectAtIndex:row];
        NSArray *array = [scrType objectForKey:selType];
        subsets = array;
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView reloadComponent:1];
    }
    selectedType = [pickerView selectedRowInComponent:0];
    selectedSubset = [pickerView selectedRowInComponent:1];
    selScrType = (int)(selectedType << 5 | selectedSubset);
    selScrName = [NSString stringWithFormat:@"%@ - %@", [types objectAtIndex:selectedType], [subsets objectAtIndex:selectedSubset]];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *printString;
    if (component == 0) {
        printString = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, typeComponentWidth, 45)];
        printString.text = [types objectAtIndex:row];
        //[printString setFont:[UIFont fontWithName:@"Georgia" size:12.0f]];
    } else {
        printString = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, subsetComponentWidth, 45)];
        printString.text = [subsets objectAtIndex:row];
    }
    printString.backgroundColor = [UIColor clearColor];
    printString.textAlignment = UITextAlignmentCenter;
    return printString;
}
@end
