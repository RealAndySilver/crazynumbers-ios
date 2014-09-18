//
//  AppDelegate.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Flurry.h"
#import "FlurryAds.h"
#import "CPIAPHelper.h"
#import "FileSaver.h"
#import "GameKitHelper.h"
#import "TouchesObject.h"
#import <Parse/Parse.h>
#import "OneButtonAlert.h"
#import "AppInfo.h"

#define TIME_FOR_NEW_TOUCHES 3600
#define TIME_FOR_NEW_LIVES 3600
#define NEW_LIVES 5
#define NEW_TOUCHES 120

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Parse & Facebook setup
    [Parse setApplicationId:@"Z9VRUjoPPSMl2PQqQYVncx6UPjReI47lKROjPwkW"
                  clientKey:@"pCLXgoDeQGR6cZZ62DK1CtNzCHFqMheI5qDHSy8e"];
    [PFFacebookUtils initializeFacebook];
    
    //Register for remote notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    //Init our InApp-Purchases Helper Singleton
    [CPIAPHelper sharedInstance];
 
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
        
    }
    
    //Save maximum touches in User Defaults
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Touches"] == nil) {
        //First time the user launches the app
        [[NSUserDefaults standardUserDefaults] setObject:@(NEW_TOUCHES)forKey:@"Touches"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [TouchesObject sharedInstance].totalTouches = NEW_TOUCHES;
    } else {
        //Init our touches singleton
        [TouchesObject sharedInstance].totalTouches = [self getTouchesLeftInUserDefaults];
    }
    
    /////////////////////////////////////////////////////////////////
    //Set initial unlocked game in fast game mode. Just the first game
    //is unlocked
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"unlockedFastGames"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"unlockedFastGames"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //Set initial lives for fast game mode
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"lives"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //Check if the user has already launch the app, and show game center inmediatly
    /*if ([[fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"] boolValue]) {
    }*/
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    [self checkForNewTouchesAndLives];
  
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
    
    NSLog(@"ME DESACTIVAREEEEEEEEEE");
    [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self checkForNewTouchesAndLives];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"RECIBI NOTIFICATION LOCAL");
    NSString *notificationID = notification.userInfo[@"notificationID"];
    if ([notificationID isEqualToString:@"touchesNotification"]) {
        [self restoreTouches];
        [self showNewTouchesAlertWithMessage:@"All your touches have been restored!"];
        
    } else if ([notificationID isEqualToString:@"livesNotification"]) {
        [self restoreLives];
        [self showNewLivesAlertWithMessage:@"All your lives have been restored!"];
    }
}

#pragma mark - Alerts 

-(void)showNewTouchesAlertWithMessage:(NSString *)message {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    OneButtonAlert *newTouchesAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 110.0, screenBounds.size.height/2.0 - 75.0, 220, 150.0)];
    newTouchesAlert.alertText = message;
    newTouchesAlert.buttonTitle = @"Ok";
    newTouchesAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    newTouchesAlert.messageLabel.frame = CGRectMake(20.0, 30.0, newTouchesAlert.bounds.size.width - 40.0, 50.0);
    newTouchesAlert.button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][1];
    [newTouchesAlert showOnWindow:self.window];
}

-(void)showNewLivesAlertWithMessage:(NSString *)message {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    OneButtonAlert *newLivesAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 110.0, screenBounds.size.height/2.0 - 75.0, 220, 150.0)];
    newLivesAlert.alertText = message;
    newLivesAlert.buttonTitle = @"Ok";
    newLivesAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    newLivesAlert.messageLabel.frame = CGRectMake(20.0, 30.0, newLivesAlert.bounds.size.width - 40.0, 50.0);
    newLivesAlert.button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][1];
    [newLivesAlert showOnWindow:self.window];
}

#pragma mark - NSUserDefaults

-(NSArray *)getSavedDatesArray {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GiveTouchesDatesArray"]) {
        NSArray *savedDatesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"GiveTouchesDatesArray"];
        return savedDatesArray;
    } else {
        return nil;
    }
}

-(NSArray *)getLivesDatesArray {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"]) {
        NSArray *savedDatesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"];
        return savedDatesArray;
    } else {
        return nil;
    }
}

-(void)saveDatesArrayInUserDefaults:(NSArray *)datesArray {
    [[NSUserDefaults standardUserDefaults] setObject:datesArray forKey:@"GiveTouchesDatesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveLivesDatesArrayInUserDefaults:(NSArray *)datesArray {
    [[NSUserDefaults standardUserDefaults] setObject:datesArray forKey:@"GiveLivesDatesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSUInteger)getTouchesLeftInUserDefaults {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"Touches"] intValue];
}

-(NSUInteger)getLivesLeftInUserDefaults {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
}

-(void)saveLivesLeftInUserDefaults:(NSUInteger)livesLeft {
    [[NSUserDefaults standardUserDefaults] setObject:@(livesLeft) forKey:@"lives"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveTouchesLeftInUserDefaults:(NSUInteger)touchesLeft {
    [[NSUserDefaults standardUserDefaults] setObject:@(touchesLeft) forKey:@"Touches"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Custom Methods

-(void)restoreLives {
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Lives stuff
    NSMutableArray *savedLivesDatesArray = [[NSMutableArray alloc] initWithArray:[self getLivesDatesArray]];
    if (savedLivesDatesArray && [savedLivesDatesArray count] > 0) {
        for (int i = 0; i< [savedLivesDatesArray count]; i++) {
            NSDate *savedDate = savedLivesDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                //Ya pasó la fecha guardada, entonces demos cinco toques
                if ([self getLivesLeftInUserDefaults] < 5) {
                    //Dar los toques
                    [self saveLivesLeftInUserDefaults:[self getLivesLeftInUserDefaults] + 1];
                }
            }
        }
        
        NSMutableArray *tempLivesArray = [NSMutableArray arrayWithArray:savedLivesDatesArray];
        for (int i = 0; i < [savedLivesDatesArray count]; i++) {
            NSDate *savedDate = savedLivesDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                [tempLivesArray removeObject:savedDate];
            }
        }
        
        //Save the new dates array
        [self saveLivesDatesArrayInUserDefaults:tempLivesArray];
        //Post a notification in case the user in on the game screen,
        //to update the screen with the new touches
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewLivesAvailable" object:nil];
    }
}

-(void)restoreTouches {
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Touches stuff
    NSMutableArray *savedDatesArray = [[NSMutableArray alloc] initWithArray:[self getSavedDatesArray]];
    if (savedDatesArray && [savedDatesArray count] > 0) {
        for (int i = 0; i < [savedDatesArray count]; i++) {
            NSDate *savedDate = savedDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                //Ya pasó la fecha guardada, entonces demos cinco toques
                if ([TouchesObject sharedInstance].totalTouches < 120) {
                    //Dar los toques
                    [TouchesObject sharedInstance].totalTouches += 5;
                    if ([TouchesObject sharedInstance].totalTouches > 120.0) {
                        [TouchesObject sharedInstance].totalTouches = 120.0;
                    }
                }
            }
        }
        
        //Remove the dates that were already used to give touches
        NSLog(@"******************* NUMERO DE FECHAS GUARDADAS: %lu", (unsigned long)[savedDatesArray count]);
        NSMutableArray *tempDatesArray = [NSMutableArray arrayWithArray:savedDatesArray];
        for (int i = 0; i < [savedDatesArray count]; i++) {
            NSDate *savedDate = savedDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                [tempDatesArray removeObject:savedDate];
            }
        }
        
        //Save the new dates array
        [self saveDatesArrayInUserDefaults:tempDatesArray];
        [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
        
        //Post a notification in case the user in on the game screen,
        //to update the screen with the new touches
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTouchesAvailable" object:nil];
    }
}

-(void)checkForNewTouchesAndLives {
    static BOOL newTouchesAvailable = NO;
    static BOOL newLivesAvailable = NO;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    //Touches stuff
    NSMutableArray *savedDatesArray = [[NSMutableArray alloc] initWithArray:[self getSavedDatesArray]];
    if (savedDatesArray && [savedDatesArray count] > 0) {
        for (int i = 0; i < [savedDatesArray count]; i++) {
            NSDate *savedDate = savedDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                //Ya pasó la fecha guardada, entonces demos cinco toques
                if ([TouchesObject sharedInstance].totalTouches < 120) {
                    //Dar los toques
                    [TouchesObject sharedInstance].totalTouches += 5;
                    if ([TouchesObject sharedInstance].totalTouches > 120.0) {
                        [TouchesObject sharedInstance].totalTouches = 120.0;
                    }
                    newTouchesAvailable = YES;
                }
            }
        }
        
        //Remove the dates that were already used to give touches
        NSLog(@"******************* NUMERO DE FECHAS GUARDADAS: %lu", (unsigned long)[savedDatesArray count]);
        NSMutableArray *tempDatesArray = [NSMutableArray arrayWithArray:savedDatesArray];
        for (int i = 0; i < [savedDatesArray count]; i++) {
            NSDate *savedDate = savedDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                [tempDatesArray removeObject:savedDate];
            }
        }
        
        //Save the new dates array
        [self saveDatesArrayInUserDefaults:tempDatesArray];
        
        if (newTouchesAvailable) {
            [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
            [self showNewTouchesAlertWithMessage:@"You have new touches available!"];
            newTouchesAvailable = NO;
            
            //Post a notification in case the user in on the game screen,
            //to update the screen with the new touches
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewTouchesAvailable" object:nil];
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Lives stuff
    NSMutableArray *savedLivesDatesArray = [[NSMutableArray alloc] initWithArray:[self getLivesDatesArray]];
    if (savedLivesDatesArray && [savedLivesDatesArray count] > 0) {
        for (int i = 0; i< [savedLivesDatesArray count]; i++) {
            NSDate *savedDate = savedLivesDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                //Ya pasó la fecha guardada, entonces demos cinco toques
                if ([self getLivesLeftInUserDefaults] < 5) {
                    //Dar los toques
                    [self saveLivesLeftInUserDefaults:[self getLivesLeftInUserDefaults] + 1];
                    newLivesAvailable = YES;
                }
            }
        }
        
        NSMutableArray *tempLivesArray = [NSMutableArray arrayWithArray:savedLivesDatesArray];
        for (int i = 0; i < [savedLivesDatesArray count]; i++) {
            NSDate *savedDate = savedLivesDatesArray[i];
            if ([savedDate timeIntervalSinceNow] < 0.0) {
                [tempLivesArray removeObject:savedDate];
            }
        }
        
        //Save the new dates array
        [self saveLivesDatesArrayInUserDefaults:tempLivesArray];
        
        if (newLivesAvailable) {
            [self showNewLivesAlertWithMessage:@"You have new lives available!"];
            newLivesAvailable = NO;
            
            //Post a notification in case the user in on the game screen,
            //to update the screen with the new touches
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewLivesAvailable" object:nil];
        }
    }
}

@end
