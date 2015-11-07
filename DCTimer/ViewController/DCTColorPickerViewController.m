//
//  DCTColorPickerViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-4-9.
//
//

#import "DCTColorPickerViewController.h"
#import "DCTUtils.h"

@interface DCTColorPickerViewController ()

@end

@implementation DCTColorPickerViewController
@synthesize crntColor;
@synthesize defkey;
@synthesize c1slider;
@synthesize c2slider;
@synthesize c3slider;
@synthesize c1label;
@synthesize c2label;
@synthesize c3label;
int rcolor, gcolor, bcolor;
float hcolor, scolor, lcolor;
int segSel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setLabelText {
    [c1label setText:[NSString stringWithFormat:@"%1.2f", c1slider.value]];
    [c2label setText:[NSString stringWithFormat:@"%1.2f", c2slider.value]];
    [c3label setText:[NSString stringWithFormat:@"%1.2f", c3slider.value]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    rcolor = ([crntColor intValue]>>16)&0xff;
    gcolor = ([crntColor intValue]>>8)&0xff;
    bcolor = [crntColor intValue]&0xff;
    segSel = 0;
    [self rgb2Hsl];
    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:bcolor/255.0 alpha:1]];
    [c1slider setValue:rcolor/255.0];
    [c2slider setValue:gcolor/255.0];
    [c3slider setValue:bcolor/255.0];
    [self setLabelText];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"") style:UIBarButtonItemStylePlain target:self action:@selector(changeColor)];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeColor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:((rcolor<<16)|(gcolor<<8)|bcolor) forKey:defkey];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)segChanged:(UISegmentedControl *)sender {
    segSel = [sender selectedSegmentIndex];
    switch (segSel) {
        case 0:
            [c1slider setValue:rcolor/255.0];
            [c2slider setValue:gcolor/255.0];
            [c3slider setValue:bcolor/255.0];
            break;
        case 1:
            [self rgb2Hsl];
            [c1slider setValue:hcolor/360];
            [c2slider setValue:scolor];
            [c3slider setValue:lcolor];
            break;
    }
    [self setLabelText];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    float v = sender.value;
    switch (segSel) {
        case 0:
            switch (sender.tag) {
                case 1:
                    rcolor = v*255;
                    [self.view setBackgroundColor:[UIColor colorWithRed:v green:gcolor/255.0 blue:bcolor/255.0 alpha:1]];
                    [c1label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
                case 2:
                    gcolor = v*255;
                    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:v blue:bcolor/255.0 alpha:1]];
                    [c2label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
                case 3:
                    bcolor = v*255;
                    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:v alpha:1]];
                    [c3label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
            }
            break;
        case 1:
            switch (sender.tag) {
                case 1:
                    hcolor = v*360;
                    [self hsl2Rgb];
                    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:bcolor/255.0 alpha:1]];
                    [c1label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
                case 2:
                    scolor = v;
                    [self hsl2Rgb];
                    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:bcolor/255.0 alpha:1]];
                    [c2label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
                case 3:
                    lcolor = v;
                    [self hsl2Rgb];
                    [self.view setBackgroundColor:[UIColor colorWithRed:rcolor/255.0 green:gcolor/255.0 blue:bcolor/255.0 alpha:1]];
                    [c3label setText:[NSString stringWithFormat:@"%1.2f", v]];
                    break;
            }
            break;
    }
    
}
- (void)viewDidUnload {
    [self setC1slider:nil];
    [self setC2slider:nil];
    [self setC3slider:nil];
    [self setC1label:nil];
    [self setC2label:nil];
    [self setC3label:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([DCTUtils isPhone]) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)hsl2Rgb {
    double r, g, b;
    if(scolor == 0) r = g = b = lcolor;
    else {
        double q, p, tr, tg, tb;
        if(lcolor<0.5) q = lcolor * (1 + scolor);
        else q = lcolor + scolor - lcolor * scolor;
        p = 2 * lcolor - q;
        double H = hcolor/360.0;
        tr = H + 1/3.0;
        tg = H;
        tb = H - 1/3.0;
        r = [self toRGB:tr q:q p:p H:H];
        g = [self toRGB:tg q:q p:p H:H];
        b = [self toRGB:tb q:q p:p H:H];
    }
    rcolor = r * 255 + 0.5;
    gcolor = g * 255 + 0.5;
    bcolor = b * 255 + 0.5;
}

- (double)toRGB:(double)tc q:(double)q p:(double)p H:(double)H {
    if(tc < 0)tc += 1;
    if(tc > 1)tc -= 1;
    if(tc < 1/6.0)
        return p + (q - p) * 6 * tc;
    else if(tc < 0.5)
        return q;
    else if(tc < 2/3.0)
        return p + (q - p) * 6 * (2/3.0 - tc);
    else return p;
}

- (void)rgb2Hsl {
    double R = rcolor / 255.0;
    double G = gcolor / 255.0;
    double B = bcolor / 255.0;
    double h = 0, s = 0, l;
    double max = MAX(MAX(R, G), B);
    double min = MIN(MIN(R, G), B);
    if(max == min) h = 0;
    else if(max == R && G >= B) h = 60 * ((G - B) / (max - min));
    else if(max == R && G < B) h = 60 * ((G - B) / (max - min)) + 360;
    else if(max == G) h = 60 * ((B - R) / (max - min)) + 120;
    else if(max == B) h = 60 * ((R - G) / (max - min)) + 240;
    l = (max + min) / 2;
    if(l == 0 || max == min) s = 0;
    else if(l > 0 && l <= 0.5)s = (max - min) / (max + min);
    else if(l > 0.5) s = (max - min) / (2 - (max + min));
    hcolor = (float)h;
    scolor = (float)s;
    lcolor = (float)l;
}
@end
