//
//  DCTColorPickerController.m
//  DCTimer
//
//  Created by MeigenChou on 14-3-10.
//
//

#import "DCTColorPickerController.h"
#import "DCTUtils.h"
#import "InfColorBarPicker.h"
#import "InfColorSquarePicker.h"
#import "InfHSBSupport.h"

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

static void HSVFromUIColor(UIColor* color, float* h, float* s, float* v)
{
	CGColorRef colorRef = [color CGColor];
	
	const CGFloat* components = CGColorGetComponents(colorRef);
	size_t numComponents = CGColorGetNumberOfComponents(colorRef);
	
	CGFloat r, g, b;
	
	if (numComponents < 3) {
		r = g = b = components[0];
	}
	else {
		r = components[0];
		g = components[1];
		b = components[2];
	}
	
	RGBToHSV(r, g, b, h, s, v, YES);
}

@interface DCTColorPickerController ()

@property (nonatomic) IBOutlet InfColorBarView *barView;
@property (nonatomic) IBOutlet InfColorSquareView *squareView;
@property (nonatomic) IBOutlet InfColorBarPicker *barPicker;
@property (nonatomic) IBOutlet InfColorSquarePicker *squarePicker;
@property (nonatomic) IBOutlet UIView *sourceColorView;
@property (nonatomic) IBOutlet UIView *resultColorView;
@property (nonatomic) IBOutlet UILabel *rgbLabel;
@property (nonatomic) IBOutlet UILabel *hsbLabel;
@property (nonatomic) IBOutlet UIButton *btnReset;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIView *barStroke;
@property (nonatomic, strong) UIView *squareStroke;

@end

@implementation DCTColorPickerController {
    float _hue;
	float _saturation;
	float _brightness;
    NSInteger segSelect;
}
@synthesize defColor, crntColor;
@synthesize defkey;
@synthesize barStroke, squareStroke, colorView;
@synthesize segment;
@synthesize btnReset;
@synthesize colorList, defList;
int rcolor, gcolor, bcolor;
extern BOOL svChanged;

+ (DCTColorPickerController *)colorPickerViewController {
    return [[self alloc] init];
}

+ (CGSize)idealSizeForViewInPopover
{
	return CGSizeMake(256 + (1 + 20) * 2, 420);
}

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
	
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (colorList != nil) {
        crntColor = [colorList objectAtIndex:0];
        NSArray *segArray;
        if([self.title isEqualToString:@"Pyraminx"]) {
            segArray = [[NSArray alloc] initWithObjects:@"F", @"L", @"R", @"D", nil];
        } else if([self.title isEqualToString:@"Skewb"]) {
            segArray = [[NSArray alloc] initWithObjects:@"U", @"D", @"F-L", @"F-R", @"B-L", @"B-R", nil];
        } else segArray = [[NSArray alloc] initWithObjects:@"U", @"D", @"L", @"R", @"F", @"B", nil];
        segment = [[UISegmentedControl alloc] initWithItems:segArray];
        [self.view addSubview:segment];
        [segment setSelectedSegmentIndex:0];
        [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        segSelect = 0;
    }
    
    _rgbLabel = [[UILabel alloc] init];
    _hsbLabel = [[UILabel alloc] init];
    _rgbLabel.numberOfLines = 3;
    _rgbLabel.font = [UIFont systemFontOfSize:([DCTUtils isPad] ? 26 : 15)];
    _rgbLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self.view addSubview:_rgbLabel];
    _hsbLabel.numberOfLines = 3;
    _hsbLabel.font = [UIFont systemFontOfSize:([DCTUtils isPad] ? 26 : 15)];
    _hsbLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self.view addSubview:_hsbLabel];
    
    colorView = [[UIView alloc] init];
    colorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:colorView];
    _sourceColorView = [[UIView alloc] init];
    [self.view addSubview:_sourceColorView];
    _resultColorView = [[UIView alloc] init];
    [self.view addSubview:_resultColorView];
    
    barStroke = [[UIView alloc] init];
    [barStroke setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:barStroke];
    _barView = [[InfColorBarView alloc] init];
    [self.view addSubview:_barView];
    _barPicker = [[InfColorBarPicker alloc] init];
    [self.view addSubview:_barPicker];
    [_barPicker addTarget:self action:@selector(takeBarValue:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside];
    
    squareStroke = [[UIView alloc] init];
    [squareStroke setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:squareStroke];
    _squareView = [[InfColorSquareView alloc] init];
    [self.view addSubview:_squareView];
    _squarePicker = [[InfColorSquarePicker alloc] init];
    [self.view addSubview:_squarePicker];
    [_squarePicker addTarget:self action:@selector(takeSquareValue:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside];
    
    btnReset = [[UIButton alloc] init];
    [btnReset setTitle:[DCTUtils getString:@"reset"] forState:UIControlStateNormal];
    [btnReset setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReset setBackgroundColor:[UIColor grayColor]];
    [btnReset addTarget:self action:@selector(setDefColor) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReset];
    
    [self setComponent];
    [self setColor];
    [self setLabelText];
    
	[self.view setBackgroundColor:[UIColor colorWithRed:0.92 green:0.93 blue:0.95 alpha:1]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DCTUtils getString:@"done"] style:UIBarButtonItemStylePlain target:self action:@selector(changeColor)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeColor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"%f %f %f", _hue, _saturation, _brightness);
    [self hsbToRgb:_hue s:_saturation b:_brightness];
    //NSLog(@"%d %d %d", rcolor, gcolor, bcolor);
    if(colorList != nil) {
        [colorList replaceObjectAtIndex:segSelect withObject:crntColor];
        for (int i=0; i<colorList.count; i++) {
            [defaults setInteger:[[colorList objectAtIndex:i] intValue] forKey:[NSString stringWithFormat:@"%@%d", defkey, i + 1]];
        }
        svChanged = YES;
    } else [defaults setInteger:[crntColor intValue] forKey:defkey];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setLabelText {
    _rgbLabel.text = [NSString stringWithFormat:@"R: %d\nG: %d\nB: %d", rcolor, gcolor, bcolor];
    _hsbLabel.text = [NSString stringWithFormat:@"H: %d\nS: %.2f\nB: %.2f", (int)(_hue*360), _saturation, _brightness];
}

- (void)informDelegateDidChangeColor
{
	if (self.delegate && [(id) self.delegate respondsToSelector: @selector(colorPickerControllerDidChangeColor:)])
		[self.delegate colorPickerControllerDidChangeColor: self];
}

- (void)updateResultColor
{
	// This is used when code internally causes the update.  We do this so that
	// we don't cause push-back on the HSV values in case there are rounding
	// differences or anything.
	
	[self willChangeValueForKey: @"resultColor"];
	
    [self hsbToRgb:_hue s:_saturation b:_brightness];
    [self setLabelText];
    crntColor = [NSNumber numberWithInt:(rcolor<<16)|(gcolor<<8)|bcolor];
    
	_resultColor = [UIColor colorWithHue: _hue
							  saturation: _saturation
							  brightness: _brightness
								   alpha: 1.0f];
	
	[self didChangeValueForKey: @"resultColor"];
	
	_resultColorView.backgroundColor = _resultColor;
	
	[self informDelegateDidChangeColor];
}

- (IBAction)takeBarValue:(InfColorBarPicker*)sender
{
	_hue = sender.value;
	
	_squareView.hue = _hue;
	_squarePicker.hue = _hue;
	
	[self updateResultColor];
}

- (IBAction)takeSquareValue:(InfColorSquarePicker*)sender
{
	_saturation = sender.value.x;
	_brightness = sender.value.y;
	
	[self updateResultColor];
}

- (void)setDefColor {   //TODO
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(colorList != nil) {
        [defaults removeObjectForKey:[NSString stringWithFormat:@"%@%d", defkey, (int)segSelect + 1]];
        crntColor = [defList objectAtIndex:segSelect];
    } else {
        [defaults removeObjectForKey:defkey];
        crntColor = defColor;
    }
    [self setColor];
    [self setLabelText];
}

- (void)setColor {
    rcolor = ([crntColor intValue] >> 16) & 0xff;
    gcolor = ([crntColor intValue] >> 8) & 0xff;
    bcolor = [crntColor intValue] & 0xff;
    _sourceColor = _resultColor = [UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:bcolor/255.0 alpha:1.0];
    HSVFromUIColor(_sourceColor, &_hue, &_saturation, &_brightness);
    _barPicker.value = _hue;
    _squareView.hue = _hue;
    _squarePicker.hue = _hue;
    _squarePicker.value = CGPointMake(_saturation, _brightness);
    _sourceColorView.backgroundColor = _sourceColor;
    _resultColorView.backgroundColor = _resultColor;
}

- (void)setComponent {
    int wid = [DCTUtils getFrame].width;
    int hei = [DCTUtils getFrame].height;
    //NSLog(@"%d x %d", wid, hei);
    int ios7delta = [DCTUtils isOS7] ? 64 : 0;
    int startX = [DCTUtils isPad] ? (hei==1004 ? 80 : 208) : 20;
    int startY = [DCTUtils isPad] ? (hei==1004 ? 135 : 56) : (hei==460 ? 50 : (hei==548 ? 70 : (hei==647 ? 80 : 90)));
    int sqY = [DCTUtils isPad] ? (hei==1004 ? 316 : 181) : (hei==460 ? 122 : (hei==548 ? 162 : (hei==647 ? 182 : 202)));
    int sqWid = [DCTUtils isPad] ? 460 : wid - 90;
    int barX = [DCTUtils isPad] ? (hei==1004 ? 610 : 738) : wid - 50;
    int barWid = [DCTUtils isPad] ? 78 : 30;
    //int colX = [DCTUtils isPad] ? (hei==1004 ? 589 : 837) : wid - 79;
    int colWid = [DCTUtils isPad] ? 111 : 59;
    
    _rgbLabel.frame = CGRectMake(startX+colWid+20, startY-4+ios7delta, colWid+4, colWid+4);
    _hsbLabel.frame = CGRectMake(startX+colWid*2+20, startY-4+ios7delta, colWid+4, colWid+4);
    
    colorView.frame = CGRectMake(startX-1, startY-1+ios7delta, colWid+2, colWid+2);
    _sourceColorView.frame = CGRectMake(startX, startY+1+colWid/2+ios7delta, colWid, colWid/2);
    _resultColorView.frame = CGRectMake(startX, startY+ios7delta, colWid, colWid/2);
    
    barStroke.frame = CGRectMake(barX-1, sqY-1+ios7delta, barWid+2, sqWid+2);
    _barView.frame = CGRectMake(barX, sqY+ios7delta, barWid, sqWid);
    _barPicker.frame = CGRectMake(barX, sqY-15+ios7delta, barWid, sqWid+30);
    
    squareStroke.frame = CGRectMake(startX-1, sqY-1+ios7delta, sqWid+2, sqWid+2);
    _squareView.frame = CGRectMake(startX, sqY+ios7delta, sqWid, sqWid);
    _squarePicker.frame = CGRectMake(startX-15, sqY-15+ios7delta, sqWid+30, sqWid+30);
    
    int btX = hei==1024 ? 944-startX : wid-startX-80;
    btnReset.frame = CGRectMake(btX, startY+ios7delta, 80, 35);
    
    if (colorList != nil) {
        int segWid = [DCTUtils isPad] ? 610 : wid - 40;
        int segHei = [DCTUtils isOS7] ? 29 : 34;
        int segX = [DCTUtils isPad] ? (hei==1004 ? 79 : 207) : 20;
        int segY = [DCTUtils isPad] && hei==1004 ? 20 : 10;
        segment.frame = CGRectMake(segX, ios7delta+segY, segWid, segHei);
    }
}

- (void)hsbToRgb:(float)h s:(float)s b:(float)v {
    float r = 0, g = 0, b = 0;
    int i = (int) (h * 6.0) % 6;    //0
    float f = (h * 6.0) - i;    //6
    if(f==6) f = 0;
    float p = v * (1 - s);  //.1976
    float q = v * (1 - f * s);  //-
    float t = v * (1 - (1 - f) * s);
    switch (i) {
        case 0:
            r = v; g = t; b = p;
            break;
        case 1:
            r = q; g = v; b = p;
            break;
        case 2:
            r = p; g = v; b = t;
            break;
        case 3:
            r = p; g = q; b = v;
            break;
        case 4:
            r = t; g = p; b = v;
            break;
        case 5:
            r = v; g = p; b = q;
            break;
        default:
            break;
    }
    rcolor = (int) (r*255.0); gcolor = (int) (g*255.0); bcolor = (int) (b*255.0);
}

- (void)segmentAction:(UISegmentedControl *)seg {
    [colorList replaceObjectAtIndex:segSelect withObject:crntColor];
    NSInteger index = seg.selectedSegmentIndex;
    crntColor = [colorList objectAtIndex:index];
    segSelect = index;
    [self setColor];
    [self setLabelText];
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
    [self setComponent];
}

@end
