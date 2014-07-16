//
//  LoginViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 7/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController () <FBLoginViewDelegate>

@end

@implementation LoginViewController {
    CGRect screenBounds;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)setupUI {
    //Background Image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:screenBounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        backgroundImageView.image = [UIImage imageNamed:@"BackgroundPad.png"];
    } else {
        backgroundImageView.image = [UIImage imageNamed:@"Background.png"];
    }
    [self.view addSubview:backgroundImageView];
    
    //Facebook Button
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
    loginView.delegate = self;
    loginView.frame = CGRectOffset(loginView.frame, screenBounds.size.width/2.0 - loginView.frame.size.width/2.0 , screenBounds.size.height - 100.0);
    [self.view addSubview:loginView];
    
    /*UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
    facebookButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, self.view.bounds.size.height/2.0, 300.0, 40.0);
    [facebookButton setTitle:@"Login With Facebook" forState:UIControlStateNormal];
    [facebookButton addTarget:self action:@selector(startLoginProcess) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];*/
    
    //Dont login button
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    enterButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 150.0, screenBounds.size.height - 50.0, 300.0, 40.0);
    [enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [enterButton setTitle:@"Ingresar sin Facebook" forState:UIControlStateNormal];
    [enterButton addTarget:self action:@selector(goToRootVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterButton];
}

#pragma mark - Actions 

-(void)goToRootVC {
    RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Root"];
    rootVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:rootVC animated:YES completion:nil];
}

#pragma mark - FBLoginViewDelegate 

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSLog(@"Me logueé con Facebook");
    NSLog(@"UserName: %@", user.name);
    [self goToRootVC];
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"Cerré sesión con Facebook");
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
