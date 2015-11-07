//
//  DCTSettingsViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-28.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTSettingsViewController.h"
#import "DCTSecondLevelViewController.h"
#import "DCTColorPickerController.h"
#import "DCTHelpViewController.h"
#import "DCTAboutViewController.h"
#import "DCTUtils.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface DCTSettingsViewController ()
@property (nonatomic, strong) DCTHelpViewController *helpView;
@end

@implementation DCTSettingsViewController
@synthesize fTime;
@synthesize helpView;
NSInteger timerupd, accuracy;
NSInteger cside, cxe, sqshp;
NSInteger timeForm;
NSInteger bgcolor, textcolor;
bool tfChanged = false;
bool imgChanged = false;
bool svChanged = false;
bool monoChanged = false;
BOOL showImg = NO;
BOOL prntScr;
NSInteger subTitle;
NSInteger tmfont;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"settings", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"img3"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"settings", @"");
}

-(void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int bgcolor = (int)[defaults integerForKey:@"bgcolor"];
    int r = (bgcolor>>16)&0xff;
    int g = (bgcolor>>8)&0xff;
    int b = bgcolor&0xff;
    if([DCTUtils isOS7]) self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    else self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"timer", @"");
        case 1:
            return NSLocalizedString(@"scramble", @"");
        case 2:
            return NSLocalizedString(@"stt_stats", @"");
        case 3:
            return NSLocalizedString(@"tools", @"");
        case 4:
            return NSLocalizedString(@"interface", @"");
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 8;
        case 1:
            return 3;
        case 2:
            return 4;
        case 3:
            return 3;
        case 4:
            return [DCTUtils isPad] ? 7 : 6;
        case 5:
            return 4;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(indexPath.section==0 && indexPath.row==4) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Subtitle"];
    }
    else if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    bool isEn = [DCTUtils isPhone] && [[DCTUtils getString:@"language"] isEqualToString:@"en"];
    bool isNl = [DCTUtils isPhone] && [[DCTUtils getString:@"language"] isEqualToString:@"nl"];
    switch (indexPath.section) {
        case 0: //计时
            switch (indexPath.row) {
                case 0: //WCA观察
                {
                    cell.textLabel.text = NSLocalizedString(@"WCAinsp", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    UISwitch *wcainspSwitch = [[UISwitch alloc] init];
                    [wcainspSwitch setTag:0];
                    wcainspSwitch.on = [defaults boolForKey:@"wcainsp"];
                    [wcainspSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = wcainspSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                } 
                case 1: //时间格式
                {
                    cell.textLabel.text = NSLocalizedString(@"clockformat", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    //UISwitch *tformatSwitch = [[UISwitch alloc] init];
                    //[tformatSwitch setTag:1];
                    //tformatSwitch.on = [defaults boolForKey:@"clockform"];
                    //clkFormat = tformatSwitch.on;
                    //[tformatSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    NSArray *array = [[NSArray alloc] initWithObjects:@"hh:mm:ss.xy(z)", @"mm:ss.xy(z)", @"ss.xy(z)", nil];
                    timeForm = [defaults integerForKey:@"timeform"];
                    cell.detailTextLabel.text = [array objectAtIndex:timeForm];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.accessoryView = nil;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    break;
                }
                case 2: //计时器更新方式
                {
                    cell.textLabel.text = NSLocalizedString(@"timerupd", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"On", @""), NSLocalizedString(@"secondsonly", @""), NSLocalizedString(@"insponly", @""), NSLocalizedString(@"Off", @""), nil];
                    timerupd = [defaults integerForKey:@"timerupd"];
                    cell.detailTextLabel.text = [array objectAtIndex:timerupd];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 3: //精度
                {
                    cell.textLabel.text = NSLocalizedString(@"accuracy", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"0.001sec", @""), NSLocalizedString(@"0.01sec", @""), nil];
                    accuracy = [defaults integerForKey:@"accuracy"];
                    cell.detailTextLabel.text = [array objectAtIndex:accuracy];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 4: //启动延时
                {
                    cell.textLabel.text = NSLocalizedString(@"pressingtime", @"");
                    if([DCTUtils isOS7]) {
                        if(isNl) cell.textLabel.font = [UIFont systemFontOfSize:15];
                        else cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    else if(isEn) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    } else if(isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:14];
                    } else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    NSInteger time = [defaults integerForKey:@"freezeslide"];
                    fTime = cell.detailTextLabel;
                    if([DCTUtils isOS7]) fTime.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f s", (double)time*0.05];
                    UISlider *freezeTime = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 140, 34)];
                    freezeTime.minimumValue = 0;
                    freezeTime.maximumValue = 20;
                    freezeTime.tag = 0;
                    [freezeTime addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    freezeTime.value = time;
                    cell.accessoryView = freezeTime;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 5: //手动输入
                {
                    cell.textLabel.text = [DCTUtils getString:@"input_time"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.numberOfLines = 2;
                    }
                    UISwitch *inputSwitch = [[UISwitch alloc] init];
                    [inputSwitch setTag:5];
                    inputSwitch.on = [defaults boolForKey:@"intime"];
                    [inputSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = inputSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 6: //拍桌子停表
                {
                    cell.textLabel.text = [DCTUtils getString:@"drop_stop"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.numberOfLines = 2;
                    }
                    UISwitch *dropSwitch = [[UISwitch alloc] init];
                    [dropSwitch setTag:6];
                    dropSwitch.on = [defaults boolForKey:@"drops"];
                    [dropSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = dropSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 7: //灵敏度
                {
                    cell.textLabel.text = [DCTUtils getString:@"sensitivity"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSInteger sens = [defaults integerForKey:@"sensity"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"";
                    UISlider *senSlide = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 140, 34)];
                    senSlide.minimumValue = 0;
                    senSlide.maximumValue = 50;
                    senSlide.tag = 2;
                    [senSlide addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    senSlide.value = sens;
                    cell.accessoryView = senSlide;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
            }
            break;
        case 1: //打乱
            switch (indexPath.row) {
                case 0: //隐藏打乱
                {
                    cell.textLabel.text = NSLocalizedString(@"hide_scr", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.numberOfLines = 2;
                    }
                    UISwitch *hideSwitch = [[UISwitch alloc] init];
                    [hideSwitch setTag:4];
                    hideSwitch.on = [defaults boolForKey:@"hidescr"];
                    [hideSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = hideSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1: //显示打乱状态
                {
                    cell.textLabel.text = NSLocalizedString(@"display_scr", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    UISwitch *showScr = [[UISwitch alloc] init];
                    [showScr setTag:8];
                    showScr.on = [defaults boolForKey:@"showscr"];
                    [showScr addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = showScr;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2: //等宽字体打乱
                {
                    cell.textLabel.text = NSLocalizedString(@"mono_font", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    UISwitch *monoFont = [[UISwitch alloc] init];
                    [monoFont setTag:10];
                    monoFont.on = [defaults boolForKey:@"monofont"];
                    [monoFont addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = monoFont;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
            }
            break;
        case 2: //统计
            switch (indexPath.row) {
                case 0: //提示每次操作
                {
                    cell.textLabel.text = NSLocalizedString(@"prompttime", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.numberOfLines = 2;
                    }
//                    if(isNl) {
//                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
//                        else cell.textLabel.font = [UIFont systemFontOfSize:13];
//                    }
                    UISwitch *promtSwitch = [[UISwitch alloc] init];
                    [promtSwitch setTag:2];
                    promtSwitch.on = [defaults boolForKey:@"prompttime"];
                    [promtSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = promtSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1: //显示打乱
                {
                    cell.textLabel.text = NSLocalizedString(@"printscr", @"");
                    if(isEn) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.numberOfLines = 2;
                    }
                    if(isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:16];
                        cell.textLabel.numberOfLines = 2;
                    }
                    UISwitch *prnscrSwitch = [[UISwitch alloc] init];
                    [prnscrSwitch setTag:3];
                    prnscrSwitch.on = [defaults boolForKey:@"printscr"];
                    prntScr = prnscrSwitch.on;
                    [prnscrSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = prnscrSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2: //逆序显示
                {
                    cell.textLabel.text = NSLocalizedString(@"newest_top", @"");
                    if(isEn) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    if(isNl) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont systemFontOfSize:16];
                    }
                    UISwitch *newtSwitch = [[UISwitch alloc] init];
                    [newtSwitch setTag:9];
                    newtSwitch.on = [defaults boolForKey:@"newtop"];
                    [newtSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = newtSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 3: //副标题
                {
                    cell.textLabel.text = NSLocalizedString(@"subtitle", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"time", @""), [DCTUtils getString:@"scramble"], nil];
                    subTitle = [defaults integerForKey:@"subtitle"];
                    cell.detailTextLabel.text = [array objectAtIndex:subTitle];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
            }
            break;
        case 3: //工具
            switch (indexPath.row) {
                case 0: //三阶求解
                {
                    cell.textLabel.text = NSLocalizedString(@"3solver", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"none", @""), @"Cross", @"Xcross", @"EOLine", nil];
                    cxe = [defaults integerForKey:@"cxe"];
                    cell.detailTextLabel.text = [array objectAtIndex:cxe];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 1: //底色
                {
                    cell.textLabel.text = NSLocalizedString(@"solcolor", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"dside", @""), NSLocalizedString(@"uside", @""), NSLocalizedString(@"lside", @""), NSLocalizedString(@"rside", @""), NSLocalizedString(@"fside", @""), NSLocalizedString(@"bside", @""), nil];
                    cside = [defaults integerForKey:@"cside"];
                    if(cside==6) {
                        cside = 0;
                        [defaults setInteger:0 forKey:@"cside"];
                    }
                    cell.detailTextLabel.text = [array objectAtIndex:cside];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 2: //SQ1求解
                {
                    cell.textLabel.text = NSLocalizedString(@"sq_shape_solver", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:16];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"none", @""), @"Face turn metric", @"Twist metric", nil];
                    sqshp = [defaults integerForKey:@"sqshape"];
                    cell.detailTextLabel.text = [array objectAtIndex:sqshp];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
            }
            break;
        case 4: //界面
            switch (indexPath.row) {
                case 0: //背景色
                {
                    bgcolor = [defaults integerForKey:@"bgcolor"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.textLabel.text = NSLocalizedString(@"bgcolor", @"");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 1: //文字色
                {
                    textcolor = [defaults integerForKey:@"textcolor"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.textLabel.text = NSLocalizedString(@"textcolor", @"");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 2: //背景图
                {
                    cell.textLabel.text = NSLocalizedString(@"bg_image", @"image");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 3: //不透明度
                {
                    cell.textLabel.text = NSLocalizedString(@"opacity", @"image");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"";
                    UISlider *opac = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 140, 34)];
                    opac.minimumValue = 0;
                    opac.maximumValue = 100;
                    opac.tag = 1;
                    [opac addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    opac.value = [defaults integerForKey:@"opacity"];
                    cell.accessoryView = opac;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 4: //显示图片
                {
                    cell.textLabel.text = NSLocalizedString(@"show_image", @"image");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    UISwitch *imgSwitch = [[UISwitch alloc] init];
                    [imgSwitch setTag:7];
                    imgSwitch.on = [defaults boolForKey:@"showimg"];
                    showImg = imgSwitch.on;
                    [imgSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryView = imgSwitch;
                    break;
                }
                case 5: //计时器字体
                {
                    cell.textLabel.text = [DCTUtils getString:@"timer_font"];
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:@"Arial", @"Courier New", @"Digiface", @"Georgia", @"Helvetica", @"Times New Roman", @"Verdana", nil];
                    tmfont = [defaults integerForKey:@"tmfont"];
                    cell.detailTextLabel.text = [array objectAtIndex:tmfont];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 6: //计时器大小
                {
                    cell.textLabel.text = NSLocalizedString(@"timer_size", @"");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"";
                    UISlider *tmSize = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 140, 34)];
                    tmSize.minimumValue = 80;
                    tmSize.maximumValue = 180;
                    tmSize.tag = 3;
                    [tmSize addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    tmSize.value = [defaults integerForKey:@"tmsize"];
                    cell.accessoryView = tmSize;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
            }
            break;
        case 5:
            switch (indexPath.row) {
                case 0: //手势说明
                    cell.textLabel.text = NSLocalizedString(@"gesture", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 1: //评分
                    cell.textLabel.text = NSLocalizedString(@"rate_app", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 2: //反馈
                    cell.textLabel.text = NSLocalizedString(@"email_feedback", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 3: //许可证
                    cell.textLabel.text = NSLocalizedString(@"licenses", @"");
                    if(isEn || isNl) {
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
            }
    }
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:@"hh:mm:ss.xy(z)", @"mm:ss.xy(z)", @"ss.xy(z)", nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(timeForm);
                    second.key = @"timeform";
                    second.title = NSLocalizedString(@"clockformat", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
                case 2:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"On", @""), NSLocalizedString(@"secondsonly", @""), NSLocalizedString(@"insponly", @""), NSLocalizedString(@"Off", @""), nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(timerupd);
                    second.key = @"timerupd";
                    second.title = NSLocalizedString(@"timerupd", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
                case 3:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"0.001sec", @""), NSLocalizedString(@"0.01sec", @""), nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(accuracy);
                    second.key = @"accuracy";
                    second.title = NSLocalizedString(@"accuracy", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 3:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"time", @""), [DCTUtils getString:@"scramble"], nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(subTitle);
                    second.key = @"subtitle";
                    second.title = [DCTUtils getString:@"subtitle"];
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"none", @""), @"Cross", @"Xcross", @"EOLine", nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(cxe);
                    second.key = @"cxe";
                    second.title = NSLocalizedString(@"3solver", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
                case 1:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"dside", @""), NSLocalizedString(@"uside", @""), NSLocalizedString(@"lside", @""), NSLocalizedString(@"rside", @""), NSLocalizedString(@"fside", @""), NSLocalizedString(@"bside", @""), nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(cside);
                    second.key = @"cside";
                    second.title = NSLocalizedString(@"solcolor", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
                case 2:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"none", @""), @"Face turn metric", @"Twist metric", nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(sqshp);
                    second.key = @"sqshape";
                    second.title = NSLocalizedString(@"sq_shape_solver", @"");
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
            }
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                {
                    DCTColorPickerController *colorView = [[DCTColorPickerController alloc] init];
                    colorView.title = NSLocalizedString(@"bgcolor", @"");
                    colorView.crntColor = @(bgcolor);
                    colorView.defkey = @"bgcolor";
                    [self.navigationController pushViewController:colorView animated:YES];
                    break;
                }
                case 1:
                {
                    DCTColorPickerController *colorView = [[DCTColorPickerController alloc] init];
                    colorView.title = NSLocalizedString(@"textcolor", @"");
                    colorView.crntColor = @(textcolor);
                    colorView.defkey = @"textcolor";
                    [self.navigationController pushViewController:colorView animated:YES];
                    break;
                }
                case 2:
                    [self showPicker];
                    break;
                case 5:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:@"Arial", @"Courier New", @"Digiface", @"Georgia", @"Helvetica", @"Times New Roman", @"Verdana", nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = @(tmfont);
                    second.key = @"tmfont";
                    second.title = [DCTUtils getString:@"timer_font"];
                    second.array = array;
                    [self.navigationController pushViewController:second animated:YES];
                    break;
                }
            }
            break;
        case 5:
            switch (indexPath.row) {
                case 0:
                {
                    if(!helpView) {
                        helpView = [[DCTHelpViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    }
                    helpView.title = NSLocalizedString(@"gesture", @"");
                    [self.navigationController pushViewController:helpView animated:YES];
                    break;
                }
                case 1:
                {
                    NSString *url = [DCTUtils isOS7] ? [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", 794870196] : [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", 794870196];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    break;
                }
                case 2:
                    [self sendFeedback];
                    break;
                case 3:
                {
                    DCTAboutViewController *aboutView = [[DCTAboutViewController alloc] init];
                    //aboutView.title = NSLocalizedString(@"", @"");
                    [self.navigationController pushViewController:aboutView animated:YES];
                }
                    
                default:
                    break;
            }
    }
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

- (IBAction)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    //NSLog(@"%d", [sender tag]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (switchButton.tag) {
        case 0: //WCA观察
            [defaults setBool:switchButton.on forKey:@"wcainsp"];
            break;
        case 2: //确认成绩
            [defaults setBool:switchButton.on forKey:@"prompttime"];
            break;
        case 3:
            [defaults setBool:switchButton.on forKey:@"printscr"];
            break;
        case 4:
            [defaults setBool:switchButton.on forKey:@"hidescr"];
            break;
        case 5:
            [defaults setBool:switchButton.on forKey:@"intime"];
            tfChanged = true;
            break;
        case 6:
            [defaults setBool:switchButton.on forKey:@"drops"];
            break;
        case 7:
            [defaults setBool:switchButton.on forKey:@"showimg"];
            showImg = switchButton.on;
            imgChanged = true;
            break;
        case 8:
            [defaults setBool:switchButton.on forKey:@"showscr"];
            svChanged = true;
            break;
        case 9:
            [defaults setBool:switchButton.on forKey:@"newtop"];
            break;
        case 10:
            [defaults setBool:switchButton.on forKey:@"monofont"];
            monoChanged = true;
            break;
    }
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (slider.tag) {
        case 0:
            fTime.text = [NSString stringWithFormat:@"%1.2f s", (double)progressAsInt*0.05];
            //NSLog(@"%d", progressAsInt);
            [defaults setInteger:progressAsInt forKey:@"freezeslide"];
            break;
        case 1:
            [defaults setInteger:progressAsInt forKey:@"opacity"];
            break;
        case 2:
            [defaults setInteger:progressAsInt forKey:@"sensity"];
            break;
        case 3:
            [defaults setInteger:progressAsInt forKey:@"tmsize"];
            break;
        default:
            break;
    }
    
}

- (void)showPicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)aImage editingInfo:(NSDictionary *)editingInfo
{
    if(showImg)imgChanged = true;
    NSData *imageData = UIImagePNGRepresentation(aImage);
    if(imageData == nil) imageData = UIImageJPEGRepresentation(aImage, 1);
    [imageData writeToFile:[DCTUtils getFilePath:@"bg.png"] atomically:NO];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)sendFeedback
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) [self displayMailPicker];
        else [self launchMailAppOnDevice];
    } else [self launchMailAppOnDevice];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    //设置主题
    [mailPicker setSubject: [NSString stringWithFormat:@"DCTimer %@ %@", [DCTUtils getAppVersion], NSLocalizedString(@"feedback", @"")]];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"meigenchou@foxmail.com"];
    [mailPicker setToRecipients: toRecipients];
    NSString *emailBody = [NSString stringWithFormat:@"(%@, iOS %@)\n", [DCTUtils getDeviceString], [[UIDevice currentDevice] systemVersion]];
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController: mailPicker animated:YES];
}

- (void)launchMailAppOnDevice
{
    NSString *subject = [NSString stringWithFormat:@"DCTimer %@ %@", [DCTUtils getAppVersion], NSLocalizedString(@"feedback", @"")];
    NSString *body = [NSString stringWithFormat:@"(%@, iOS %@)\n", [DCTUtils getDeviceString], [[UIDevice currentDevice] systemVersion]];
    NSString *email = [NSString stringWithFormat:@"mailto:meigenchou@foxmail.com?subject=%@&body=%@", subject, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"邮件发送取消");
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            NSLog(@"邮件保存成功");
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            
            NSLog(@"邮件发送成功");
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            NSLog(@"邮件发送失败");
            break;
        default:
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
