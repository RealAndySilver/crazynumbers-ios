//
//  LoginViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 7/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"
#import "AppInfo.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "MBProgressHUD.h"
#import "GameKitHelper.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    CGRect screenBounds;
    BOOL _gameCenterEnabled;
    NSString *_leaderboardIdentifier;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //The user is loggin with facebook, go to root VC
        //[self goToRootVC];
    }
}

-(void)setupUI {
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    
    //Background Image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenBounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        backgroundImageView.image = [UIImage imageNamed:@"BackgroundiPadPortrait.png"];
    } else {
        if (screenBounds.size.height > 500) {
            //Big Screen iPhone
            backgroundImageView.image = [UIImage imageNamed:@"BackgroundiPhonePortraitR4.png"];
        } else {
            backgroundImageView.image = [UIImage imageNamed:@"BackgroundiPhonePortrait.png"];
        }
    }
    [self.view addSubview:backgroundImageView];
    
    //Dont login button
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    enterButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 120.0, screenBounds.size.height - 60.0, 240.0, 50.0);
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setTitle:@"Don't Login" forState:UIControlStateNormal];
    enterButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    enterButton.layer.cornerRadius = 10.0;
    enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    enterButton.layer.borderWidth = 1.0;
    [enterButton addTarget:self action:@selector(goToRootVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterButton];
    
    //Facebook button
    UIButton *facebookButton = [[UIButton alloc]initWithFrame:CGRectOffset(enterButton.frame, 0.0, -(enterButton.frame.size.height + 10.0))];
    [facebookButton setTitle:@"Login With Facebook" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(startLoginProcess) forControlEvents:UIControlEventTouchUpInside];
    facebookButton.layer.cornerRadius = 10.0;
    facebookButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    facebookButton.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:75.0/255.0 blue:139.0/255.0 alpha:1.0];
    [self.view addSubview:facebookButton];
}

#pragma mark - Actions 

-(void)startLoginProcess {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *permissions = @[@"public_profile", @"user_friends", @"publish_actions"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        //Error with the login
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                errorMessage = [error localizedDescription];
            }
            [[[UIAlertView alloc] initWithTitle:@"Log In Error"
                                       message:errorMessage
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"Dismiss", nil] show];
        } else {
            //Success login
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            [self goToRootVC];
        }
    }];
}

-(void)goToRootVC {
    RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Root"];
    rootVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:rootVC animated:YES completion:nil];
}

@end
