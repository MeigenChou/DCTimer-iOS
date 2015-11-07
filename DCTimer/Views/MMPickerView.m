//
//  MMPickerView.m
//  MMPickerView
//
//  Created by Madjid Mahdjoubi on 6/5/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import "MMPickerView.h"
#import "DCTUtils.h"
#define componentCount 2
#define typeComponent 0
#define subsetComponent 1
#define typeComponentWidth 150
#define subsetComponentWidth 170

NSString * const MMfont = @"font";
NSString * const MMvalueY = @"yValueFromTop";
NSString * const MMselectedIdx = @"selectedIdx";
NSString * const MMtoolbarBackgroundImage = @"toolbarBackgroundImage";
NSString * const MMtextAlignment = @"textAlignment";
NSString * const MMshowsSelectionIndicator = @"showsSelectionIndicator";

@interface MMPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UILabel *pickerViewLabel;
@property (nonatomic, strong) UIView *pickerViewLabelView;
@property (nonatomic, strong) UIView *pickerContainerView;
@property (nonatomic, strong) UIView *pickerViewContainerView;
@property (nonatomic, strong) UIView *pickerTopBarView;
@property (nonatomic, strong) UIImageView *pickerTopBarImageView;
@property (nonatomic, strong) UIToolbar *pickerViewToolBar;
@property (nonatomic, strong) UIBarButtonItem *pickerViewBarButtonItem;
@property (nonatomic, strong) UIButton *pickerDoneButton;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIFont *pickerViewFont;

@property (nonatomic, assign) CGFloat yValueFromTop;
@property (nonatomic, assign) NSInteger pickerViewTextAlignment;
@property (nonatomic, assign) BOOL pickerViewShowsSelectionIndicator;
@property (copy) void (^onDismissCompletion)(NSString *);
//@property (copy) NSString *(^objectToStringConverter)(id object);

@end


@implementation MMPickerView
int selectedType = -1;
int selectedSubset;
int selScrType;
NSString *selScrName = @"3x3 - random state";
extern NSArray *types;
extern NSArray *subsets;
extern NSDictionary *scrType;

#pragma mark - Singleton

+ (MMPickerView*)sharedView {
  static dispatch_once_t once;
  static MMPickerView *sharedView;
  dispatch_once(&once, ^ { sharedView = [[self alloc] init]; });
  return sharedView;
}

#pragma mark - Show Methods

+(void)showPickerViewInView:(UIView *)view
                withOptions:(NSDictionary *)options
                 completion:(void (^)(NSString *)) completion {
  
  [[self sharedView] initializePickerViewInView:view
                                    withOptions:options];
  
  [[self sharedView] setPickerHidden:NO callBack:nil];
  [self sharedView].onDismissCompletion = completion;
  [view addSubview:[self sharedView]];
  
}

#pragma mark - Dismiss Methods

+(void)dismissWithCompletion:(void (^)(NSString *))completion{
  [[self sharedView] setPickerHidden:YES callBack:completion];
}

-(void)dismiss {
 [MMPickerView dismissWithCompletion:self.onDismissCompletion];
}

-(void) cancel {
    selScrType = -1;
    [MMPickerView dismissWithCompletion:self.onDismissCompletion];
}

+(void)removePickerView {
  [[self sharedView] removeFromSuperview];
}

#pragma mark - Show/hide PickerView methods

-(void)setPickerHidden: (BOOL)hidden
              callBack: (void(^)(NSString *))callBack; {
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         if (hidden) {
                             [_pickerViewContainerView setAlpha:0.0];
                             [_pickerContainerView setTransform:CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(_pickerContainerView.frame))];
                         } else {
                             [_pickerViewContainerView setAlpha:1.0];
                             [_pickerContainerView setTransform:CGAffineTransformIdentity];
                         }
                     } completion:^(BOOL completed) {
                         if(completed && hidden){
                             [MMPickerView removePickerView];
                             callBack([self selectedObject]);
                         }
                     }];
}

#pragma mark - Initialize PickerView

-(void)initializePickerViewInView: (UIView *)view
                      withOptions: (NSDictionary *)options {
    int selidx = [options[MMselectedIdx] intValue];
    selectedType = selidx >> 5;
    selectedSubset = selidx & 31;
    selScrType = selidx;
    
    NSNumber *textAlignment = [[NSNumber alloc] init];
    textAlignment = options[MMtextAlignment];
    //Default value is NSTextAlignmentCenter
    _pickerViewTextAlignment = 1;
    
    if (textAlignment != nil) {
        _pickerViewTextAlignment = [options[MMtextAlignment] integerValue];
    }
    
    BOOL showSelectionIndicator = [options[MMshowsSelectionIndicator] boolValue];
    
    if (!showSelectionIndicator) {
        _pickerViewShowsSelectionIndicator = 1;
    }
    _pickerViewShowsSelectionIndicator = showSelectionIndicator;
    
    UIColor *pickerViewBackgroundColor = [UIColor whiteColor];
    UIColor *toolbarBackgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:0.8];
    UIColor *buttonTextColor = [UIColor colorWithRed:0.000 green:0.486 blue:0.976 alpha:1];
    UIFont *pickerViewFont = [[UIFont alloc] init];
    pickerViewFont = options[MMfont];
    _yValueFromTop = [options[MMvalueY] floatValue];
    
    //[view bringSubviewToFront:self];
    [self setFrame: view.bounds];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImage * toolbarImage = options[MMtoolbarBackgroundImage];
    
    //Whole screen with PickerView and a dimmed background
    _pickerViewContainerView = [[UIView alloc] initWithFrame:view.bounds];
    [_pickerViewContainerView setBackgroundColor: [UIColor colorWithRed:0.412 green:0.412 blue:0.412 alpha:0.7]];
    [self addSubview:_pickerViewContainerView];
    
    //PickerView Container with top bar
    _pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _pickerViewContainerView.bounds.size.height - 260.0, 320.0, 260.0)];
    
    //Default Color Values (if colors == nil)
    
    if (pickerViewFont==nil) {
        _pickerViewFont = [UIFont systemFontOfSize:22];
    }
    _pickerViewFont = pickerViewFont;
    
    /*
     //ToolbackBackgroundImage - Clear Color
     if (toolbarBackgroundImage!=nil) {
     //Top bar imageView
     _pickerTopBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _pickerContainerView.frame.size.width, 44.0)];
     //[_pickerContainerView addSubview:_pickerTopBarImageView];
     _pickerTopBarImageView.image = toolbarBackgroundImage;
     [_pickerViewToolBar setHidden:YES];
     
     }
     */
    
    _pickerContainerView.backgroundColor = pickerViewBackgroundColor;
    [_pickerViewContainerView addSubview:_pickerContainerView];
    
    
    //Content of pickerContainerView
    
    //Top bar view
    _pickerTopBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _pickerContainerView.frame.size.width, 44.0)];
    [_pickerContainerView addSubview:_pickerTopBarView];
    [_pickerTopBarView setBackgroundColor:[UIColor whiteColor]];
    
    
    _pickerViewToolBar = [[UIToolbar alloc] initWithFrame:_pickerTopBarView.frame];
    [_pickerContainerView addSubview:_pickerViewToolBar];
    
    if (![DCTUtils isOS7]) {
        
        _pickerViewToolBar.tintColor = toolbarBackgroundColor;
        //[_pickerViewToolBar setBackgroundColor:toolbarBackgroundColor];
    }else{
        [_pickerViewToolBar setBackgroundColor:toolbarBackgroundColor];
        
        //_pickerViewToolBar.tintColor = toolbarBackgroundColor;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        _pickerViewToolBar.barTintColor = toolbarBackgroundColor;
#endif
    }
    
    if (toolbarImage!=nil) {
        [_pickerViewToolBar setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    _pickerViewBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    _pickerViewToolBar.items = @[cancelButton, flexibleSpace, _pickerViewBarButtonItem];
    [_pickerViewBarButtonItem setTintColor:buttonTextColor];
    
    //[_pickerViewBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Helvetica-Neue" size:23.0], UITextAttributeFont,nil] forState:UIControlStateNormal];
    
    /*
     _pickerDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(_pickerContainerView.frame.size.width - 80.0, 10.0, 60.0, 24.0)];
     [_pickerDoneButton setTitle:@"Done" forState:UIControlStateNormal];
     [_pickerContainerView addSubview:_pickerDoneButton];
     [_pickerDoneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
     */
    
    //Add pickerView
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 216.0)];
    [_pickerView setDelegate:self];
    [_pickerView setDataSource:self];
    [_pickerView setShowsSelectionIndicator: _pickerViewShowsSelectionIndicator];//YES];
    [_pickerContainerView addSubview:_pickerView];
    
    //[self.pickerViewContainerView setAlpha:0.0];
    [_pickerContainerView setTransform:CGAffineTransformMakeTranslation(0.0, CGRectGetHeight(_pickerContainerView.frame))];
    
    //Set selected row
    [_pickerView selectRow:selectedType inComponent:0 animated:YES];
    [_pickerView selectRow:selectedSubset inComponent:1 animated:YES];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView {
    return componentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    if (component == typeComponent) {
        return [types count];
    } else {
        return [subsets count];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == typeComponent) {
        return typeComponentWidth;
    } else {
        return subsetComponentWidth;
    }
}

/*
- (NSString *)pickerView: (UIPickerView *)pickerView
             titleForRow: (NSInteger)row
            forComponent: (NSInteger)component {
  if (self.objectToStringConverter == nil){
    return [_types objectAtIndex:row];
  } else{
    return (self.objectToStringConverter ([_types objectAtIndex:row]));
  }
}*/

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == typeComponent) {
        NSString *selType = [types objectAtIndex:row];
        NSArray *array = [scrType objectForKey:selType];
        subsets = array;
        [pickerView selectRow:0 inComponent:subsetComponent animated:YES];
        [pickerView reloadComponent:subsetComponent];
    }
    selectedType = [pickerView selectedRowInComponent:typeComponent];
    selectedSubset = [pickerView selectedRowInComponent:subsetComponent];
    selScrType = selectedType<<5|selectedSubset;
    selScrName = [NSString stringWithFormat:@"%@ - %@", [types objectAtIndex:selectedType], [subsets objectAtIndex:selectedSubset]];
}

- (id)selectedObject {
    return selScrName;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *printString;
    if (component == typeComponent) {
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
