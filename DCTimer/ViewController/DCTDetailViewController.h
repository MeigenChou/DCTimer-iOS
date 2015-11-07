//
//  DCTDetailViewController.h
//  DCTimer
//
//  Created by MeigenChou on 14-1-8.
//
//

#import <UIKit/UIKit.h>
#import "DCTData.h"

@interface DCTDetailViewController : UITableViewController <UIActionSheetDelegate>

@property (copy, nonatomic) NSString *rest, *time, *scramble;

- (void)setDetail:(int)idx;

@end
