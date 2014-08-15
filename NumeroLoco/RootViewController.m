//
//  RootViewController.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "RootViewController.h"
#import "ChaptersViewController.h"
#import "ColorsChaptersViewController.h"
#import "WordsChaptersViewController.h"
#import "AppInfo.h"
#import "TutorialViewController.h"
#import "FileSaver.h"
#import "Flurry.h"
#import <GameKit/GameKit.h>
#import "CPIAPHelper.h"
#import "IAPProduct.h"
#import "MBProgressHUD.h"
#import "MultiplayerGameViewController.h"
#import "GameKitHelper.h"

@interface RootViewController () <GKGameCenterControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *rossLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigCLabel;
@property (weak, nonatomic) IBOutlet UIView *colorBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *optionsMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *gamesMenuButton;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) UIButton *numbersButton;
@property (strong, nonatomic) UIButton *colorsButton;
@property (strong, nonatomic) UIButton *wordsButton;
@property (strong, nonatomic) UIButton *twoPlayerButton;
@property (strong, nonatomic) UIButton *removeAdsButton;
@property (strong, nonatomic) UIButton *optionsButton;
@property (strong, nonatomic) UIButton *gameCenterButton;
@property (strong, nonatomic) UIButton *backButton;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

@implementation RootViewController {
    CGRect screenBounds;
    CGFloat cornerRadius;
    BOOL isPad;
    BOOL viewIsVisible;
    CGFloat animationDistance;
    BOOL gamesButtonsDisplayed;
    BOOL viewAppearFromFirstTimeTutorial;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailedNotificationReceived:)
                                                 name:@"TransactionFailedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firsTimeTutorialNotificationReceived:)
                                                 name:@"FirstTimeTutorialNotification"
                                               object:nil];*/
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        animationDistance = 50.0;
        cornerRadius = 10.0;
    } else {
        isPad = NO;
        animationDistance = 25.0;
        cornerRadius = 5.0;
    }
    self.navigationController.navigationBarHidden = YES;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    viewIsVisible = YES;

    if (viewAppearFromFirstTimeTutorial) {
        [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        viewAppearFromFirstTimeTutorial = NO;
    }
    
    //Check if this is the first time the user launch the app
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        viewAppearFromFirstTimeTutorial = YES;
        
        [fileSaver setDictionary:@{@"FirstAppLaunchKey" : @YES} withName:@"FirstAppLaunchDic"];
        [self goToTutorialVC];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    viewIsVisible = NO;
}

-(void)setupUI {
    CGRect buttonFrames;
    CGRect backButtonFrame;
    CGRect gamesButtonsFrames;
    NSUInteger buttonsHeight = 0;
    NSUInteger fontSize = 0;
    NSUInteger borderWidth;
    NSString *fontName = nil;
    if (isPad) {
        borderWidth = 2.0;
        backButtonFrame = CGRectMake(0.0, 0.0, 150.0, 70.0);
        buttonFrames = CGRectMake(0.0, 0.0, 237.0, 97.0);
        gamesButtonsFrames = CGRectMake(0.0, 0.0, 237.0, 97.0);
        fontSize = 40.0;
        buttonsHeight = 70.0;
        fontName = @"HelveticaNeue-Light";
    } else {
        borderWidth = 1.0;
        backButtonFrame = CGRectMake(0.0, 0.0, 80.0, 35.0);
        buttonFrames = CGRectMake(0.0, 0.0, 150.0, 70.0);
        gamesButtonsFrames = CGRectMake(0.0, 0.0, 100.0, 50.0);
        fontSize = 20.0;
        buttonsHeight = 40.0;
        fontName = @"HelveticaNeue-Light";
    }
    
    if (self.view.bounds.size.height > 500) {
        self.rossLabel.center = CGPointMake(self.rossLabel.center.x, self.bigCLabel.frame.origin.y + self.bigCLabel.frame.size.height - 40.0);
    } else {
        self.rossLabel.center = CGPointMake(self.rossLabel.center.x, self.bigCLabel.frame.origin.y + self.bigCLabel.frame.size.height - 65.0);
    }
    
    //ColorBackgroundView
    self.colorBackgroundView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height/2.0);
    NSUInteger randomColor = arc4random()%3;
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColor];
    self.colorBackgroundView.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColor];
    self.bigCLabel.textColor = [[AppInfo sharedInstance] appColorsArray][randomColor];
    
    //GameMenu & OptionsMenu Buttons
    self.gamesMenuButton.frame = buttonFrames;
    [self.gamesMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gamesMenuButton.center = CGPointMake(self.view.center.x, self.view.center.y + (self.view.bounds.size.height/4.0) - self.gamesMenuButton.bounds.size.height/2.0 - 10.0);
    self.gamesMenuButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize + 10.0];
    [self.gamesMenuButton addTarget:self action:@selector(showGameMenuOptions) forControlEvents:UIControlEventTouchUpInside];
    self.gamesMenuButton.layer.cornerRadius = 10.0;
    self.gamesMenuButton.layer.borderWidth = borderWidth;
    self.gamesMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.optionsMenuButton.frame = buttonFrames;
    [self.optionsMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.optionsMenuButton.center = CGPointMake(self.view.center.x, self.view.center.y + (self.view.bounds.size.height/4.0) + self.optionsMenuButton.frame.size.height/2.0 + 10.0);
    self.optionsMenuButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize + 10.0];
    self.optionsMenuButton.layer.cornerRadius = 10.0;
    self.optionsMenuButton.layer.borderWidth = borderWidth;
    self.optionsMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.optionsMenuButton addTarget:self action:@selector(showOptionsButtons) forControlEvents:UIControlEventTouchUpInside];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //Numbers labels
    //5 label
    /*self.firstLabel.layer.cornerRadius = cornerRadius;
    self.firstLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.firstLabel.textAlignment = NSTextAlignmentCenter;*/
    
    /*//4 label
    self.secondLabel.text = @"R";
    self.secondLabel.backgroundColor = [UIColor whiteColor];
    self.secondLabel.layer.cornerRadius = cornerRadius;
    self.secondLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.secondLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //2 label
    self.thirdLabel.text = @"O";
    self.thirdLabel.backgroundColor = [UIColor whiteColor];
    self.thirdLabel.layer.cornerRadius = cornerRadius;
    self.thirdLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.thirdLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //1 label
    self.fourthLabel.text = @"S";
    self.fourthLabel.backgroundColor = [UIColor whiteColor];
    self.fourthLabel.layer.cornerRadius = cornerRadius;
    self.fourthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fourthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //0 label
    self.fifthLabel.text = @"S";
    self.fifthLabel.backgroundColor = [UIColor whiteColor];
    self.fifthLabel.layer.cornerRadius = cornerRadius;
    self.fifthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fifthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];*/
    
    //Tutorial
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.optionsButton.frame = gamesButtonsFrames;
    self.optionsButton.center = CGPointMake(self.view.bounds.size.width + self.optionsButton.frame.size.width/2.0, self.view.center.y + self.view.frame.size.height/4.0);
    [self.optionsButton setTitle:@"Tutorial" forState:UIControlStateNormal];
    [self.optionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.optionsButton.layer.cornerRadius = cornerRadius;
    self.optionsButton.layer.borderWidth = borderWidth;
    self.optionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.optionsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.optionsButton addTarget:self action:@selector(goToTutorialVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //Remove Ads button
    self.removeAdsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.removeAdsButton.frame = gamesButtonsFrames;
    self.removeAdsButton.center = CGPointMake(self.view.frame.size.width + self.removeAdsButton.frame.size.width/2.0, self.optionsButton.center.y - self.optionsButton.bounds.size.height - 20.0);
    [self.removeAdsButton setTitle:@"Remove Ads" forState:UIControlStateNormal];
    [self.removeAdsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.removeAdsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize - 6.0];
    self.removeAdsButton.layer.cornerRadius = cornerRadius;
    self.removeAdsButton.layer.borderWidth = borderWidth;
    self.removeAdsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.removeAdsButton addTarget:self action:@selector(buyNoAds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeAdsButton];
    
    ////////////////////////////////////////////////////////////////////////////////////////
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.frame = gamesButtonsFrames;
    self.colorsButton.center = CGPointMake(self.view.bounds.size.width + self.colorsButton.frame.size.width/2.0, self.view.center.y + self.view.frame.size.height/4.0);
    [self.colorsButton setTitle:@"Colors" forState:UIControlStateNormal];
    [self.colorsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.colorsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.colorsButton addTarget:self action:@selector(goToColorsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    self.colorsButton.layer.cornerRadius = 10.0;
    self.colorsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.colorsButton.layer.borderWidth = borderWidth;
    [self.view addSubview:self.colorsButton];
    
    //Numbers Button
    self.numbersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.numbersButton.frame = gamesButtonsFrames;
    self.numbersButton.center = CGPointMake(self.view.frame.size.width + self.numbersButton.frame.size.width/2.0, self.colorsButton.center.y - self.colorsButton.bounds.size.height - 20.0);
    [self.numbersButton setTitle:@"Numbers" forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    self.numbersButton.layer.cornerRadius = 10.0;
    self.numbersButton.layer.borderWidth = borderWidth;
    self.numbersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.numbersButton];
    
    //Two Players Button
    if (isPad) {
        self.twoPlayerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.twoPlayerButton.frame = gamesButtonsFrames;
        self.twoPlayerButton.center = CGPointMake(self.view.frame.size.width + self.twoPlayerButton.frame.size.width/2.0, self.colorsButton.center.y + self.colorsButton.frame.size.height + 20.0);
        self.twoPlayerButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
        [self.twoPlayerButton setTitle:@"2-Players Vs" forState:UIControlStateNormal];
        [self.twoPlayerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.twoPlayerButton addTarget:self action:@selector(goToMultiplayerVC) forControlEvents:UIControlEventTouchUpInside];
        self.twoPlayerButton.layer.cornerRadius = 10.0;
        self.twoPlayerButton.layer.borderWidth = borderWidth;
        self.twoPlayerButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.view addSubview:self.twoPlayerButton];
    }
    
    //Words Button
    /*self.wordsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.wordsButton.frame = gamesButtonsFrames;
    self.wordsButton.center = CGPointMake(self.view.frame.size.width + self.wordsButton.frame.size.width/2.0, self.colorsButton.center.y + self.colorsButton.frame.size.height + 20.0);
    [self.wordsButton setTitle:@"Words" forState:UIControlStateNormal];
    [self.wordsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.wordsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.wordsButton.layer.borderWidth = 1.0;
    self.wordsButton.layer.cornerRadius = 10.0;
    [self.wordsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.wordsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.wordsButton addTarget:self action:@selector(goToWordsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.wordsButton];*/
    
    //GameCenter BUtton
    self.gameCenterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.gameCenterButton.frame = gamesButtonsFrames;
    self.gameCenterButton.center = CGPointMake(self.view.frame.size.width + self.gameCenterButton.frame.size.width/2.0, self.optionsButton.center.y + self.optionsButton.frame.size.height + 20.0);
    [self.gameCenterButton setTitle:@"Game Center" forState:UIControlStateNormal];
    [self.gameCenterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gameCenterButton.layer.cornerRadius = cornerRadius;
    self.gameCenterButton.layer.borderWidth = borderWidth;
    self.gameCenterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.gameCenterButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize - 6.0];
    [self.gameCenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.gameCenterButton];
    
    //BackButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = backButtonFrame;
    self.backButton.center = CGPointMake(self.backButton.frame.size.width/2.0 + 10.0, self.view.frame.size.height + self.backButton.frame.size.height/2.0);
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.backButton addTarget:self action:@selector(showInitialMenuButtons) forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton.layer.cornerRadius = 7.0;
    self.backButton.layer.borderWidth = borderWidth;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.backButton];
}

#pragma mark - Animations 

-(void)showOptionsButtons {
    gamesButtonsDisplayed = NO;
    
    [UIView animateWithDuration:1.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.gamesMenuButton.center = CGPointMake(-self.gamesMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(-self.optionsMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height - self.backButton.frame.size.height/2.0 - 10.0);
                         
                         self.optionsButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.optionsButton.center.y);
                         self.gameCenterButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.gameCenterButton.center.y);
                         self.removeAdsButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.removeAdsButton.center.y);
                     } completion:^(BOOL finished){}];
}

-(void)showInitialMenuButtons {
    [UIView animateWithDuration:1.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         if (gamesButtonsDisplayed) {
                             //Hidde Game Buttons
                             self.numbersButton.center = CGPointMake(self.view.bounds.size.width + self.numbersButton.frame.size.width/2.0, self.numbersButton.center.y);
                             self.colorsButton.center = CGPointMake(self.view.bounds.size.width + self.colorsButton.frame.size.width/2.0, self.colorsButton.center.y);
                             //self.wordsButton.center = CGPointMake(self.view.bounds.size.width + self.wordsButton.frame.size.width/2.0, self.wordsButton.center.y);
                             self.twoPlayerButton.center = CGPointMake(self.view.bounds.size.width + self.twoPlayerButton.frame.size.width/2.0, self.twoPlayerButton.center.y);
                         
                         } else {
                             //Hidde optionsbuttons
                             self.removeAdsButton.center = CGPointMake(self.view.bounds.size.width + self.removeAdsButton.frame.size.width/2.0, self.removeAdsButton.center.y);
                             self.gameCenterButton.center = CGPointMake(self.view.bounds.size.width + self.gameCenterButton.frame.size.width/2.0, self.gameCenterButton.center.y);
                             self.optionsButton.center = CGPointMake(self.view.bounds.size.width + self.optionsButton.frame.size.width/2.0, self.optionsButton.center.y);

                         }
                         self.backButton.center = CGPointMake(10.0 + self.backButton.frame.size.width/2.0, self.view.bounds.size.height + self.backButton.frame.size.height/2.0);
                         
                         self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.optionsMenuButton.center.y);
                         
                     } completion:^(BOOL success){}];
}

-(void)showGameMenuOptions {
    gamesButtonsDisplayed = YES;
    
    [UIView animateWithDuration:1.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.gamesMenuButton.center = CGPointMake(-self.gamesMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(-self.optionsMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.numbersButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.numbersButton.center.y);
                         self.colorsButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.colorsButton.center.y);
                         //self.wordsButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.wordsButton.center.y);
                         self.twoPlayerButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.twoPlayerButton.center.y);
                         self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height - self.backButton.frame.size.height/2.0 - 20.0);
                     } completion:^(BOOL finished){}];
}

/*-(void)animateLabel:(UILabel *)label {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         label.transform = CGAffineTransformMakeTranslation(0.0, -animationDistance);
                     } completion:^(BOOL finished){
                         if (viewIsVisible) [self animateLabelSecondMovement:label];
                     }];
}

-(void)animateLabelSecondMovement:(UILabel *)label {
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         label.transform = CGAffineTransformMakeTranslation(0.0, animationDistance);
                     } completion:^(BOOL finished){
                         if (viewIsVisible) [self animateLabelThirdMovement:label];
                     }];
}

-(void)animateLabelThirdMovement:(UILabel *)label {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(){
                         label.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
                     } completion:^(BOOL finished){
                         if (viewIsVisible) [self animateLabel:label];
                     }];
}*/

#pragma mark - Actions

/*-(void)showGameButtons {
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.onePlayerButton.transform = CGAffineTransformMakeTranslation(-2*(self.onePlayerButton.frame.origin.x + self.onePlayerButton.frame.size.width + 10), 0.0);
                         self.colorsButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.colorsButton.frame.size.width/2.0), 0.0);
                         self.numbersButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.numbersButton.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){}];

}*/

-(void)goToMultiplayerVC {
    MultiplayerGameViewController *multiplayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGame"];
    multiplayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:multiplayerVC animated:YES completion:nil];
}

-(void)buyNoAds {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        if (success) {
            if (products) {
                for (IAPProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.noads"]) {
                        NSLog(@"Compraré el productooooooo");
                        [[CPIAPHelper sharedInstance] buyProduct:product];
                        break;
                    }
                }
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error trying to connect. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"There was an error trying to connect. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

-(void)showGameCenter {
    GKGameCenterViewController *gameViewController = [[GKGameCenterViewController alloc] init];
    if (gameViewController) {
        NSLog(@"Entré a mostrar el controlador de game center");
        gameViewController.gameCenterDelegate = self;
        [self presentViewController:gameViewController animated:YES completion:nil];
    } 
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(void)animatePlayersButtons {
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.startButton.transform = CGAffineTransformMakeTranslation(-(self.startButton.frame.origin.x + self.startButton.frame.size.width + 10), 0.0);
                         self.onePlayerButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.numbersButton.frame.size.width/2.0), 0.0);
                         self.twoPlayerButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.colorsButton.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){}];
}

-(void)animateGameButtons {
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.startButton.transform = CGAffineTransformMakeTranslation(-(self.startButton.frame.origin.x + self.startButton.frame.size.width + 10), 0.0);
                         self.numbersButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.numbersButton.frame.size.width/2.0), 0.0);
                         self.colorsButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.colorsButton.frame.size.width/2.0), 0.0);
                         self.wordsButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.colorsButton.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){}];
}*/

-(void)goToColorsChaptersVC {
    [Flurry logEvent:@"OpenColorsChapters"];
    ColorsChaptersViewController *colorsChaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorsChapters"];
    colorsChaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorsChaptersVC animated:YES completion:nil];
    
}

-(void)goToChaptersVC {
    [Flurry logEvent:@"OpenNumbersChapters"];
    ChaptersViewController *chaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapters"];
    chaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:chaptersVC animated:YES completion:nil];
}

-(void)goToTutorialVC {
    [Flurry logEvent:@"OpenTutorial"];
    TutorialViewController *tutorialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    //tutorialVC.viewControllerAppearedFromInitialLaunching = viewAppearFromFirstTimeTutorial;
    [self presentViewController:tutorialVC animated:YES completion:nil];
}

-(void)goToWordsChaptersVC {
    WordsChaptersViewController *wordsChapterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WordsChapters"];
    wordsChapterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:wordsChapterVC animated:YES completion:nil];
}

#pragma mark - GameCenterDelegate

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    NSLog(@"Me saldréeee de game center oiiiiiiiiissssssssssss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Falló la transacción");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción");
    //[[[UIAlertView alloc] initWithTitle:nil message:@"Purchase complete!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
    //Save a key in FileSaver indicating that the user has removed the ads
    FileSaver *fileSaver = [[FileSaver alloc] init];
    [fileSaver setDictionary:@{@"UserRemovedAdsKey" : @YES} withName:@"UserRemovedAdsDic"];
}

/*-(void)firsTimeTutorialNotificationReceived:(NSNotification *)notification {
    NSLog(@"Me llegó la notificacion*****");
    viewAppearFromFirstTimeTutorial = YES;
}*/

@end
