//
//  GameViewController.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameViewController.h"
#import "AppInfo.h"
#import "FileSaver.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "FlurryAdDelegate.h"
#import "GameKitHelper.h"
#import <Social/Social.h>
#import "GameWonAlert.h"
#import "ChallengeFriendsViewController.h"
#import "Score+AddOns.h"
#import "AllGamesFinishedView.h"
#import "AudioPlayer.h"
#import "NoTouchesAlertView.h"
#import "BuyTouchesView.h"
#import "CPIAPHelper.h"
#import "MBProgressHUD.h"
#import "IAPProduct.h"
#import "TouchesObject.h"
@import AVFoundation;

@interface GameViewController () <UIAlertViewDelegate, GameWonAlertDelegate, AllGamesFinishedViewDelegate, NoTouchesAlertDelegate, BuyTouchesViewDelegate>
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray; //Of UIButton
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) UILabel *numberOfTapsLabel;
@property (strong, nonatomic) UILabel *maxTapsLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *resetButton;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) UILabel *maxScoreLabel;
@property (strong, nonatomic) UILabel *touchesAvailableLabel;
@property (strong, nonatomic) NSNumberFormatter *purchasesPriceFormatter;

//CoreData
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSURL *databaseDocumentURL;

@property (strong, nonatomic) AVAudioPlayer *playerGameWon;
@property (strong, nonatomic) AVAudioPlayer *playerButtonPressed;
@property (strong, nonatomic) AVAudioPlayer *playerGameRestarted;
@property (strong, nonatomic) AVAudioPlayer *playerBackButton;
@end

#define FONT_NAME @"HelveticaNeue-Light"
#define DOCUMENT_NAME @"MyDocument";

@implementation GameViewController {
    CGRect screenBounds;
    NSUInteger numberOfTaps;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    NSUInteger numberOfChapters;
    NSUInteger pointsForBestScore;
    NSUInteger bestTime;
    NSUInteger pointsWon;
    NSUInteger bestTapCount;
    NSUInteger bestTapsScore;
    NSUInteger bestTimeScore;
    float maxScore;
    float maxTime;
    float timeElapsed;
    BOOL managedDocumentIsReady;
    BOOL isPad;
    BOOL userBoughtInfiniteMode;
}

#pragma mark - Lazy Instantiation

-(NSNumberFormatter *)purchasesPriceFormatter {
    if (!_purchasesPriceFormatter) {
        _purchasesPriceFormatter = [[NSNumberFormatter alloc] init];
        _purchasesPriceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        _purchasesPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    return _purchasesPriceFormatter;
}

-(NSURL *)databaseDocumentURL {
    if (!_databaseDocumentURL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = DOCUMENT_NAME;
        _databaseDocumentURL = [documentsDirectory URLByAppendingPathComponent:documentName];
    }
    return _databaseDocumentURL;
}

-(UIManagedDocument *)databaseDocument {
    if (!_databaseDocument) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = DOCUMENT_NAME;
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
        _databaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _databaseDocument;
}

-(NSMutableArray *)columnsButtonsArray {
    if (!_columnsButtonsArray) {
        _columnsButtonsArray = [[NSMutableArray alloc] init];
    }
    return _columnsButtonsArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    if ([self userBoughtInfiniteMode]) userBoughtInfiniteMode = YES;
    else userBoughtInfiniteMode = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
    } else {
        isPad = NO;
    }
    
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][self.selectedChapter];
    screenBounds = [UIScreen mainScreen].bounds;
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    maxScore = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxScore"] floatValue];
    numberOfChapters = [chaptersDataArray count];
    [TouchesObject sharedInstance].totalTouches = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Touches"] intValue];
    NSLog(@"Toques disponibleeeesss: %lu", (unsigned long)[TouchesObject sharedInstance].totalTouches);
    
    [self setupUI];
    [self initGame];
    [self openCoreDataDocument];
    [self configureSounds];
    
    if (!userBoughtInfiniteMode) {
        if ([TouchesObject sharedInstance].totalTouches == 0) [self disableButtons];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Register for the notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newTouchesNotificationReceived:)
                                                 name:@"NewTouchesAvailable"
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!userBoughtInfiniteMode) {
        //Add adds from Flurry
        [FlurryAds setAdDelegate:self];
        if ([FlurryAds adReadyForSpace:@"FullScreenAd"]) {
            NSLog(@"Mostraré el ad");
            //[FlurryAds displayAdForSpace:@"FullScreenAd" onView:self.view];
        } else {
            NSLog(@"No mostraré el ad sino que lo cargaré");
            [FlurryAds fetchAdForSpace:@"FullScreenAd" frame:self.view.frame size:FULLSCREEN];
        }
    }
    
    //Check number of touches available
    if ([TouchesObject sharedInstance].totalTouches == 0 && !userBoughtInfiniteMode) {
        NoTouchesAlertView *noTouchesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 100.0, 280.0, 200.0)];
        noTouchesAlert.delegate = self;
        [noTouchesAlert showInView:self.view];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Stop the timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    //Remove ads from Flurry
    [FlurryAds removeAdFromSpace:@"FullScreenAd"];
    [FlurryAds setAdDelegate:nil];
}

-(void)configureSounds {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"wav"];
    NSURL *url = [NSURL URLWithString:soundFilePath];
    self.playerGameWon = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.playerGameWon prepareToPlay];
    
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"restartnuevo" ofType:@"wav"];
    url = nil;
    url = [NSURL URLWithString:soundFilePath];
    self.playerGameRestarted = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.playerGameRestarted.volume = 1.0;
    [self.playerGameRestarted prepareToPlay];
    
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"press" ofType:@"wav"];
    url = nil;
    url = [NSURL URLWithString:soundFilePath];
    self.playerButtonPressed = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.playerButtonPressed.volume = 0.3;
    [self.playerButtonPressed prepareToPlay];
    
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"wav"];
    url = nil;
    url = [NSURL URLWithString:soundFilePath];
    self.playerBackButton = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.playerBackButton prepareToPlay];
}

-(void)setupUI {
    //Setup MainTitle
    NSUInteger labelsFontSize;
    if (isPad) {
        self.numberOfTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height - 140.0, 300.0, 30.0)];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, screenBounds.size.width, 70.0)];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:70.0];
        labelsFontSize = 25.0;
    } else {
        //self.numberOfTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height - (screenBounds.size.height/4.20), 300.0, 30.0)];
        
        if (screenBounds.size.height > 500) {
            //4 Inch
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/8.11, screenBounds.size.width, 40.0)];
            self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
        } else {
            //Small iPhone
            NSLog(@"***************** ESTOY EN IPHONE PEQUEÑOOOO *********************");
            if (matrixSize >= 5) {
                NSLog(@"El tamaño de la matriz es muy grandeeeeeeeeeee");
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            } else {
                NSLog(@"EL tamaño de la matriz es menor que cincooooo");
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/8.11, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            }
        }
        labelsFontSize = 18.0;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %u - Game %u", self.selectedChapter + 1, self.selectedGame + 1];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    //Back Button
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(10.0, screenBounds.size.height - 60.0, 60.0, 40.0);
    self.backButton.layer.cornerRadius = 10.0;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    //Reset Button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(screenBounds.size.width - 70, screenBounds.size.height - 60.0, 60.0, 40.0);
    self.resetButton.layer.cornerRadius = 10.0;
    self.resetButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.resetButton.layer.borderWidth = 1.0;
    [self.resetButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.resetButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    //Buttons container view
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    self.buttonsContainerView = [[UIView alloc] init];
    [self.view addSubview:self.buttonsContainerView];
    
    //Max Score Label
    //self.maxScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height - 60.0, 300.0, 40.0)];
    self.maxScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 80.0, screenBounds.size.height - 60.0, 160.0, 40.0)];
    self.maxScoreLabel.textColor = [UIColor whiteColor];
    self.maxScoreLabel.layer.cornerRadius = 10.0;
    self.maxScoreLabel.layer.borderWidth = 1.0;
    self.maxScoreLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.maxScoreLabel.textAlignment = NSTextAlignmentCenter;
    self.maxScoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [self.view addSubview:self.maxScoreLabel];
    
    //Touches available label
    self.touchesAvailableLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.maxScoreLabel.frame, 0.0, -(self.maxScoreLabel.frame.size.height + 10.0))];
    if (userBoughtInfiniteMode)
        self.touchesAvailableLabel.text = @"Infinite Touches";
    else self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %lu", (unsigned long)[TouchesObject sharedInstance].totalTouches];
    self.touchesAvailableLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    self.touchesAvailableLabel.textColor = [UIColor whiteColor];
    self.touchesAvailableLabel.layer.cornerRadius = 10.0;
    self.touchesAvailableLabel.layer.borderWidth = 1.0;
    self.touchesAvailableLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.touchesAvailableLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.touchesAvailableLabel];
    
    //Buy button
    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectOffset(self.backButton.frame, 0.0, -(self.backButton.frame.size.height + 10.0))];
    [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    buyButton.layer.cornerRadius = 10.0;
    buyButton.layer.borderColor = [UIColor whiteColor].CGColor;
    buyButton.layer.borderWidth = 1.0;
    [buyButton addTarget:self action:@selector(getPricesForPurchases) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buyButton];
}

#pragma mark - Custom Methods

-(void)resetGame {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    /*for (int i = 0; i < [self.buttonsContainerView.subviews count]; i++) {
        UIView *view = self.buttonsContainerView.subviews[i];
        view = nil;
    }*/
    [self.columnsButtonsArray removeAllObjects];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    if (self.selectedGame >= [chaptersDataArray[self.selectedChapter] count]) {
        self.selectedChapter += 1;
        self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][self.selectedChapter];
        self.selectedGame = 0;
    }
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    //maxScore = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxScore"] floatValue];
    maxTime = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxTime"] floatValue];
    bestTapCount = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"puntos"] count];
    bestTapsScore = bestTapCount * 100;
    bestTimeScore = bestTapsScore/2;
    maxScore = bestTapsScore + bestTimeScore;
    NSLog(@"******* %lu ----- %lu *********", (unsigned long)bestTapsScore, (unsigned long)bestTimeScore);
    timeElapsed = 0;
    self.maxScoreLabel.text = [NSString stringWithFormat:@"Best Score: %lu/%d", (unsigned long)[self getScoredStoredInCoreData], (int)maxScore];
    
    bestTime = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"bestTime"] intValue];
    float pointsAtBestTime = [self pointsWonForTime:(float)bestTime];
    pointsForBestScore = bestTimeScore - pointsAtBestTime;

    
    //self.buttonsContainerView.frame = CGRectMake(0.0, 100.0, matrixSize*53.33333, matrixSize*53.33333);
    if (matrixSize < 5) {
        if (isPad) {
            self.buttonsContainerView.frame = CGRectMake(130.0, 110.0, screenBounds.size.width - 260.0, screenBounds.size.width - 260.0);
            self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
        }
        else {
            self.buttonsContainerView.frame = CGRectMake(35.0, screenBounds.size.height/5.16, screenBounds.size.width - 70.0, screenBounds.size.width - 70.0);
            self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
        }
        
    } else {
        if (isPad) {
            self.buttonsContainerView.frame = CGRectMake(50.0, 110.0, screenBounds.size.width - 100.0, screenBounds.size.width - 100.0);
            self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
        }
        else if (screenBounds.size.height > 500) {
            NSLog(@"************ Estoy en 4 inch");
            //4 inch
            self.buttonsContainerView.frame = CGRectMake(10.0, 110.0, screenBounds.size.width - 20.0, screenBounds.size.width - 20.0);
            self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);

        } else {
            //Small screen iPhone
            NSLog(@"*************** Estoy en iPhone pequeño");
            self.buttonsContainerView.frame = CGRectMake(10.0, 70.0, screenBounds.size.width - 20.0, screenBounds.size.width - 20.0);
        }
    }
    
    [self createSquareMatrixOf:matrixSize];
    
    numberOfTaps = 0;
    self.numberOfTapsLabel.text = @"Número de Taps: 0";
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            [self.columnsButtonsArray[i][j] setTitle:@"0" forState:UIControlStateNormal];
            CGPoint originalButtonCenter = [self.columnsButtonsArray[i][j] center];
            CGPoint randomCenter = CGPointMake(arc4random()%1000, arc4random()%500);
            [self.columnsButtonsArray[i][j] setCenter:randomCenter];
            [UIView animateWithDuration:0.8
                                  delay:0.0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [self.columnsButtonsArray[i][j] setCenter:originalButtonCenter];
                             } completion:^(BOOL finished){}];
           
        }
    }
    
    //Check if the user dont have more touches
    if ([TouchesObject sharedInstance].totalTouches == 0 && !userBoughtInfiniteMode) [self disableButtons];
}

-(void)initGame {
    [self resetGame];
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %u - Game %u", self.selectedChapter + 1, self.selectedGame + 1];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    self.pointsArray = chaptersDataArray[self.selectedChapter][self.selectedGame][@"puntos"];
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        [self addOneToButtonAtRow:row column:column];
        //NSUInteger buttonTag = [self tagForButtonAtRow:row column:column];
        //[self addOneToButtonWithTag:buttonTag];
    }
    numberOfTaps = 0;
    
    //Start the game timer
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

-(void)addOneToButtonAtRow:(NSInteger)row column:(NSInteger)column {
    NSString *buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row]];
    [self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row + 1]];
        [self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row - 1]];
        [self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column - 1][row]];
        [self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column + 1][row]];
        [self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

-(NSString *)getNewValueForButton:(UIButton *)button {
    NSLog(@"titulo actual: %@", button.currentTitle);
    NSString *newTitle = [NSString stringWithFormat:@"%i", [button.currentTitle intValue] + 1];
    return newTitle;
}

-(NSString *)substractOneForButton:(UIButton *)button {
    NSInteger newbuttonValue = [button.currentTitle intValue] - 1;
    if (newbuttonValue < 0) {
        newbuttonValue = maxNumber;
    }
    return [NSString stringWithFormat:@"%li", (long)newbuttonValue];
}

-(void)createSquareMatrixOf:(NSUInteger)size {
    NSUInteger buttonDistance;
    NSUInteger cornerRadius;
    if (isPad) {
        buttonDistance = 20.0;
        cornerRadius = 10.0;
    }
    else {
        buttonDistance = 10.0;
        cornerRadius = 10.0;
    }
    
    NSUInteger buttonSize = (self.buttonsContainerView.frame.size.width - ((matrixSize + 1)*buttonDistance)) / matrixSize;
    NSLog(@"Tamaño del boton: %lu", (unsigned long)buttonSize);
    
    int h = 1000;
    for (int i = 0; i < size; i++) {
        NSMutableArray *filaButtonsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < size; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitleColor:[[AppInfo sharedInstance] appColorsArray][self.selectedChapter] forState:UIControlStateNormal];
            button.layer.cornerRadius = cornerRadius;
            button.frame = CGRectMake(buttonDistance + (i*buttonSize + buttonDistance*i), buttonDistance + (j*buttonSize + buttonDistance*j), buttonSize, buttonSize);
            button.backgroundColor = [UIColor whiteColor];
            [button setTitle:@"0" forState:UIControlStateNormal];
            if (matrixSize < 5) {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
            } else {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:70.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            }
            [button addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = h;
            [self.buttonsContainerView addSubview:button];
            [filaButtonsArray addObject:button];
            h+=1;
        }
        [self.columnsButtonsArray addObject:filaButtonsArray];
    }
}

#pragma mark - Actions 

-(void)restartGame {
    self.resetButton.userInteractionEnabled = NO;
    [self performSelector:@selector(enableResetButton) withObject:nil afterDelay:1.0];
    [self playRestartSound];
    [self initGame];
}

-(void)enableResetButton {
    self.resetButton.userInteractionEnabled = YES;
}

-(void)numberButtonPressed:(UIButton *)numberButton {
    [self playButtonPressedSound];
    
    NSLog(@"Oprimí el boton con tag %ld", (long)numberButton.tag);
    NSUInteger index = numberButton.tag - 1000;
    NSInteger column = index / matrixSize;
    NSInteger row = index % matrixSize;
    
    NSString *buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row]];
    [self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row + 1]];
        [self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row - 1]];
        [self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column - 1][row]];
        [self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column + 1][row]];
        [self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    numberOfTaps++;
    if (!userBoughtInfiniteMode) {
        [TouchesObject sharedInstance].totalTouches--;
        self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %lu", (unsigned long)[TouchesObject sharedInstance].totalTouches];
        
        if ([TouchesObject sharedInstance].totalTouches == 0) {
            //Show alert
            NoTouchesAlertView *noTouchesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 100.0, 280.0, 200.0)];
            noTouchesAlert.delegate = self;
            [noTouchesAlert showInView:self.view];
            
            [self disableButtons];
            [self saveCurrentDateInUserDefaults];
        }
    }
    [self checkIfUserWon];
}

-(void)enableButtons {
    for (int i = 0; i < [self.buttonsContainerView.subviews count]; i++) {
        UIButton *numberButton = self.buttonsContainerView.subviews[i];
        numberButton.userInteractionEnabled = YES;
        numberButton.alpha = 1.0;
    }
}

-(void)disableButtons {
    for (int i = 0; i < [self.buttonsContainerView.subviews count]; i++) {
        UIButton *numberButton = self.buttonsContainerView.subviews[i];
        numberButton.userInteractionEnabled = NO;
        numberButton.alpha = 0.5;
    }
}

-(void)updateUI {
    self.maxScoreLabel.text = [NSString stringWithFormat:@"Best Score: %lu/%d", (unsigned long)[self getScoredStoredInCoreData], (int)maxScore];
}

-(void)checkIfUserWon {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            NSString *buttonValue = [self.columnsButtonsArray[i][j] currentTitle];
            if (![buttonValue isEqualToString:@"0"]) {
                return;
            }
        }
    }
    
    //User Won
    //Get Points Won
    //Taps points
    NSUInteger tapPointsWon = [self pointsWonForTaps:numberOfTaps];
    NSLog(@"Puntos ganadoooooooossssss: %lu", (unsigned long)tapPointsWon);
    
    //Bonus time points
    NSUInteger bonusPointsWon = [self pointsWonForTime:timeElapsed] + pointsForBestScore;
    if (bonusPointsWon > bestTimeScore) bonusPointsWon = bestTimeScore;
    
    pointsWon = tapPointsWon + bonusPointsWon;
    NSLog(@"################################################################################");
    NSLog(@"Puntos ganados por taps: %lu", (unsigned long)tapPointsWon);
    NSLog(@"Puntos ganados por tiempo: %lu", (unsigned long)bonusPointsWon);
    NSLog(@"Puntos totales ganados: %lu", (unsigned long)pointsWon);
    /*pointsWon = [self pointsWonForTime:timeElapsed] + pointsForBestScore;
    if (pointsWon > maxScore) pointsWon = maxScore;
    NSLog(@"Point Woooon %lu", (unsigned long)pointsWon);*/

    //Cancel timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];
}

-(void)userWon {
    BOOL scoreWasImproved = [self checkIfScoredWasImprovedInCoreDataWithNewScore:pointsWon];
    
    //Send data to Flurry
    [Flurry logEvent:@"NumbersGameWon" withParameters:@{@"Chapter" : @(self.selectedChapter), @"Game" : @(self.selectedGame)}];
    [self savePointsInCoreData];
    if (scoreWasImproved) {
        NSLog(@"EL score se mejoróoooo *************************");
        NSUInteger totalScore = [self getTotalScoreInCoreData];
        NSLog(@"Score Totaaaaaaaalllllll: %lu", (unsigned long)totalScore);
        [[GameKitHelper sharedGameKitHelper] submitScore:totalScore category:@"Points_Leaderboard"];
        
        //Post a notification to update the chapters VC with the new score
        //if (isPad)
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"ScoreUpdatedNotification" object:nil];
    
    } else {
        NSLog(@"El score no se mejoróooooo *************************");
    }
    
    //Unlock the next game saving the game number with FileSaver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableArray *chaptersArray = [fileSaver getDictionary:@"NumberChaptersDic"][@"NumberChaptersArray"];
    NSLog(@"Agregando el número %u a filesaver porque gané", self.selectedGame + 2);
    
    //Check if the user won the last game of the chapter
    if (self.selectedGame == 8 && self.selectedChapter != numberOfChapters - 1) {
        //This is the last game of the chapter
        NSLog(@"Estamos en el último juego del capítulo");
        NSMutableArray *chapterGamesFinishedArray = [NSMutableArray arrayWithArray:chaptersArray[self.selectedChapter + 1]];
        
        //Check if the first game of the next chapter has been already unlocked
        //by the user
        if (![chapterGamesFinishedArray containsObject:@1]) {
            //The user hadn't unlocked this game, so unlock it in file saver
            NSLog(@"Guardaré el primer juego del próximo capítulo en file saver");
            
            [chapterGamesFinishedArray addObject:@(1)];
            [chaptersArray replaceObjectAtIndex:self.selectedChapter + 1 withObject:chapterGamesFinishedArray];
            [fileSaver setDictionary:@{@"NumberChaptersArray" : chaptersArray} withName:@"NumberChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GameWonNotification" object:nil];
        
        } else {
            NSLog(@"No guardé la info porque el usuario ya había ganado este juego");
        }
        
    } else {
        //The user is playing a game different than the last one
        NSMutableArray *chapterGamesFinishedArray = chaptersArray[self.selectedChapter];
        
        //Check if this game is already saved in FileSaver (The user has already won this game)
        if (![chapterGamesFinishedArray containsObject:@(self.selectedGame + 2)]) {
            NSLog(@"Guardé la info del juego ganado en file saver");
            //The user won this game for the first time, so save it in file saver
            
            [chapterGamesFinishedArray addObject:@(self.selectedGame + 2)];
            [chaptersArray replaceObjectAtIndex:self.selectedChapter withObject:chapterGamesFinishedArray];
            [fileSaver setDictionary:@{@"NumberChaptersArray" : chaptersArray} withName:@"NumberChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GameWonNotification" object:nil];
        
        } else {
            NSLog(@"No guardé la info del juego ganado porque el usuario ya lo había ganado");
        }
    }
    
    [self playWinSound];
    
    //Synchronize touches left in User Defaults
    [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
    
    GameWonAlert *gameWonAlert = [[GameWonAlert alloc] initWithFrame:CGRectMake(20.0, 20.0, screenBounds.size.width - 40.0, screenBounds.size.height - 40.0)];
    gameWonAlert.delegate = self;
    gameWonAlert.touchesMade = numberOfTaps;
    gameWonAlert.touchesForBestScore = bestTapCount;
    gameWonAlert.touchesScore = [self pointsWonForTaps:numberOfTaps];
    gameWonAlert.maxTouchesScore = bestTapsScore;
    gameWonAlert.timeUsed = timeElapsed;
    gameWonAlert.timeForBestScore = bestTime;
    NSUInteger bonusPointsWon = [self pointsWonForTime:timeElapsed] + pointsForBestScore;
    if (bonusPointsWon > bestTimeScore) bonusPointsWon = bestTimeScore;
    gameWonAlert.bonusScore = bonusPointsWon;
    gameWonAlert.maxBonusScore = bestTimeScore;
    [gameWonAlert showAlertInView:self.view];
}

#pragma mark - Sounds

-(void)playRestartSound {
    [self.playerGameRestarted stop];
    self.playerGameRestarted.currentTime = 0;
    [self.playerGameRestarted play];
}

-(void)playButtonPressedSound {
    [self.playerButtonPressed stop];
    self.playerButtonPressed.currentTime = 0;
    [self.playerButtonPressed play];
}

-(void)playWinSound {
    [self.playerGameWon play];
}

#pragma mark - Flurry Ads

-(void)showFlurryAds {
    //Check if the user removed the ads
    FileSaver *fileSaver = [[FileSaver alloc] init];
    BOOL userHasRemoveAds = [[fileSaver getDictionary:@"UserRemovedAdsDic"][@"UserRemovedAdsKey"] boolValue];
    
    if (userHasRemoveAds || userBoughtInfiniteMode) {
        //The user removed the ads
        
        //Check if this is the last game
        [self prepareNextGame];
    
    } else {
        //The user has not removed the ads, so display them.
        if ([FlurryAds adReadyForSpace:@"FullScreenAd"]) {
            NSLog(@"Mostraré el ad");
            [FlurryAds displayAdForSpace:@"FullScreenAd" onView:self.view];
        } else {
            NSLog(@"No mostraré el ad sino que lo cargaré");
            [FlurryAds fetchAdForSpace:@"FullScreenAd" frame:self.view.frame size:FULLSCREEN];
            
            //Go to the next game
            [self prepareNextGame];
        }
    }
}

#pragma mark - User Defaults 

-(BOOL)userBoughtInfiniteMode {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"infiniteMode"] boolValue]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)saveTouchesLeftInUserDefaults:(NSUInteger)touchesLeft {
    [[NSUserDefaults standardUserDefaults] setObject:@(touchesLeft) forKey:@"Touches"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveCurrentDateInUserDefaults {
    NSLog(@"Fecha actual: %@", [NSDate date]);
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"NoTouchesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeSavedDateInUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NoTouchesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)dismissVC {
    //Synchronize touches in UserDefault
    [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
    
    [[AudioPlayer sharedInstance] playBackSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareNextGame {
    if (self.selectedChapter == numberOfChapters - 1 && self.selectedGame == 8) {
        //The user won the last game of the game. Display a congrats view
        [self displayAllGamesFinishedView];
    } else {
        self.selectedGame += 1;
        [self initGame];
    }
}

-(void)displayAllGamesFinishedView {
    AllGamesFinishedView *allGamesFinishedView = [[AllGamesFinishedView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, self.view.bounds.size.height/2.0 - 200.0, 250.0, 400.0)];
    allGamesFinishedView.delegate = self;
    [allGamesFinishedView showInView:self.view];
}

-(NSUInteger)pointsWonForTaps:(NSUInteger)tapsMade {
    float points = 0;
    points = (bestTapCount * bestTapsScore)/tapsMade;
    return (int)points;
}

-(NSUInteger)pointsWonForTime:(float)time {
    float points = 0;
    float pendiente = (0 - (float)bestTimeScore) / (maxTime - 0);
    NSLog(@"********** formula para los puntos de tiempo: %f * %f + %lu", pendiente, time, (unsigned long)bestTimeScore);
    points = pendiente * time + bestTimeScore;
    
    if (points < 0) {
        points = 0;
    }
    return (int)points;
}

-(void)substractTime {
    timeElapsed += 0.1;
}

#pragma mark - Social Stuff

-(void)challengeFriends {
    /*ChallengeFriendsViewController *challengeFriendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChallengeFriends"];
    if (isPad) challengeFriendsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    challengeFriendsVC.score = [self pointsWonForTime:timeElapsed];
    [self presentViewController:challengeFriendsVC animated:YES completion:nil];*/
    
    [[GameKitHelper sharedGameKitHelper] sendScoreChallengeToPlayers:nil withScore:[self pointsWonForTime:timeElapsed] message:nil];
}

-(void)shareScoreOnSocialNetwork:(NSString *)socialNetwork {
    NSString *serviceType;
    if ([socialNetwork isEqualToString:@"facebook"]) {
        serviceType = SLServiceTypeFacebook;
    } else if ([socialNetwork isEqualToString:@"twitter"]) {
        serviceType = SLServiceTypeTwitter;
    }
    SLComposeViewController *socialViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    [socialViewController setInitialText:[NSString stringWithFormat:@"I scored %lu points playing #Cross : Numbers & Colors", (unsigned long)pointsWon]];
    [self presentViewController:socialViewController animated:YES completion:nil];
}

#pragma mark - CoreData Stuff

-(void)openCoreDataDocument {
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
    if (fileExist) {
        //Open the database document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                managedDocumentIsReady = YES;
                [self updateUI];
            } else {
                managedDocumentIsReady = NO;
            }
        }];
    } else {
        //The database document did not exist, so create it.
        [self.databaseDocument saveToURL:self.databaseDocumentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                managedDocumentIsReady = YES;
                [self updateUI];
            } else {
                managedDocumentIsReady = NO;
            }
        }];
    }
}

-(NSUInteger)getTotalScoreInCoreData {
    if (managedDocumentIsReady && self.databaseDocument.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        return [Score getTotalScoreInContext:context];
    } else {
        return 0;
    }
}

-(BOOL)checkIfScoredWasImprovedInCoreDataWithNewScore:(NSUInteger)newScore {
    if (managedDocumentIsReady && self.databaseDocument.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        
        //Get the game identifier
        NSNumber *gameIdentifier;
        if (self.selectedChapter == 0) {
            gameIdentifier = @(self.selectedGame + 1);
        } else {
            gameIdentifier = @((9*(self.selectedChapter)) + (self.selectedGame + 1));
        }
        Score *score = [Score getScoreWithType:@"numbers" identifier:gameIdentifier inManagedObjectContext:context];
        if (score) {
            NSLog(@"******************* EXISTE EL OBJETO SCORE ******************");
            if ([score.value intValue] < newScore) {
                //The score was improved
                NSLog(@"***************** SCORE MEJORADO *************************");
                NSLog(@"**************** SCORE GUARDADO EN COREDATA: %d", [score.value intValue]);
                NSLog(@"**************** SCORE LOGRADO: %lu", (unsigned long)newScore);
                return YES;
            } else {
                NSLog(@"**************** SCORE NO MEJORADO ************************");
                NSLog(@"**************** SCORE GUARDADO EN COREDATA: %d", [score.value intValue]);
                NSLog(@"**************** SCORE LOGRADO: %lu", (unsigned long)newScore);
                return NO;
            }
        } else {
            NSLog(@"No había ningun score guardado, así que si se mejoró");
            return YES;
        }
        
    } else {
        NSLog(@"No pude abrir el documento para obtener el puntaje del juego");
        //Error in the document state, alert the user
        return NO;
    }
}

-(NSUInteger)getScoredStoredInCoreData {
    if (managedDocumentIsReady && self.databaseDocument.documentState == UIDocumentStateNormal) {
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        
        //Get the game identifier
        NSNumber *gameIdentifier;
        if (self.selectedChapter == 0) {
            gameIdentifier = @(self.selectedGame + 1);
        } else {
            gameIdentifier = @((9*(self.selectedChapter)) + (self.selectedGame + 1));
        }
        Score *score = [Score getScoreWithType:@"numbers" identifier:gameIdentifier inManagedObjectContext:context];
        if (score) {
            return [score.value intValue];
        } else {
            NSLog(@"Error obteniendo el score de este juego en CoreData");
            return 0;
        }
        
    } else {
        NSLog(@"No pude abrir el documento para obtener el puntaje del juego");
        //Error in the document state, alert the user
        return 0;
    }
}

-(void)savePointsInCoreData {
    //Check database document state
    if (managedDocumentIsReady && self.databaseDocument.documentState == UIDocumentStateNormal) {
        //Do anything with the document
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        
        //Get the game identifier
        NSNumber *gameIdentifier;
        if (self.selectedChapter == 0) {
            gameIdentifier = @(self.selectedGame + 1);
        } else {
            gameIdentifier = @((9*(self.selectedChapter)) + (self.selectedGame + 1));
        }
        NSLog(@"Game Identifier: %@", gameIdentifier);
        [Score scoreWithIdentifier:gameIdentifier type:@"numbers" value:@(pointsWon) inManagedObjectContext:context];
        
    } else {
        //Error in the document state, alert the user.
    }
}

#pragma mark - Buying stuff

-(void)getPricesForPurchases {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (success) {
            NSMutableDictionary *pricesDic = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < [products count]; i++) {
                IAPProduct *product = products[i];
                self.purchasesPriceFormatter.locale = product.skProduct.priceLocale;
                if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.threehundredtouches"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"threehundredprice"];
                
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.sevenhundredtouches"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"sevenhundredprice"];
                
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.twothousandtouches"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"twothousandprice"];
                
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"infinitemode"];
                }
            }
            [self showBuyTouchesViewUsingPricesDic:pricesDic];
        }
    }];
}

-(void)showBuyTouchesViewUsingPricesDic:(NSDictionary *)pricesDic {
    BuyTouchesView *buyTouchesView = [[BuyTouchesView alloc] initWithFrame:CGRectMake(20.0, 20.0, screenBounds.size.width - 40.0, screenBounds.size.height - 40.0) pricesDic:pricesDic];
    buyTouchesView.delegate = self;
    [buyTouchesView showInView:self.view];
}

#pragma mark - GameWonAlert

-(void)gameWonAlertDidApper:(GameWonAlert *)gameWonAlert {
    //[self showFlurryAds];
}

-(void)facebookButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    [self shareScoreOnSocialNetwork:@"facebook"];
}

-(void)challengeButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    [self challengeFriends];
}

-(void)twitterButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    [self shareScoreOnSocialNetwork:@"twitter"];
}

-(void)continueButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    NSLog(@"Presioné el botón de continuar");
}

-(void)gameWonAlertDidDissapear:(GameWonAlert *)gameWonAlert {
    [self showFlurryAds];
}

#pragma mark - FlurryAdsDelegate

- (BOOL) spaceShouldDisplay:(NSString*)adSpace interstitial:(BOOL)
interstitial {
    NSLog(@"Entré al delegate");
    if (interstitial) {
        // Pause app state here
    }
    
    // Continue ad display
    return YES;
}

/*
 *  Resume app state when the interstitial is dismissed.
 */
- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    NSLog(@"Entré al spaceDidDismiss");
    if (interstitial) {
        // Resume app state here
        NSLog(@"**************Entraré al prepare next game ***************");
        [self prepareNextGame];
    }
}

#pragma mark - UIAlertViewDelegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AllGamesFinishedViewDelegate

-(void)gameFinishedViewDidDissapear:(AllGamesFinishedView *)gamesFinishedView {
    gamesFinishedView = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)gameFinishedViewWillDissapear:(AllGamesFinishedView *)gamesFinishedView {
    
}

#pragma mark - NoTouchesAlertDelegate

-(void)noTouchesAlertDidDissapear:(NoTouchesAlertView *)noTouchesAlert {
    noTouchesAlert = nil;
}

-(void)waitButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert {
    
}

-(void)buyTouchesButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert {
    [self getPricesForPurchases];
    //[self showBuyTouchesView];
}

#pragma mark - BuyTouchesViewDelegate

-(void)buyTouchesViewDidDisappear:(BuyTouchesView *)buyTouchesView {
    buyTouchesView = nil;
}

-(void)closeButtonPressedInView:(BuyTouchesView *)buyTouchesView {
    
}

-(void)moreTouchesBought:(NSUInteger)totalTouchesAvailable inView:(BuyTouchesView *)buyTouchesView {
    [TouchesObject sharedInstance].totalTouches = totalTouchesAvailable;
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %lu", (unsigned long)[TouchesObject sharedInstance].totalTouches];
    [self enableButtons];
    
    //Remove the date when there was no touches left
    [self removeSavedDateInUserDefaults];
}

-(void)infiniteTouchesBoughtInView:(BuyTouchesView *)buyTouchesView {
    userBoughtInfiniteMode = YES;
    self.touchesAvailableLabel.text = @"Infinite Touches";
    [self enableButtons];
    
    [self removeSavedDateInUserDefaults];
}

#pragma mark - Notification Handlers 

-(void)newTouchesNotificationReceived:(NSNotification *)notification {
    [self enableButtons];
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %lu", (unsigned long)[TouchesObject sharedInstance].totalTouches];
}

@end
