//
//  DCTSessionViewController.h
//  DCTimer
//
//  Created by MeigenChou on 13-3-29.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCTSessionViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
    int selectedSesIdx;
    bool isDefSes;
}

@end
