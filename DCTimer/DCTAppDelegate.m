//
//  DCTAppDelegate.m
//  DCTimer
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import "DCTAppDelegate.h"
#import "DCTFirstViewController.h"
#import "DCTResultViewController.h"
#import "DCTSettingsViewController.h"
#import "DCTUtils.h"

@implementation DCTAppDelegate
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"clockform", [NSNumber numberWithInt:7], @"freezeslide", [NSNumber numberWithBool:YES], @"printscr", [DCTUtils getString:@"defsession"], @"defsesname", [NSNumber numberWithInt:32], @"crntscrtype", [NSNumber numberWithInt:0x66CCFF], @"bgcolor", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2, *viewController3;
    if ([DCTUtils isPhone]) {
        viewController1 = [[DCTFirstViewController alloc] initWithNibName:@"DCTFirstViewController_iPhone" bundle:nil];
    } else {
        viewController1 = [[DCTFirstViewController alloc] initWithNibName:@"DCTFirstViewController_iPad" bundle:nil];
    }
    viewController2 = [[DCTResultViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController3 = [[DCTSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navCtrl2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController *navCtrl3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, navCtrl2, navCtrl3, nil];
    self.window.rootViewController = self.tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
