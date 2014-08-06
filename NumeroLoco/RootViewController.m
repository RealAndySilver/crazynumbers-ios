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

@interface RootViewController () <GKGameCenterControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) UIButton *numbersButton;
@property (strong, nonatomic) UIButton *colorsButton;
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UIButton *wordsButton;
@property (strong, nonatomic) UIButton *onePlayerButton;
@property (strong, nonatomic) UIButton *twoPlayerButton;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

@implementation RootViewController {
    CGRect screenBounds;
    CGFloat cornerRadius;
    BOOL isPad;
    BOOL viewIsVisible;
    CGFloat animationDistance;
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        animationDistance = 50.0;
        cornerRadius = 10.0;
    } else {
        isPad = NO;
        animationDistance = 25.0;
        cornerRadius = 5.0;
    }
    self.view.backgroundColor = [[[AppInfo sharedInstance] appColorsArray] firstObject];
    self.navigationController.navigationBarHidden = YES;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Animate labels
    //[self performSelector:@selector(animateLabel:) withObject:self.firstLabel afterDelay:0.1];
    //[self performSelector:@selector(animateLabel:) withObject:self.secondLabel afterDelay:0.3];
    //[self performSelector:@selector(animateLabel:) withObject:self.thirdLabel afterDelay:0.5];
    //[self performSelector:@selector(animateLabel:) withObject:self.fourthLabel afterDelay:0.7];
    //[self performSelector:@selector(animateLabel:) withObject:self.fifthLabel afterDelay:0.9];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    viewIsVisible = YES;

    //Check if this is the first time the user launch the app
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        [fileSaver setDictionary:@{@"FirstAppLaunchKey" : @YES} withName:@"FirstAppLaunchDic"];
        [self goToTutorialVC];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    viewIsVisible = NO;
    self.firstLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    self.secondLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    self.thirdLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    self.fourthLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    self.fifthLabel.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
}

-(void)setupUI {
    NSUInteger buttonsHeight = 0;
    NSUInteger fontSize = 0;
    NSString *fontName = nil;
    if (isPad) {
        fontSize = 40.0;
        buttonsHeight = 70.0;
        fontName = @"HelveticaNeue-UltraLight";
    } else {
        fontSize = 20.0;
        buttonsHeight = 40.0;
        fontName = @"HelveticaNeue-Light";
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //Numbers labels
    //5 label
    self.firstLabel.text = @"C";
    self.firstLabel.backgroundColor = [UIColor whiteColor];
    self.firstLabel.layer.cornerRadius = cornerRadius;
    self.firstLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.firstLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    
    //4 label
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
    else        self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //Remove Ads button
    UIButton *removeAdsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    removeAdsButton.frame = CGRectMake(screenBounds.size.width/2.0 - (screenBounds.size.width/6.4), screenBounds.size.height - 80.0, screenBounds.size.width/6.4*2, buttonsHeight);
    [removeAdsButton setTitle:@"Remove Ads" forState:UIControlStateNormal];
    [removeAdsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    removeAdsButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0];
    //removeAdsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //removeAdsButton.layer.borderWidth = 1.0;
    removeAdsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize - 6.0];
    removeAdsButton.layer.cornerRadius = cornerRadius;
    [removeAdsButton addTarget:self action:@selector(buyNoAds) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeAdsButton];
    
    //Tutorial
    UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    optionsButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0];
    //optionsButton.layer.borderWidth = 1.0;
    //optionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    optionsButton.layer.cornerRadius = cornerRadius;
    [optionsButton setTitle:@"Tutorial" forState:UIControlStateNormal];
    [optionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    optionsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    optionsButton.frame = CGRectOffset(removeAdsButton.frame, 0.0, -(10.0 + removeAdsButton.frame.size.height));
    [optionsButton addTarget:self action:@selector(goToTutorialVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optionsButton];
    
    //Start Option
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButton.backgroundColor = [UIColor whiteColor];
    //self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.cornerRadius = cornerRadius;
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.startButton.frame = CGRectOffset(optionsButton.frame, 0.0, -(10.0 + optionsButton.frame.size.height));
    if (isPad) {
        [self.startButton addTarget:self action:@selector(animatePlayersButtons) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.startButton addTarget:self action:@selector(animateGameButtons) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.startButton];
    
    /////////////////////////////////////////////////////////////////////////////////////////
    if (isPad) {
        //One Player Button
        self.onePlayerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.onePlayerButton.backgroundColor = [UIColor whiteColor];
        self.onePlayerButton.layer.cornerRadius = cornerRadius;
        [self.onePlayerButton setTitle:@"One Player" forState:UIControlStateNormal];
        [self.onePlayerButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
        self.onePlayerButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
        //self.onePlayerButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y, screenBounds.size.width/6.4*2, buttonsHeight);
        self.onePlayerButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y - 10.0 - buttonsHeight, screenBounds.size.width/6.4*2, buttonsHeight);
        [self.onePlayerButton addTarget:self action:@selector(showGameButtons) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.onePlayerButton];
        
        //Numbers Button
        self.twoPlayerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.twoPlayerButton.backgroundColor = [UIColor whiteColor];
        self.twoPlayerButton.layer.cornerRadius = cornerRadius;
        [self.twoPlayerButton setTitle:@"Two Player Vs" forState:UIControlStateNormal];
        [self.twoPlayerButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
        self.twoPlayerButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
        self.twoPlayerButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y, screenBounds.size.width/6.4*2, buttonsHeight);
        [self.twoPlayerButton addTarget:self action:@selector(goToMultiplayerVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.twoPlayerButton];
    }
    
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.backgroundColor = [UIColor whiteColor];
    //self.colorsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.colorsButton.layer.borderWidth = 1.0;
    self.colorsButton.layer.cornerRadius = cornerRadius;
    [self.colorsButton setTitle:@"Colors" forState:UIControlStateNormal];
    [self.colorsButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.colorsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    if (!isPad)
        self.colorsButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y, screenBounds.size.width/6.4*2, buttonsHeight);
    else
        self.colorsButton.frame = CGRectMake(screenBounds.size.width, self.onePlayerButton.frame.origin.y, screenBounds.size.width/6.4*2, buttonsHeight);
    [self.colorsButton addTarget:self action:@selector(goToColorsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.colorsButton];
    
    //Numbers Button
    self.numbersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.numbersButton.backgroundColor = [UIColor whiteColor];
    //self.numbersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.numbersButton.layer.borderWidth = 1.0;
    self.numbersButton.layer.cornerRadius = cornerRadius;
    [self.numbersButton setTitle:@"Numbers" forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    if (!isPad)
        self.numbersButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y - 10.0 - buttonsHeight, screenBounds.size.width/6.4*2, buttonsHeight);
    else
        self.numbersButton.frame = CGRectMake(screenBounds.size.width, self.onePlayerButton.frame.origin.y - 10.0 - buttonsHeight, screenBounds.size.width/6.4*2, buttonsHeight);
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.numbersButton];
    
    //Words Button
    self.wordsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.wordsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.wordsButton.layer.borderWidth = 1.0;
    self.wordsButton.layer.cornerRadius = cornerRadius;
    [self.wordsButton setTitle:@"Words" forState:UIControlStateNormal];
    [self.wordsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.wordsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.wordsButton.frame = CGRectMake(screenBounds.size.width, self.numbersButton.frame.origin.y - 10.0 - buttonsHeight, screenBounds.size.width/6.4*2, buttonsHeight);
    [self.wordsButton addTarget:self action:@selector(goToWordsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
   // [self.view addSubview:self.wordsButton];
    
    //Back button
    /*UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(20.0, screenBounds.size.height - 80.0, screenBounds.size.width/4.57, buttonsHeight);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    backButton.layer.cornerRadius = cornerRadius;
    backButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];*/
    
    //GameCenter BUtton
    UIButton *gameCenterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    gameCenterButton.frame = CGRectMake(screenBounds.size.width - 20.0 - (screenBounds.size.width/4.57), screenBounds.size.height - 80.0, screenBounds.size.width/4.57, buttonsHeight);
    gameCenterButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0];
    [gameCenterButton setTitle:@"My Points" forState:UIControlStateNormal];
    [gameCenterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //gameCenterButton.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:160.0/255.0 blue:122.0/255.0 alpha:1.0].CGColor;
    //gameCenterButton.layer.borderWidth = 1.0;
    gameCenterButton.layer.cornerRadius = cornerRadius;
    gameCenterButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize - 6.0];
    [gameCenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gameCenterButton];
}

#pragma mark - Animations 

-(void)animateLabel:(UILabel *)label {
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
}

#pragma mark - Actions

-(void)showGameButtons {
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

}

-(void)goToMultiplayerVC {
    MultiplayerGameViewController *multiplayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGame"];
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

-(void)animatePlayersButtons {
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
}

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
    [self presentViewController:tutorialVC animated:YES completion:nil];
}

-(void)goToWordsChaptersVC {
    WordsChaptersViewController *wordsChapterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WordsChapters"];
    wordsChapterVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:wordsChapterVC animated:YES completion:nil];
}

#pragma mark - GameCenterDelegate

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
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


@end
