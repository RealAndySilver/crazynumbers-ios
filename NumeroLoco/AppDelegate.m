//
//  AppDelegate.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "FileSaver.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Flurry.h"
#import "FlurryAds.h"
#import "CPIAPHelper.h"
#import "FileSaver.h"
#import "GameKitHelper.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Init our InApp-Purchases Helper Singleton
    [CPIAPHelper sharedInstance];
    
    //Facebook Setup
    [FBLoginView class];
    
    //Flurry Setup
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"F3B2NR3G33WX6BTWXFFQ"];
    [FlurryAds initialize:self.window.rootViewController];
    
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if ([fileSaver getDictionary:@"NumberChaptersDic"]) {
        NSLog(@"Ya existía el dic");
    } else {
        NSLog(@"No existía el dic");
        [fileSaver setDictionary:@{@"NumberChaptersArray" : @[@[@1],
                                                              @[],
                                                              @[],
                                                              @[]]} withName:@"NumberChaptersDic"];
        
        [fileSaver setDictionary:@{@"ColorChaptersArray" : @[@[@1],
                                                              @[],
                                                              @[],
                                                              @[]]} withName:@"ColorChaptersDic"];
        
        [fileSaver setDictionary:@{@"WordChaptersArray" : @[@[@1],
                                                             @[],
                                                             @[],
                                                             @[]]} withName:@"WordChaptersDic"];
    }
    
    if ([fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

@end
