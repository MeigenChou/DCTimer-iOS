//
//  DCTDetailViewController.h
//  DCTimer
//
//  Created by MeigenChou on 14-1-8.
//
//

#import <UIKit/UIKit.h>

@interface DCTDetailViewController : UITableViewController <UIActionSheetDelegate>
@property (copy, nonatomic) NSString *rest, *time, *scramble;
@property (copy, nonatomic) NSArray *resi;
@end
