//
//  GSAppDelegate.m
//  Tab Hint Demo
//
//  Created by Simon Whitaker on 04/05/2013.
//  Copyright (c) 2013 Goo Software Ltd. All rights reserved.
//

#import "GSAppDelegate.h"
#import "GSDemoViewController.h"

@interface GSAppDelegate() {
    __weak UITabBarController *_tabBarController;
}
@end

@implementation GSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    // Override point for customization after application launch.
    [[self window] setBackgroundColor:[UIColor whiteColor]];
    [[self window] makeKeyAndVisible];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:4];
    
    UIViewController *viewController = [[GSDemoViewController alloc] init];
    [viewController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0]];
    [viewControllers addObject:viewController];

    viewController = [[UIViewController alloc] init];
    [viewController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:1]];
    [viewControllers addObject:viewController];

    viewController = [[UIViewController alloc] init];
    [viewController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:2]];
    [viewControllers addObject:viewController];

    [tabBarController setViewControllers:viewControllers];
    [[self window] setRootViewController:tabBarController];
    _tabBarController = tabBarController;
    
    return YES;

}

- (void)incrementDownloadBadge {
    
    static NSUInteger downloadCount = 0;
    downloadCount++;
    [[[[_tabBarController tabBar] items] objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%u", downloadCount]];
    
}

@end
