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
#import "TutorialContainerViewController.h"
#import "FastGameModeViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "TwoButtonsAlert.h"
#import "FacebookRankingList.h"
#import "OneButtonAlert.h"
#import "StoreView.h"
#import "SoundsView.h"
@import AVFoundation;

@interface RootViewController () <GKGameCenterControllerDelegate, TwoButtonsAlertDelegate>
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *views;
@property (weak, nonatomic) IBOutlet UIView *view9;
@property (weak, nonatomic) IBOutlet UIView *view8;
@property (weak, nonatomic) IBOutlet UIView *view7;
@property (weak, nonatomic) IBOutlet UIView *view6;
@property (weak, nonatomic) IBOutlet UIView *view5;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UILabel *bigCLabel;
@property (weak, nonatomic) IBOutlet UIView *colorBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *optionsMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *gamesMenuButton;
@property (strong, nonatomic) UIButton *numbersButton;
@property (strong, nonatomic) UIButton *colorsButton;
@property (strong, nonatomic) UIButton *fastModeButton;
@property (strong, nonatomic) UIButton *wordsButton;
@property (strong, nonatomic) UIButton *twoPlayerButton;
@property (strong, nonatomic) UIButton *removeAdsButton;
@property (strong, nonatomic) UIButton *optionsButton;
@property (strong, nonatomic) UIButton *gameCenterButton;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *enterButton;
@property (strong, nonatomic) UIButton *facebookButton;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIButton *soundsButton;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) AVAudioPlayer *playerButtonPressed;
@property (strong, nonatomic) AVAudioPlayer *playerBackSound;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

@implementation RootViewController {
    CGRect screenBounds;
    CGFloat cornerRadius;
    BOOL isPad;
    BOOL viewIsVisible;
    CGFloat animationDistance;
    BOOL gamesButtonsDisplayed;
    BOOL optionsButtonsDisplayed;
    BOOL mainMenuButtonsDisplayed;
    BOOL viewAppearFromFirstTimeTutorial;
    BOOL userIsLoggedIn;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playMusicNotificationReceived:)
                                                 name:@"PlayMusicNotification"
                                               object:nil];
  
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        animationDistance = 50.0;
        cornerRadius = 10.0;
    } else {
        isPad = NO;
        animationDistance = 25.0;
        cornerRadius = 10.0;
    }
    self.navigationController.navigationBarHidden = YES;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
    [self setupMusic];
    
    //Start animating views
    [self startAnimatingViews];
    
    //Check if user is logged in with facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        userIsLoggedIn = YES;
    } else {
        userIsLoggedIn = NO;
    }
    
    if (userIsLoggedIn) {
        //Dont show login buttons
        [self showMainButtonsDirectly];
    } else {
        self.logoutButton.hidden = YES;
    }
}

-(void)showMainButtonsDirectly {
    self.facebookButton.center = CGPointMake(-(self.facebookButton.frame.size.width/2.0), self.facebookButton.center.y);
    self.enterButton.center = CGPointMake(-(self.enterButton.frame.size.width/2.0), self.enterButton.center.y);
    self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.gamesMenuButton.center.y);
    self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.optionsMenuButton.center.y);
    self.logoutButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.logoutButton.center.y);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailedNotificationReceived:)
                                                 name:@"TransactionFailedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSuscribeNotificationReceived:)
                                                 name:@"UserDidSuscribe"
                                               object:nil];*/
    viewIsVisible = YES;

    /*if (viewAppearFromFirstTimeTutorial) {
        [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
        viewAppearFromFirstTimeTutorial = NO;
    }*/
    
    //Check if this is the first time the user launch the app
    /*FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"] boolValue]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        viewAppearFromFirstTimeTutorial = YES;
        
        [fileSaver setDictionary:@{@"FirstAppLaunchKey" : @YES} withName:@"FirstAppLaunchDic"];
        NSLog(@"Iré al tutorial");
        [self goToTutorialVC];
    } else {
        NSLog(@"No iré al tutorial");
    }*/
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TransactionFailedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UserDidSuscribe" object:nil];
    viewIsVisible = NO;
}

-(void)setupMusic {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"crossbg" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
    self.player.numberOfLoops = -1;
    [self.player prepareToPlay];
    [self.player play];
    
    //Button pressed player
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"buttonpress" ofType:@"wav"];
    soundFileURL = nil;
    soundFileURL = [NSURL URLWithString:soundFilePath];
    self.playerButtonPressed = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [self.playerButtonPressed prepareToPlay];
    
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"wav"];
    soundFileURL = nil;
    soundFileURL = [NSURL URLWithString:soundFilePath];
    self.playerBackSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [self.playerBackSound prepareToPlay];
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
        gamesButtonsFrames = CGRectMake(0.0, 0.0, 237.0, 60.0);
        fontSize = 40.0;
        buttonsHeight = 70.0;
        fontName = @"HelveticaNeue-Light";
    } else {
        borderWidth = 1.0;
        backButtonFrame = CGRectMake(0.0, 0.0, 70.0, 40.0);
        buttonFrames = CGRectMake(0.0, 0.0, 100.0, 50.0);
        gamesButtonsFrames = CGRectMake(0.0, 0.0, 100.0, screenBounds.size.height/11.36);
        fontSize = 20.0;
        buttonsHeight = 40.0;
        fontName = @"HelveticaNeue-Light";
    }
    
    //Buttons views
    for (UIView *view in self.views) {
        view.layer.cornerRadius = 10.0;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.layer.borderWidth = 1.0;
        view.backgroundColor = [UIColor clearColor];
    }
    
    //views background color
    self.view2.backgroundColor = [UIColor whiteColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor whiteColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    
    //Dont login button
    self.enterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.enterButton.frame = CGRectMake(self.view.bounds.size.width/2.0 - 90, screenBounds.size.height - 60.0, 180.0, 50.0);
    [self.enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.enterButton setTitle:NSLocalizedString(@"Don't Login", @"Button to enter without login") forState:UIControlStateNormal];
    self.enterButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    self.enterButton.layer.cornerRadius = 10.0;
    self.enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.enterButton.layer.borderWidth = 1.0;
    [self.enterButton addTarget:self action:@selector(animateMainButtons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.enterButton];
    
    //Facebook button
    self.facebookButton = [[UIButton alloc]initWithFrame:CGRectOffset(self.enterButton.frame, 0.0, -(self.enterButton.frame.size.height + 10.0))];
    [self.facebookButton setTitle:NSLocalizedString(@"Login With Facebook", @"Button to enter with facebook") forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(startLoginProcess) forControlEvents:UIControlEventTouchUpInside];
    self.facebookButton.layer.cornerRadius = 10.0;
    self.facebookButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    self.facebookButton.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:75.0/255.0 blue:139.0/255.0 alpha:1.0];
    [self.view addSubview:self.facebookButton];
    
    //ColorBackgroundView
    self.colorBackgroundView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height/2.0);
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.colorBackgroundView.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    
    //GameMenu & OptionsMenu Buttons
    self.gamesMenuButton.frame = buttonFrames;
    [self.gamesMenuButton setTitle:NSLocalizedString(@"Games", @"Games") forState:UIControlStateNormal];
    [self.gamesMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width + self.gamesMenuButton.frame.size.width/2.0, self.view.center.y + (self.view.bounds.size.height/4.0) - self.gamesMenuButton.bounds.size.height/2.0 + 10.0);
    self.gamesMenuButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.gamesMenuButton addTarget:self action:@selector(showGameMenuOptions) forControlEvents:UIControlEventTouchUpInside];
    self.gamesMenuButton.layer.cornerRadius = 10.0;
    self.gamesMenuButton.layer.borderWidth = borderWidth;
    self.gamesMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.optionsMenuButton.frame = buttonFrames;
    [self.optionsMenuButton setTitle:NSLocalizedString(@"Settings", @"Settings") forState:UIControlStateNormal];
    [self.optionsMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width + self.optionsMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y + self.gamesMenuButton.frame.size.height + 10.0);
    self.optionsMenuButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.optionsMenuButton.layer.cornerRadius = 10.0;
    self.optionsMenuButton.layer.borderWidth = borderWidth;
    self.optionsMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.optionsMenuButton addTarget:self action:@selector(showOptionsButtons) forControlEvents:UIControlEventTouchUpInside];
    
    self.logoutButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.optionsMenuButton.frame, 0.0, self.optionsMenuButton.frame.size.height + 10.0)];
    [self.logoutButton addTarget:self action:@selector(facebookLogout) forControlEvents:UIControlEventTouchUpInside];
    [self.logoutButton setTitle:NSLocalizedString(@"Logout", @"Button to close session with facebook") forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.logoutButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    self.logoutButton.layer.cornerRadius = 10.0;
    self.logoutButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.logoutButton.layer.borderWidth = 1.0;
    [self.view addSubview:self.logoutButton];
    
    //Tutorial
    self.optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.optionsButton.frame = gamesButtonsFrames;
    self.optionsButton.center = CGPointMake(self.view.bounds.size.width + self.optionsButton.frame.size.width/2.0, screenBounds.size.height - screenBounds.size.height/4.0 + 40.0);
    [self.optionsButton setTitle:NSLocalizedString(@"Tutorial", @"Button to open the tutorial of the game") forState:UIControlStateNormal];
    [self.optionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.optionsButton.layer.cornerRadius = cornerRadius;
    self.optionsButton.layer.borderWidth = borderWidth;
    self.optionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.optionsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.optionsButton addTarget:self action:@selector(goToTutorialVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //Remove Ads button
    //Display it only if the user has not removed the ads
    self.removeAdsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.removeAdsButton.frame = gamesButtonsFrames;
    //self.removeAdsButton.center = CGPointMake(self.view.frame.size.width + self.removeAdsButton.frame.size.width/2.0, self.optionsButton.center.y + self.optionsButton.frame.size.height + 10.0);
    self.removeAdsButton.center = CGPointMake(self.view.frame.size.width + self.removeAdsButton.frame.size.width/2.0, self.optionsButton.center.y);
    [self.removeAdsButton setTitle:NSLocalizedString(@"Store", @"Button to open the store") forState:UIControlStateNormal];
    [self.removeAdsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.removeAdsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.removeAdsButton.layer.cornerRadius = cornerRadius;
    self.removeAdsButton.layer.borderWidth = borderWidth;
    self.removeAdsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.removeAdsButton addTarget:self action:@selector(showPurchases) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeAdsButton];
    
    ////////////////////////////////////////////////////////////////////////////////////////
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.frame = gamesButtonsFrames;
    //self.colorsButton.center = CGPointMake(self.view.bounds.size.width + self.colorsButton.frame.size.width/2.0, self.view.center.y + self.view.frame.size.height/4.0);
    self.colorsButton.center = CGPointMake(self.view.bounds.size.width + self.colorsButton.frame.size.width/2.0, screenBounds.size.height - screenBounds.size.height/4.0 + 40.0);
    [self.colorsButton setTitle:NSLocalizedString(@"Colors", @"Button to open the colors games") forState:UIControlStateNormal];
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
    self.numbersButton.center = CGPointMake(self.view.frame.size.width + self.numbersButton.frame.size.width/2.0, self.colorsButton.center.y - self.colorsButton.bounds.size.height - 10.0);
    [self.numbersButton setTitle:NSLocalizedString(@"Numbers", @"Button to open the numbers games") forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    self.numbersButton.layer.cornerRadius = 10.0;
    self.numbersButton.layer.borderWidth = borderWidth;
    self.numbersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.numbersButton];
    
    //Fast mode button
    self.fastModeButton = [[UIButton alloc] initWithFrame:gamesButtonsFrames];
    self.fastModeButton.center = CGPointMake(self.view.frame.size.width + self.fastModeButton.frame.size.width/2.0, self.colorsButton.center.y + self.colorsButton.frame.size.height + 10.0);
    [self.fastModeButton setTitle:NSLocalizedString(@"Fast Mode", @"Button to open the fast mode") forState:UIControlStateNormal];
    [self.fastModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.fastModeButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.fastModeButton.layer.cornerRadius = 10.0;
    self.fastModeButton.layer.borderWidth = 1.0;
    self.fastModeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.fastModeButton addTarget:self action:@selector(goToFastModeVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fastModeButton];
    
    //Two Players Button
    if (isPad) {
        self.twoPlayerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.twoPlayerButton.frame = gamesButtonsFrames;
        self.twoPlayerButton.center = CGPointMake(self.view.frame.size.width + self.twoPlayerButton.frame.size.width/2.0, self.colorsButton.center.y + self.colorsButton.frame.size.height + 80.0);
        self.twoPlayerButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
        [self.twoPlayerButton setTitle:NSLocalizedString(@"2-Players Vs", @"Button to open the multiplayer game") forState:UIControlStateNormal];
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
    self.gameCenterButton.center = CGPointMake(self.view.frame.size.width + self.gameCenterButton.frame.size.width/2.0, self.optionsButton.center.y - self.optionsButton.bounds.size.height - 10.0);
    [self.gameCenterButton setTitle:NSLocalizedString(@"Rankings", @"Button to open the rankings") forState:UIControlStateNormal];
    [self.gameCenterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.gameCenterButton.layer.cornerRadius = cornerRadius;
    self.gameCenterButton.layer.borderWidth = borderWidth;
    self.gameCenterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.gameCenterButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.gameCenterButton addTarget:self action:@selector(showRankingsAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.gameCenterButton];
    
    //SOunds button
    self.soundsButton = [[UIButton alloc] initWithFrame:gamesButtonsFrames];
    self.soundsButton.center = CGPointMake(self.view.frame.size.width + self.soundsButton.frame.size.width/2.0, self.gameCenterButton.center.y);
    [self.soundsButton setTitle:NSLocalizedString(@"Sound", @"Button to open the sound configuration") forState:UIControlStateNormal];
    [self.soundsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.soundsButton.layer.cornerRadius = cornerRadius;
    self.soundsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.soundsButton.layer.borderWidth = 1.0;
    self.soundsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    [self.soundsButton addTarget:self action:@selector(showSoundsAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.soundsButton];
    
    //BackButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = backButtonFrame;
    self.backButton.center = CGPointMake(self.backButton.frame.size.width/2.0 + 10.0, self.view.frame.size.height + self.backButton.frame.size.height/2.0);
    [self.backButton setTitle:NSLocalizedString(@"Back", @"Button to go back to the previous options") forState:UIControlStateNormal];
    self.backButton.backgroundColor = [UIColor whiteColor];
    [self.backButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize - 5.0];
    [self.backButton addTarget:self action:@selector(showInitialMenuButtons) forControlEvents:UIControlEventTouchUpInside];
    
    self.backButton.layer.cornerRadius = 7.0;
    //self.backButton.layer.borderWidth = borderWidth;
    //self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.backButton];
}

#pragma mark - Animations 

-(void)startAnimatingViews {
    [self performSelector:@selector(setPosition1) withObject:nil afterDelay:5.0];
}

-(void)setPosition1 {
    self.view1.backgroundColor = [UIColor whiteColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor clearColor];
    self.view7.backgroundColor = [UIColor whiteColor];
    self.view8.backgroundColor = [UIColor clearColor];
    self.view9.backgroundColor = [UIColor clearColor];
    [self performSelector:@selector(setPosition2) withObject:nil afterDelay:4.0];
}

-(void)setPosition2 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor clearColor];
    self.view5.backgroundColor = [UIColor clearColor];
    self.view6.backgroundColor = [UIColor whiteColor];
    self.view7.backgroundColor = [UIColor clearColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    self.view9.backgroundColor = [UIColor whiteColor];
    [self performSelector:@selector(setPosition3) withObject:nil afterDelay:4.0];
}

-(void)setPosition3 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor whiteColor];
    self.view4.backgroundColor = [UIColor clearColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor whiteColor];
    self.view7.backgroundColor = [UIColor clearColor];
    self.view8.backgroundColor = [UIColor clearColor];
    self.view9.backgroundColor = [UIColor whiteColor];
    [self performSelector:@selector(setPosition4) withObject:nil afterDelay:4.0];
}

-(void)setPosition4 {
    self.view1.backgroundColor = [UIColor whiteColor];
    self.view2.backgroundColor = [UIColor whiteColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor clearColor];
    self.view6.backgroundColor = [UIColor clearColor];
    self.view7.backgroundColor = [UIColor clearColor];
    self.view8.backgroundColor = [UIColor clearColor];
    self.view9.backgroundColor = [UIColor clearColor];
    [self performSelector:@selector(setPosition5) withObject:nil afterDelay:4.0];
}

-(void)setPosition5 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor whiteColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor whiteColor];
    self.view7.backgroundColor = [UIColor clearColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    self.view9.backgroundColor = [UIColor clearColor];
    [self performSelector:@selector(setPosition6) withObject:nil afterDelay:4.0];
}

-(void)setPosition6 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor clearColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor clearColor];
    self.view7.backgroundColor = [UIColor whiteColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    self.view9.backgroundColor = [UIColor whiteColor];
    [self performSelector:@selector(setPosition7) withObject:nil afterDelay:4.0];
}

-(void)setPosition7 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor clearColor];
    self.view6.backgroundColor = [UIColor clearColor];
    self.view7.backgroundColor = [UIColor whiteColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    self.view9.backgroundColor = [UIColor clearColor];
    [self performSelector:@selector(setPosition8) withObject:nil afterDelay:4.0];
}

-(void)setPosition8 {
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor whiteColor];
    self.view3.backgroundColor = [UIColor clearColor];
    self.view4.backgroundColor = [UIColor whiteColor];
    self.view5.backgroundColor = [UIColor whiteColor];
    self.view6.backgroundColor = [UIColor whiteColor];
    self.view7.backgroundColor = [UIColor clearColor];
    self.view8.backgroundColor = [UIColor whiteColor];
    self.view9.backgroundColor = [UIColor clearColor];
    [self performSelector:@selector(setPosition1) withObject:nil afterDelay:4.0];
}

-(void)returnToMainButtons {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.facebookButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.facebookButton.center.y);
                         self.enterButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.enterButton.center.y);
                         
                         self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width + self.optionsMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.logoutButton.center = CGPointMake(self.view.bounds.size.width + self.logoutButton.frame.size.width/2.0, self.logoutButton.center.y);
                     } completion:nil];

}
-(void)animateMainButtons {
    [self.playerButtonPressed play];
    
    mainMenuButtonsDisplayed = YES;
    gamesButtonsDisplayed = NO;
    optionsButtonsDisplayed = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.enterButton.center = CGPointMake(-self.enterButton.frame.size.width/2.0, self.enterButton.center.y);
                         self.facebookButton.center = CGPointMake(-self.facebookButton.frame.size.width/2.0, self.facebookButton.center.y);
                         self.gamesMenuButton.center = CGPointMake(self.view.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(self.view.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.logoutButton.center = CGPointMake(self.view.frame.size.width/2.0, self.logoutButton.center.y);
                         
                         if (!userIsLoggedIn) {
                             self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height - self.backButton.frame.size.height/2.0 - 17.0);
                         }
                     } completion:nil];
}

-(void)showOptionsButtons {
    [self playButtonSound];
    gamesButtonsDisplayed = NO;
    optionsButtonsDisplayed = YES;
    mainMenuButtonsDisplayed = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.gamesMenuButton.center = CGPointMake(-self.gamesMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(-self.optionsMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.logoutButton.center = CGPointMake(-self.logoutButton.frame.size.width + self.logoutButton.frame.size.width/2.0, self.logoutButton.center.y);
                        
                         self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height - self.backButton.frame.size.height/2.0 - 17.0);
                         
                         self.optionsButton.center = CGPointMake(self.view.bounds.size.width/2.0 - self.optionsButton.frame.size.width/2.0 - 5.0, self.optionsButton.center.y);
                         self.gameCenterButton.center = CGPointMake(self.view.bounds.size.width/2.0 - self.gameCenterButton.frame.size.width/2.0 - 5.0, self.gameCenterButton.center.y);
                         self.removeAdsButton.center = CGPointMake(self.optionsButton.frame.origin.x + self.optionsButton.frame.size.width + 10.0 + self.removeAdsButton.frame.size.width/2.0, self.removeAdsButton.center.y);
                         self.soundsButton.center = CGPointMake(self.gameCenterButton.frame.origin.x + self.gameCenterButton.frame.size.width + 10.0 + self.soundsButton.frame.size.width/2.0, self.soundsButton.center.y);
                     } completion:^(BOOL finished){}];
}

-(void)showInitialMenuButtons {
    [self playBackSound];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         if (gamesButtonsDisplayed) {
                             //Hidde Game Buttons
                             self.numbersButton.center = CGPointMake(self.view.bounds.size.width + self.numbersButton.frame.size.width/2.0, self.numbersButton.center.y);
                             self.colorsButton.center = CGPointMake(self.view.bounds.size.width + self.colorsButton.frame.size.width/2.0, self.colorsButton.center.y);
                             self.fastModeButton.center = CGPointMake(self.view.bounds.size.width + self.fastModeButton.frame.size.width/2.0, self.fastModeButton.center.y);
                             self.twoPlayerButton.center = CGPointMake(self.view.bounds.size.width + self.twoPlayerButton.frame.size.width/2.0, self.twoPlayerButton.center.y);
                             
                             self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.gamesMenuButton.center.y);
                             self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.optionsMenuButton.center.y);
                             self.logoutButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.logoutButton.center.y);
                             
                             if (userIsLoggedIn) {
                                 //Hidde back button
                                 self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height + self.backButton.frame.size.height/2.0);
                             }
                             
                             gamesButtonsDisplayed = NO;
                             mainMenuButtonsDisplayed = YES;
                             optionsButtonsDisplayed = NO;
                         
                         } else if (optionsButtonsDisplayed) {
                             //Hidde optionsbuttons
                             self.removeAdsButton.center = CGPointMake(self.view.bounds.size.width + self.removeAdsButton.frame.size.width/2.0, self.removeAdsButton.center.y);
                             self.gameCenterButton.center = CGPointMake(self.view.bounds.size.width + self.gameCenterButton.frame.size.width/2.0, self.gameCenterButton.center.y);
                             self.optionsButton.center = CGPointMake(self.view.bounds.size.width + self.optionsButton.frame.size.width/2.0, self.optionsButton.center.y);
                             self.soundsButton.center = CGPointMake(self.view.bounds.size.width + self.soundsButton.frame.size.width/2.0, self.soundsButton.center.y);
                             
                             self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.gamesMenuButton.center.y);
                             self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.optionsMenuButton.center.y);
                             self.logoutButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.logoutButton.center.y);
                             
                             if (userIsLoggedIn) {
                                 //Hidde back button
                                 self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height + self.backButton.frame.size.height/2.0);
                             }
                             
                             optionsButtonsDisplayed = NO;
                             gamesButtonsDisplayed = NO;
                             mainMenuButtonsDisplayed = YES;
                             
                         } else if (mainMenuButtonsDisplayed) {
                             self.facebookButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.facebookButton.center.y);
                             self.enterButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.enterButton.center.y);
                             self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height + self.backButton.frame.size.height/2.0);
                             self.gamesMenuButton.center = CGPointMake(self.view.bounds.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                             self.optionsMenuButton.center = CGPointMake(self.view.bounds.size.width + self.optionsMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                             
                             optionsButtonsDisplayed = NO;
                             gamesButtonsDisplayed = NO;
                             mainMenuButtonsDisplayed = YES;
                         }
                     } completion:^(BOOL success){}];
}

-(void)showGameMenuOptions {
    [self playButtonSound];
    gamesButtonsDisplayed = YES;
    optionsButtonsDisplayed = NO;
    mainMenuButtonsDisplayed = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.gamesMenuButton.center = CGPointMake(-self.gamesMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.gamesMenuButton.center.y);
                         self.optionsMenuButton.center = CGPointMake(-self.optionsMenuButton.frame.size.width + self.gamesMenuButton.frame.size.width/2.0, self.optionsMenuButton.center.y);
                         self.logoutButton.center = CGPointMake(-self.logoutButton.frame.size.width + self.logoutButton.frame.size.width/2.0, self.logoutButton.center.y);
                         
                         self.backButton.center = CGPointMake(self.backButton.center.x, self.view.bounds.size.height - self.backButton.frame.size.height/2.0 - 17.0);
                         self.numbersButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.numbersButton.center.y);
                         self.colorsButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.colorsButton.center.y);
                         self.fastModeButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.fastModeButton.center.y);
                         self.twoPlayerButton.center = CGPointMake(self.view.bounds.size.width/2.0, self.twoPlayerButton.center.y);
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions

-(void)facebookLogout {
    [PFUser logOut];
    userIsLoggedIn = NO;
    self.logoutButton.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(showLogoutAlert) withObject:nil afterDelay:0.5];
}

-(void)showErrorAlert {
    OneButtonAlert *errorAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    errorAlert.alertText = @"Oops! There was a network error. Please check that you're connected to the internet.";
    errorAlert.button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    errorAlert.buttonTitle = @"Ok";
    errorAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    errorAlert.messageLabel.center = CGPointMake(errorAlert.messageLabel.center.x, 70.0);
    [errorAlert showInView:self.view];
}

-(void)showSoundsAlert {
    [self playButtonSound];
    SoundsView *soundsView = [[SoundsView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    [soundsView showInView:self.view];
}

-(void)showLogoutAlert {
    [self returnToMainButtons];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    OneButtonAlert *logoutAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 110.0, screenBounds.size.height/2.0 - 65.0, 220.0, 130.0)];
    logoutAlert.alertText = @"Logout Succesfull!";
    logoutAlert.buttonTitle = @"Ok";
    [logoutAlert showInView:self.view];
}

-(void)goToFastModeVC {
    [self playButtonSound];
    [self stopMusic];
    
    FastGameModeViewController *fastModeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FastGameMode"];
    fastModeVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:fastModeVC animated:YES completion:nil];
}

-(void)goToMultiplayerVC {
    [self stopMusic];
    [self playButtonSound];
    MultiplayerGameViewController *multiplayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGame"];
    multiplayerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:multiplayerVC animated:YES completion:nil];
}

-(void)showPurchases {
    [self playButtonSound];
    NSMutableDictionary *purchasesDic = [[NSMutableDictionary alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            for (IAPProduct *product in products) {
                NSLog(@"*******************************************************************");
                NSLog(@"Nombre del producto: %@", product.skProduct.localizedTitle);
                NSLog(@"Precio del producto: %@", product.skProduct.price);
                if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.twentylives"]) {
                    [purchasesDic setObject:product forKey:@"twentyLives"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.fivelives"]) {
                    [purchasesDic setObject:product forKey:@"fiveLives"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.sixtylives"]) {
                    [purchasesDic setObject:product forKey:@"sixtyLives"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.threehundredtouches"]) {
                    [purchasesDic setObject:product forKey:@"threeHundredTouches"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.sevenhundredtouches"]) {
                    [purchasesDic setObject:product forKey:@"sevenHundredTouches"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.twothousandtouches"]) {
                    [purchasesDic setObject:product forKey:@"twoThousandTouches"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.noads"]) {
                    [purchasesDic setObject:product forKey:@"noAds"];
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
                    [purchasesDic setObject:product forKey:@"infiniteMode"];
                }
            }
            NSLog(@"Purchases dic: %@", purchasesDic);
            [self showStoreViewWithProductsDic:purchasesDic];
        } else {
            NSLog(@"NO ME PUDE CONECTAR PARA VER LOS PRODUCTOS");
            [self showErrorAlert];
        }
    }];
}

-(void)showStoreViewWithProductsDic:(NSMutableDictionary *)purchasesDic {
    StoreView *storeView;
    if (isPad) {
        storeView = [[StoreView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 280.0/2.0, screenBounds.size.height/2.0 - 528.0/2.0, 280.0, 528.0)];
        
    } else {
        storeView = [[StoreView alloc]
                        initWithFrame:CGRectMake(20.0, 20.0, screenBounds.size.width - 40.0, screenBounds.size.height - 40.0)];
    }
    storeView.purchasesDic = purchasesDic;
    [storeView showInView:self.view];
}

/*-(void)buyNoAds {
    [self playButtonSound];
    
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
}*/

-(void)showRankingsAlert {
    [self playButtonSound];
    TwoButtonsAlert *twoButtonsAlert = [[TwoButtonsAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    twoButtonsAlert.alertText = @"Which rankings would you like to see?";
    twoButtonsAlert.leftButtonTitle = @"Facebook";
    twoButtonsAlert.rightButtonTitle = @"GameCenter";
    twoButtonsAlert.delegate = self;
    [twoButtonsAlert showInView:self.view];
}

-(void)showSuccessfullLoginAlert {
    OneButtonAlert *loginSuccessAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 120.0, screenBounds.size.height/2.0 - 60.0, 240.0, 120.0)];
    loginSuccessAlert.alertText = @"Succesfull Login!";
    loginSuccessAlert.buttonTitle = @"Ok";
    [loginSuccessAlert showInView:self.view];
}

-(void)showGameCenter {    
    [self playButtonSound];
    
    GKGameCenterViewController *gameViewController = [[GKGameCenterViewController alloc] init];
    if (gameViewController != nil) {
        NSLog(@"Entré a mostrar el controlador de game center");
        gameViewController.gameCenterDelegate = self;
        gameViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        [self presentViewController:gameViewController animated:YES completion:nil];
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goToColorsChaptersVC {
    if (![self getMusicSelectionInUserDefaults]) {
        [self stopMusic];
    }
    [self playButtonSound];
    
    [Flurry logEvent:@"OpenColorsChapters"];
    ColorsChaptersViewController *colorsChaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorsChapters"];
    colorsChaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorsChaptersVC animated:YES completion:nil];
}

-(void)goToChaptersVC {
    if (![self getMusicSelectionInUserDefaults]) {
        [self stopMusic];
    }
    [self playButtonSound];
    
    [Flurry logEvent:@"OpenNumbersChapters"];
    ChaptersViewController *chaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapters"];
    chaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:chaptersVC animated:YES completion:nil];
}

-(void)goToTutorialVC {
    /*NSString *accessToken = [PFFacebookUtils session].accessTokenData.accessToken;
    NSDictionary *params = @{@"score" : @"500", @"access_token" : accessToken};
    
    [FBRequestConnection startWithGraphPath:@"me/scores"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         // Handle results
         if (!error) {
             NSLog(@"%@", result);
         } else {
             NSLog(@"error: %@ %@", error, [error localizedDescription]);
         }
     }];*/
    
    [self playButtonSound];
    
    [Flurry logEvent:@"OpenTutorial"];
    TutorialContainerViewController *tutContainerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialContainer"];
    [self presentViewController:tutContainerVC animated:YES completion:nil];
}

#pragma mark - Facebook Stuff

-(void)showNoFacebookLoginAlert {
    OneButtonAlert *noFacebookAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    noFacebookAlert.alertText = @"You must log in with Facebook to access the rankings. You can login from the main options.";
    noFacebookAlert.buttonTitle = @"Ok";
    noFacebookAlert.messageLabel.frame = CGRectMake(20.0, 10.0, noFacebookAlert.bounds.size.width - 40.0, 120.0);
    noFacebookAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [noFacebookAlert showInView:self.view];
}

-(void)startLoginProcess {
    [self.playerButtonPressed play];
    
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
            userIsLoggedIn = YES;
            self.logoutButton.hidden = NO;
            [self showSuccessfullLoginAlert];
            [self animateMainButtons];
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
        }
    }];
}

-(void)showFacebookRankings {
    //746952778700195
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *accessToken = [PFFacebookUtils session].accessTokenData.accessToken;
    NSDictionary *params = @{@"access_token" : accessToken};
    [FBRequestConnection startWithGraphPath:@"746952778700195/scores"
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                              if (!error) {
                                  NSLog(@"Rspuesta correcta: %@", result);
                                  [self parseRankingsFromResult:(NSDictionary *)result];
                              } else {
                                  NSLog(@"Error: %@ %@", error, [error localizedDescription]);
                              }
                          }];
}

-(void)parseRankingsFromResult:(NSDictionary *)rankingsDic {
    NSMutableArray *parsedResults = [[NSMutableArray alloc] init];
    NSArray *rankingsArray = rankingsDic[@"data"];
    for (int i = 0; i < [rankingsArray count]; i++) {
        NSDictionary *resultDic = rankingsArray[i];
        NSDictionary *parsedDic = @{@"name" : resultDic[@"user"][@"name"],
                                    @"userID" : resultDic[@"user"][@"id"],
                                    @"score" : resultDic[@"score"]};
        [parsedResults addObject:parsedDic];
    }
    [self showFacebookRankingsListWithResults:parsedResults];
}

-(void)showFacebookRankingsListWithResults:(NSArray *)resultsArray {
    FacebookRankingList *fbRankingsList = [[FacebookRankingList alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, 20.0, 280., screenBounds.size.height - 40.0)];
    fbRankingsList.resultsArray = resultsArray;
    [fbRankingsList showInView:self.view];
}

#pragma mark - Sounds

-(void)playBackSound {
    [self.playerBackSound play];
}

-(void)playButtonSound {
    [self.playerButtonPressed stop];
    self.playerButtonPressed.currentTime = 0;
    [self.playerButtonPressed play];
}

-(void)stopMusic
{
    if (self.player.volume > 0.0) {
        self.player.volume = self.player.volume - 0.02;
        [self performSelector:@selector(stopMusic) withObject:nil afterDelay:0.02];
    } else {
        // Stop and get the sound ready for playing again
        [self.player stop];
        [self.player prepareToPlay];
        self.player.volume = 0.0;
    }
}

-(void)fadeInMusic {
    if (self.player.volume < 1.0) {
        self.player.volume += 0.02;
        [self performSelector:@selector(fadeInMusic) withObject:nil afterDelay:0.02];
    }
}

#pragma mark - NSUSerDefaults 

-(BOOL)getMusicSelectionInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"musicActive"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"musicActive"] boolValue];
    } else {
        return YES;
    }
}

#pragma mark - GameCenterDelegate

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    NSLog(@"Me saldréeee de game center oiiiiiiiiissssssssssss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*#pragma mark - Notification Handlers

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
    
    //Hidde the removed ads button
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.removeAdsButton.alpha = 0.0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             self.removeAdsButton.hidden = YES;
                         }
                     }];
}*/

-(void)playMusicNotificationReceived:(NSNotification *)notification {
    [self.player play];
    [self fadeInMusic];
}

#pragma mark - TwoButtonsAlertDelegate

-(void)leftButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //El usuario está logueado con Facebook
        [self showFacebookRankings];
    } else {
        //Mostrar login con Facebook
        //[self startLoginProcess];
        [self showNoFacebookLoginAlert];
    }
}

-(void)rightButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert {
    [self showGameCenter];
}

-(void)twoButtonsAlertDidDisappear:(TwoButtonsAlert *)twoButtonsAlert {
    
}

@end
