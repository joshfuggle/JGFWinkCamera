//
//  AppDelegate.m
//  Hoodwinked
//
//  Created by Joshua Fuglsang on 4/11/2015.
//  Copyright © 2015 Joshua Fuglsang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // No storyboards. Set the window & root view controller.
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.rootViewController = [[ViewController alloc] init];
    self.window = window;
    [window makeKeyAndVisible];
    
    return YES;
}

@end
