//
//  DCTSettingsViewController.h
//  DCTimer
//
//  Created by MeigenChou on 13-3-28.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DCTSettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, strong) UILabel *fTime;
@end
