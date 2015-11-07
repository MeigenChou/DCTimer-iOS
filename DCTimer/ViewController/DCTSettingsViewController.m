//
//  DCTSettingsViewController.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-28.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTSettingsViewController.h"
#import "DCTSecondLevelViewController.h"
#import "DCTColorPickerViewController.h"
#import "DCTHelpViewController.h"
#import "DCTAboutViewController.h"
#import "DCTUtils.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "sys/utsname.h"

@interface DCTSettingsViewController ()
@property (nonatomic, strong) DCTHelpViewController *helpView;
@end

@implementation DCTSettingsViewController
@synthesize fTime;
@synthesize helpView;
int timerupd, accuracy;
int cside, cxe, sqshp;
bool wcaInst, clkFormat;
bool hideScr, inTime;
bool promTime, prntScr;
int bgcolor, textcolor;
bool tfChanged = false;

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
            return 6;
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
            return 3;
        case 4:
            return 2;
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
    bool isEn = [DCTUtils isPhone] && [NSLocalizedString(@"language", @"") isEqualToString:@"en"];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"WCAinsp", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    UISwitch *wcainspSwitch = [[UISwitch alloc] init];
                    [wcainspSwitch setTag:0];
                    wcainspSwitch.on = [defaults boolForKey:@"wcainsp"];
                    wcaInst = wcainspSwitch.on;
                    [wcainspSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = wcainspSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                } 
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"clockformat", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                    }
                    UISwitch *tformatSwitch = [[UISwitch alloc] init];
                    [tformatSwitch setTag:1];
                    tformatSwitch.on = [defaults boolForKey:@"clockform"];
                    clkFormat = tformatSwitch.on;
                    [tformatSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = tformatSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"timerupd", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"On", @""), NSLocalizedString(@"secondsonly", @""), NSLocalizedString(@"insponly", @""), NSLocalizedString(@"Off", @""), nil];
                    timerupd = [defaults integerForKey:@"timerupd"];
                    cell.detailTextLabel.text = [array objectAtIndex:timerupd];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 3:
                {
                    cell.textLabel.text = NSLocalizedString(@"accuracy", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"0.001sec", @""), NSLocalizedString(@"0.01sec", @""), nil];
                    accuracy = [defaults integerForKey:@"accuracy"];
                    cell.detailTextLabel.text = [array objectAtIndex:accuracy];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 4:
                {
                    cell.textLabel.text = NSLocalizedString(@"pressingtime", @"");
                    if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                    else if(isEn) {
                        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
                    } else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    int time = [defaults integerForKey:@"freezeslide"];
                    fTime = cell.detailTextLabel;
                    if([DCTUtils isOS7]) fTime.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f s", (double)time*0.05];
                    UISlider *freezeTime = [[UISlider alloc] init];
                    freezeTime.minimumValue = 0;
                    freezeTime.maximumValue = 20;
                    [freezeTime addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    freezeTime.value = time;
                    [freezeTime addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = freezeTime;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 5:
                {
                    cell.textLabel.text = NSLocalizedString(@"input_time", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    UISwitch *inputSwitch = [[UISwitch alloc] init];
                    [inputSwitch setTag:5];
                    inputSwitch.on = [defaults boolForKey:@"intime"];
                    inTime = inputSwitch.on;
                    [inputSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = inputSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"hide_scr", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
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
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"prompttime", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:15];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
                    }
                    UISwitch *promtSwitch = [[UISwitch alloc] init];
                    [promtSwitch setTag:2];
                    promtSwitch.on = [defaults boolForKey:@"prompttime"];
                    promTime = promtSwitch.on;
                    [promtSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                    cell.detailTextLabel.text = @"";
                    cell.accessoryView = promtSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"printscr", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:13.5];
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
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = NSLocalizedString(@"3solver", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"none", @""), @"Cross", @"Xcross", @"EOLine", nil];
                    cxe = [defaults integerForKey:@"cxe"];
                    cell.detailTextLabel.text = [array objectAtIndex:cxe];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = NSLocalizedString(@"solcolor", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
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
                case 2:
                {
                    cell.textLabel.text = NSLocalizedString(@"sq_shape_solver", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:16];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
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
        case 4:
            switch (indexPath.row) {
                case 0:
                {
                    bgcolor = [defaults integerForKey:@"bgcolor"];
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    cell.textLabel.text = NSLocalizedString(@"bgcolor", @"");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
                case 1:
                {
                    textcolor = [defaults integerForKey:@"textcolor"];
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    cell.textLabel.text = NSLocalizedString(@"textcolor", @"");
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                }
            }
            break;
        case 5:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"gesture", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"rate_app", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"email_feedback", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                    }
                    cell.detailTextLabel.text = @"";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    cell.accessoryView = nil;
                    break;
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"licenses", @"");
                    if(isEn) {
                        if([DCTUtils isOS7]) cell.textLabel.font = [UIFont systemFontOfSize:17];
                        else cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
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
                case 2:
                {
                    NSArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"On", @""), NSLocalizedString(@"secondsonly", @""), NSLocalizedString(@"insponly", @""), NSLocalizedString(@"Off", @""), nil];
                    DCTSecondLevelViewController *second = [[DCTSecondLevelViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    second.selIndex = [NSNumber numberWithInt:timerupd];
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
                    second.selIndex = [NSNumber numberWithInt:accuracy];
                    second.key = @"accuracy";
                    second.title = NSLocalizedString(@"accuracy", @"");
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
                    second.selIndex = [NSNumber numberWithInt:cxe];
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
                    second.selIndex = [NSNumber numberWithInt:cside];
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
                    second.selIndex = [NSNumber numberWithInt:sqshp];
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
                    DCTColorPickerViewController *colorView = [[DCTColorPickerViewController alloc] init];
                    colorView.title = NSLocalizedString(@"bgcolor", @"");
                    colorView.crntColor = [NSNumber numberWithInt:bgcolor];
                    colorView.defkey = @"bgcolor";
                    [self.navigationController pushViewController:colorView animated:YES];
                    break;
                }
                case 1:
                {
                    DCTColorPickerViewController *colorView = [[DCTColorPickerViewController alloc] init];
                    colorView.title = NSLocalizedString(@"textcolor", @"");
                    colorView.crntColor = [NSNumber numberWithInt:textcolor];
                    colorView.defkey = @"textcolor";
                    [self.navigationController pushViewController:colorView animated:YES];
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
                    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", 794870196];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
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
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (IBAction)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    //NSLog(@"%d", [sender tag]);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (switchButton.tag) {
        case 0:
            [defaults setBool:switchButton.on forKey:@"wcainsp"];
            wcaInst = switchButton.on;
            break;
        case 1:
            [defaults setBool:switchButton.on forKey:@"clockform"];
            clkFormat = switchButton.on;
            break;
        case 2:
            [defaults setBool:switchButton.on forKey:@"prompttime"];
            promTime = switchButton.on;
            break;
        case 3:
            [defaults setBool:switchButton.on forKey:@"printscr"];
            prntScr = switchButton.on;
            break;
        case 4:
            [defaults setBool:switchButton.on forKey:@"hidescr"];
            hideScr = switchButton.on;
            break;
        case 5:
            [defaults setBool:switchButton.on forKey:@"intime"];
            inTime = switchButton.on;
            tfChanged = true;
            break;
    }
}

- (IBAction)sliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    fTime.text = [NSString stringWithFormat:@"%1.2f s", (double)progressAsInt*0.05];
    //NSLog(@"%d", progressAsInt);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:progressAsInt forKey:@"freezeslide"];
}

- (NSString *)getDeviceString {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"v%@", version];
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
    [mailPicker setSubject: [NSString stringWithFormat:@"DCTimer %@ %@", [self getAppVersion], NSLocalizedString(@"feedback", @"")]];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"meigenchou@foxmail.com"];
    [mailPicker setToRecipients: toRecipients];
    NSString *emailBody = [NSString stringWithFormat:@"(%@, iOS %@)\n", [self getDeviceString], [[UIDevice currentDevice] systemVersion]];
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentModalViewController: mailPicker animated:YES];
}

- (void)launchMailAppOnDevice
{
    NSString *subject = [NSString stringWithFormat:@"DCTimer %@ %@", [self getAppVersion], NSLocalizedString(@"feedback", @"")];
    NSString *body = [NSString stringWithFormat:@"(%@, iOS %@)\n", [self getDeviceString], [[UIDevice currentDevice] systemVersion]];
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
