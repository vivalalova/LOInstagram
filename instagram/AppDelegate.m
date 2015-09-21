//
//  AppDelegate.m
//  instagram
//
//  Created by ShihKuo-Hsun on 2015/5/1.
//  Copyright (c) 2015年 FT. All rights reserved.
//

#import "AppDelegate.h"
#import "FTInstagram.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FTInstagram shareInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
@end
