//
//  ColorsGameViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 20/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ColorsGameViewController.h"
#import "AppInfo.h"
#import "GameWonAlert.h"
#import "ColorPatternView.h"
#import "FileSaver.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "FlurryAdDelegate.h"
#import "GameKitHelper.h"
#import <Social/Social.h>
#import "ChallengeFriendsViewController.h"
#import "Score+AddOns.h"
#import "AllGamesFinishedView.h"
#import "AudioPlayer.h"
#import "NoTouchesAlertView.h"
#import "MBProgressHUD.h"
#import "CPIAPHelper.h"
#import "IAPProduct.h"
#import "BuyTouchesView.h"
#import "TouchesObject.h"
@import AVFoundation;

@interface ColorsGameViewController () <ColorPatternViewDelegate, GameWonAlertDelegate, AllGamesFinishedViewDelegate, NoTouchesAlertDelegate, BuyTouchesViewDelegate>
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray; //Of UIButton
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) UILabel *numberOfTapsLabel;
@property (strong, nonatomic) UILabel *maxTapsLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) NSArray *colorPaletteArray;
@property (strong, nonatomic) ColorPatternView *colorPatternView;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) UILabel *maxScoreLabel;
@property (strong, nonatomic) UIButton *resetButton;
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

@implementation ColorsGameViewController {
    CGRect screenBounds;
    NSUInteger numberOfTaps;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    NSUInteger numberOfChapters;
    NSUInteger bestTapCount;
    NSUInteger bestTapsScore;
    NSUInteger bestTimeScore;
    NSUInteger bestTime;
    NSUInteger pointsWon;
    NSUInteger pointsForBestScore;
    BOOL isPad;
    float maxScore;
    float maxTime;
    float timeElapsed;
    BOOL managedDocumentIsReady;
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

-(NSArray *)colorPaletteArray {
    if (!_colorPaletteArray) {
        _colorPaletteArray = [[AppInfo sharedInstance] arrayOfChaptersColorsArray][self.selectedChapter];
    }
    return _colorPaletteArray;
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
    self.view.backgroundColor = [UIColor whiteColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
    } else {
        isPad = NO;
    }
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    numberOfChapters = [chaptersDataArray count];
    [TouchesObject sharedInstance].totalTouches = [[[NSUserDefaults standardUserDefaults] valueForKey:@"Touches"] intValue];
    
    [self openCoreDataDocument];
    
    NSLog(@"Tamaño de la matriz: %d", matrixSize);
    screenBounds = [UIScreen mainScreen].bounds;
    NSLog(@"Seleccioné el juego %d en el capítulo %d", self.selectedGame, self.selectedChapter);
    [self setupUI];
    
    //[self createSquareMatrixOf:matrixSize];
    [self initGame];
    [self configureSounds];
    
    if ([TouchesObject sharedInstance].totalTouches == 0) [self disableButtons];
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
    [FlurryAds setAdDelegate:self];
    if ([FlurryAds adReadyForSpace:@"FullScreenAd"]) {
        NSLog(@"Mostraré el ad");
        //[FlurryAds displayAdForSpace:@"FullScreenAd" onView:self.view];
    } else {
        NSLog(@"No mostraré el ad sino que lo cargaré");
        [FlurryAds fetchAdForSpace:@"FullScreenAd" frame:self.view.frame size:FULLSCREEN];
    }
    
    //Check number of touches available
    if ([TouchesObject sharedInstance].totalTouches == 0) {
        NoTouchesAlertView *noTouchesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 100.0, 280.0, 200.0)];
        noTouchesAlert.delegate = self;
        [noTouchesAlert showInView:self.view];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [FlurryAds removeAdFromSpace:@"GAME_TOP_BANNER"];
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
        self.numberOfTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height - (screenBounds.size.height/4.20), 300.0, 30.0)];
        
        if (screenBounds.size.height > 500) {
            //4 Inch
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/8.11, screenBounds.size.width, 40.0)];
            self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
        } else {
            //Small iPhone
            if (matrixSize >= 5) {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            } else {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/8.11, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            }
        }
        labelsFontSize = 18.0;
    }
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %i - Game %i", self.selectedChapter + 1, self.selectedGame + 1];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    //Back Button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(10.0, screenBounds.size.height - 50.0, 60.0, 40.0);
    backButton.layer.cornerRadius = 10.0;
    backButton.layer.borderWidth = 1.0;
    backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //Reset Button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(screenBounds.size.width - 70, screenBounds.size.height - 50.0, 60.0, 40.0);
    self.resetButton.layer.cornerRadius = 10.0;
    self.resetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.resetButton.layer.borderWidth = 1.0;
    [self.resetButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.resetButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    //Color patern button
    UIButton *colorPattern = [UIButton buttonWithType:UIButtonTypeSystem];
    colorPattern.frame = CGRectMake(screenBounds.size.width - 70.0, screenBounds.size.height - 100.0, 60.0, 40.0);
    colorPattern.layer.cornerRadius = 10.0;
    colorPattern.layer.borderColor = [UIColor lightGrayColor].CGColor;
    colorPattern.layer.borderWidth = 1.0;
    [colorPattern setTitle:@"Pattern" forState:UIControlStateNormal];
    [colorPattern setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [colorPattern addTarget:self action:@selector(showColorPatternView) forControlEvents:UIControlEventTouchUpInside];
    colorPattern.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.view addSubview:colorPattern];
    
    //Buttons container view
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    
    self.buttonsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 100.0, matrixSize*53.33333, matrixSize*53.33333)];
    self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
    self.buttonsContainerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.buttonsContainerView.layer.cornerRadius = 10.0;
    [self.view addSubview:self.buttonsContainerView];
    
    //Max Score Label
    self.maxScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 80.0, screenBounds.size.height - 50.0, 160.0, 40.0)];
    self.maxScoreLabel.layer.cornerRadius = 10.0;
    self.maxScoreLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.maxScoreLabel.layer.borderWidth = 1.0;
    self.maxScoreLabel.textColor = [UIColor lightGrayColor];
    self.maxScoreLabel.textAlignment = NSTextAlignmentCenter;
    self.maxScoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [self.view addSubview:self.maxScoreLabel];
    
    //Touches available label
    self.touchesAvailableLabel = [[UILabel alloc] initWithFrame:CGRectOffset(self.maxScoreLabel.frame, 0.0, -(self.maxScoreLabel.frame.size.height + 10.0))];
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %d", [TouchesObject sharedInstance].totalTouches];
    self.touchesAvailableLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    self.touchesAvailableLabel.textColor = [UIColor lightGrayColor];
    self.touchesAvailableLabel.layer.cornerRadius = 10.0;
    self.touchesAvailableLabel.layer.borderWidth = 1.0;
    self.touchesAvailableLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.touchesAvailableLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.touchesAvailableLabel];
    
    //Buy button
    UIButton *buyButton = [[UIButton alloc] initWithFrame:CGRectOffset(backButton.frame, 0.0, -(backButton.frame.size.height + 10.0))];
    [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    buyButton.layer.cornerRadius = 10.0;
    buyButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    buyButton.layer.borderWidth = 1.0;
    [buyButton addTarget:self action:@selector(getPricesForPurchases) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buyButton];
}

#pragma mark - Custom Methods

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
        numberButton.alpha = 0.4;
    }
}

-(void)saveTouchesLeftInUserDefaults:(NSUInteger)touchesLeft {
    [[NSUserDefaults standardUserDefaults] setObject:@(touchesLeft) forKey:@"Touches"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)restartGame {
    self.resetButton.userInteractionEnabled = NO;
    [self performSelector:@selector(enableResetButton) withObject:nil afterDelay:1.0];
    [self.playerGameRestarted play];
    [self initGame];
}

-(void)enableResetButton {
    self.resetButton.userInteractionEnabled = YES;
}

-(void)resetGame {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    /*for (int i = 0; i < [self.buttonsContainerView.subviews count]; i++) {
        UIView *view = self.buttonsContainerView.subviews[i];
        view = nil;
    }*/
    [self.columnsButtonsArray removeAllObjects];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    if (self.selectedGame >= [chaptersDataArray[self.selectedChapter] count]) {
        self.selectedChapter += 1;
        self.selectedGame = 0;
    }
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    maxScore = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxScore"] floatValue];
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
    
    //Set the new color palette to use
    self.colorPaletteArray = [[AppInfo sharedInstance] arrayOfChaptersColorsArray][self.selectedChapter];
    
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
            //[self.columnsButtonsArray[i][j] setTitle:@"0" forState:UIControlStateNormal];
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
    
    //Check if user dont have touches available
    if ([TouchesObject sharedInstance].totalTouches == 0) [self disableButtons];
}

-(void)initGame {
    [self resetGame];
    NSLog(@"Pasé del reset game");
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %i - Game %i", self.selectedChapter + 1, self.selectedGame + 1];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    self.pointsArray = chaptersDataArray[self.selectedChapter][self.selectedGame][@"puntos"];
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        [self addOneToButtonAtRow:row column:column];
        //NSUInteger buttonTag = [self tagForButtonAtRow:row column:column];
        //[self addOneToButtonWithTag:buttonTag];
    }
    self.maxTapsLabel.text = [NSString stringWithFormat:@"Taps for perfect score: %d", [self.pointsArray count]];
    self.numberOfTapsLabel.text = @"Number of taps: 0";
    numberOfTaps = 0;
    NSLog(@"Terminé el init game");
    
    //Start the game timer
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

-(void)addOneToButtonAtRow:(NSInteger)row column:(NSInteger)column {
    NSString *buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row]];
    UIColor *buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column][row]];
    
    //[self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal]
    UIButton *button = self.columnsButtonsArray[column][row];
    button.backgroundColor = buttonColor;
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row + 1]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column][row + 1]];
        //[self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
        UIButton *button = self.columnsButtonsArray[column][row + 1];
        button.backgroundColor = buttonColor;
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row - 1]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column][row - 1]];

        //[self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
        UIButton *button = self.columnsButtonsArray[column][row - 1];
        button.backgroundColor = buttonColor;
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column - 1][row]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column - 1][row]];

        //[self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        UIButton *button = self.columnsButtonsArray[column - 1][row];
        button.backgroundColor = buttonColor;
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column + 1][row]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column + 1][row]];
        
        //[self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        UIButton *button = self.columnsButtonsArray[column + 1][row];
        button.backgroundColor = buttonColor;
    }
}

-(UIColor *)getNewColorForButton:(UIButton *)button {
    UIColor *currentColor = button.backgroundColor;
    NSUInteger currentColorIndex;
    for (int i = 0; i < [self.colorPaletteArray count]; i++) {
        UIColor *color = self.colorPaletteArray[i];
        if ([currentColor isEqual:color]) {
            currentColorIndex = i;
            break;
        }
    }
    
    UIColor *newColor = self.colorPaletteArray[currentColorIndex + 1];
    return newColor;
}

-(NSString *)getNewValueForButton:(UIButton *)button {
    NSString *newTitle = [NSString stringWithFormat:@"%i", [button.currentTitle intValue] + 1];
    return newTitle;
}

-(UIColor *)substractColorForButton:(UIButton *)button {
    UIColor *currentColor = button.backgroundColor;
    NSUInteger currentColorIndex;
    for (int i = 0; i < [self.colorPaletteArray count]; i++) {
        UIColor *color = self.colorPaletteArray[i];
        if ([currentColor isEqual:color]) {
            currentColorIndex = i;
            break;
        }
    }
    
    if (currentColorIndex == 0) {
        UIColor *newColor = self.colorPaletteArray[maxNumber];
        return newColor;
    } else {
        UIColor *newColor = self.colorPaletteArray[currentColorIndex - 1];
        return newColor;
    }
}

-(NSString *)substractOneForButton:(UIButton *)button {
    NSInteger newbuttonValue = [button.currentTitle intValue] - 1;
    if (newbuttonValue < 0) {
        newbuttonValue = maxNumber;
    }
    return [NSString stringWithFormat:@"%i", newbuttonValue];
}

-(void)createSquareMatrixOf:(NSUInteger)size {
    NSUInteger buttonDistance;
    NSUInteger cornerRadius;
    if (isPad) {
        buttonDistance = 20.0;
        cornerRadius = 10.0;
    } else {
        buttonDistance = 10.0;
        cornerRadius = 10.0;
    }
    NSUInteger buttonSize = (self.buttonsContainerView.frame.size.width - ((matrixSize + 1)*buttonDistance)) / matrixSize;
    NSLog(@"Tamaño del boton: %d", buttonSize);
    
    int h = 1000;
    for (int i = 0; i < size; i++) {
        NSMutableArray *filaButtonsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < size; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = cornerRadius;
            //button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            //button.layer.borderWidth = 1.0;
            button.frame = CGRectMake(buttonDistance + (i*buttonSize + buttonDistance*i), buttonDistance + (j*buttonSize + buttonDistance*j), buttonSize, buttonSize);
            button.backgroundColor = self.colorPaletteArray[0];
            //[button setTitle:@"0" forState:UIControlStateNormal];
            if (matrixSize < 5) {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:80.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
            } else {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:70.0];
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

-(void)showColorPatternView {
    self.opacityView = [[UIView alloc] initWithFrame:self.view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.7;
    [self.view addSubview:self.opacityView];
    
    self.colorPatternView = [[ColorPatternView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 220, 280.0, 440) colorsArray:self.colorPaletteArray];
    self.colorPatternView.delegate = self;
    [self.colorPatternView showinView:self.view];
}

-(void)numberButtonPressed:(UIButton *)numberButton {
    //Play sound
    [self playButtonPressedSound];
    
    NSLog(@"Oprimí el boton con tag %d", numberButton.tag);
    NSUInteger index = numberButton.tag - 1000;
    NSInteger column = index / matrixSize;
    NSInteger row = index % matrixSize;
    
    NSString *buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row]];
    //[self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    UIColor *buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row]];
    [(UIButton *)self.columnsButtonsArray[column][row] setBackgroundColor:buttonColor];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row + 1]];
        //[self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row + 1]];
        [(UIButton *)self.columnsButtonsArray[column][row + 1] setBackgroundColor:buttonColor];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row - 1]];
        //[self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row - 1]];
        [(UIButton *)self.columnsButtonsArray[column][row - 1] setBackgroundColor:buttonColor];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column - 1][row]];
        //[self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column - 1][row]];
        [(UIButton *)self.columnsButtonsArray[column - 1][row] setBackgroundColor:buttonColor];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column + 1][row]];
        //[self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column + 1][row]];
        [(UIButton *)self.columnsButtonsArray[column + 1][row] setBackgroundColor:buttonColor];
    }
    numberOfTaps += 1;
    [TouchesObject sharedInstance].totalTouches--;
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %d", [TouchesObject sharedInstance].totalTouches];
    
    if ([TouchesObject sharedInstance].totalTouches == 0) {
        //Show alert
        NoTouchesAlertView *noTouchesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 100.0, 280.0, 200.0)];
        noTouchesAlert.delegate = self;
        [noTouchesAlert showInView:self.view];
        
        [self disableButtons];
        [self saveCurrentDateInUserDefaults];
    }

    [self checkIfUserWon];
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

-(void)updateUI {
    self.maxScoreLabel.text = [NSString stringWithFormat:@"Best Score: %d/%d", [self getScoredStoredInCoreData], (int)maxScore];
}

-(void)substractTime {
    timeElapsed += 0.1;
}

-(void)checkIfUserWon {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            if (![((UIButton *)[self.columnsButtonsArray[i][j] backgroundColor]) isEqual:[UIColor whiteColor]]) {
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

    
    //Cancel timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    //[self userWon];
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];}

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

-(void)showFlurryAds {
    //Check if the user removed the ads
    FileSaver *fileSaver = [[FileSaver alloc] init];
    BOOL userHasRemoveAds = [[fileSaver getDictionary:@"UserRemovedAdsDic"][@"UserRemovedAdsKey"] boolValue];
    
    if (!userHasRemoveAds) {
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
    } else {
        //The user removed the ads
        [self prepareNextGame];
    }
}

-(void)userWon {
    BOOL scoreWasImproved = [self checkIfScoredWasImprovedInCoreDataWithNewScore:pointsWon];
    
    //Send data to Flurry
    [Flurry logEvent:@"ColorsGameWon" withParameters:@{@"Chapter" : @(self.selectedChapter), @"Game" : @(self.selectedGame)}];
    [self savePointsInCoreData];
    if (scoreWasImproved) {
        NSLog(@"EL score se mejoróoooo *************************");
        NSUInteger totalScore = [self getTotalScoreInCoreData];
        NSLog(@"Score Totaaaaaaaalllllll: %d", totalScore);
        [[GameKitHelper sharedGameKitHelper] submitScore:totalScore category:@"Points_Leaderboard"];
        
    } else {
        NSLog(@"El score no se mejoróooooot *************************");
    }
    
    //Unlock the next game saving the game number with FileSaver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableArray *chaptersArray = [fileSaver getDictionary:@"ColorChaptersDic"][@"ColorChaptersArray"];
    NSLog(@"Agregando el número %d a filesaver porque gané", self.selectedGame + 2);
    
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
            [fileSaver setDictionary:@{@"ColorChaptersArray" : chaptersArray} withName:@"ColorChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorGameWonNotification" object:nil];
            
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
            [fileSaver setDictionary:@{@"ColorChaptersArray" : chaptersArray} withName:@"ColorChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorGameWonNotification" object:nil];
            
            //Save points to fileSaver
           /* NSUInteger points = 0;
            if ([fileSaver getDictionary:@"UserPointsDic"][@"UserPoints"]) {
                points = [[fileSaver getDictionary:@"UserPointsDic"][@"UserPoints"] intValue];
                points += [self pointsWonForTime:timeElapsed];
                [fileSaver setDictionary:@{@"UserPoints" : @(points)} withName:@"UserPointsDic"];
            } else {
                points = [self pointsWonForTime:timeElapsed];
                [fileSaver setDictionary:@{@"UserPoints" : @(points)} withName:@"UserPointsDic"];
            }
            
            NSLog(@"Sending %d points to game center ****************", points);
            [[GameKitHelper sharedGameKitHelper] submitScore:points category:@"Points_Leaderboard"];*/
            
        } else {
            NSLog(@"No guardé la info del juego ganado orque el usuario ya lo había ganado");
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

-(void)playButtonPressedSound {
    [self.playerButtonPressed stop];
    self.playerButtonPressed.currentTime = 0;
    [self.playerButtonPressed play];
}

-(void)playWinSound {
    [self.playerGameWon play];
}

-(void)dismissVC {
    //Synchronize touches left in User Defaults
    [self saveTouchesLeftInUserDefaults:[TouchesObject sharedInstance].totalTouches];
    
    [[AudioPlayer sharedInstance] playBackSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareNextGame {
    if (self.selectedChapter == numberOfChapters - 1 && self.selectedGame == 8) {
        //The user won the last game of the game. Display a congrats view
        [self displayAllGamesFinishedView];
        //[[[UIAlertView alloc] initWithTitle:@"Congrats!" message:@"You have completed all the numbers game!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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

#pragma mark - ColorPatternViewDelegate

-(void)colorPatternViewWillDissapear:(ColorPatternView *)colorPatternView {
    [self.opacityView removeFromSuperview];
    self.opacityView = nil;
}

-(void)colorPatternViewDidDissapear:(ColorPatternView *)colorPatternView {
    self.colorPatternView = nil;
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
    [socialViewController setInitialText:[NSString stringWithFormat:@"I scored %d points playing Cross: Numbers & Colors", [self pointsWonForTime:timeElapsed]]];
    [self presentViewController:socialViewController animated:YES completion:nil];
}

#pragma mark - CoreData Stuff

-(void)openCoreDataDocument {
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
    if (fileExist) {
        //Open the database document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Abrí el documento de core data");
                managedDocumentIsReady = YES;
                [self updateUI];
            } else {
                managedDocumentIsReady = NO;
                NSLog(@"Error opening the document");
            }
        }];
    } else {
        //The database document did not exist, so create it.
        [self.databaseDocument saveToURL:self.databaseDocumentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Abrí el documento de core data");
                managedDocumentIsReady = YES;
                [self updateUI];
            } else {
                managedDocumentIsReady = NO;
                NSLog(@"Error opening the document");
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
        Score *score = [Score getScoreWithType:@"colors" identifier:gameIdentifier inManagedObjectContext:context];
        if (score) {
            NSLog(@"******************* EXISTE EL OBJETO SCORE ******************");
            if ([score.value intValue] < newScore) {
                //The score was improved
                NSLog(@"***************** SCORE MEJORADO *************************");
                NSLog(@"**************** SCORE GUARDADO EN COREDATA: %d", [score.value intValue]);
                NSLog(@"**************** SCORE LOGRADO: %d", newScore);
                return YES;
            } else {
                NSLog(@"**************** SCORE NO MEJORADO ************************");
                NSLog(@"**************** SCORE GUARDADO EN COREDATA: %d", [score.value intValue]);
                NSLog(@"**************** SCORE LOGRADO: %d", newScore);
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
        Score *score = [Score getScoreWithType:@"colors" identifier:gameIdentifier inManagedObjectContext:context];
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
        [Score scoreWithIdentifier:gameIdentifier type:@"colors" value:@(pointsWon) inManagedObjectContext:context];
        
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
        [self prepareNextGame];
    }
}

#pragma mark - AllGamesFinishedViewDelegate

-(void)gameFinishedViewDidDissapear:(AllGamesFinishedView *)gamesFinishedView {
    gamesFinishedView = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)gameFinishedViewWillDissapear:(AllGamesFinishedView *)gamesFinishedView {
    
}

#pragma mark - NoTouchesAlert 

-(void)waitButtonPressedInAlert:(NoTouchesAlertView *)noTouchesAlert {
    
}

-(void)buyTouchesButtonPressedInAlert:(NoTouchesAlertView *)noTouchesAlert {
    [self getPricesForPurchases];
}

-(void)noTouchesAlertDidDissapear:(NoTouchesAlertView *)noTouchesAlert {
    noTouchesAlert = nil;
}

#pragma mark - BuyTouchesViewDelegate

-(void)buyTouchesViewDidDisappear:(BuyTouchesView *)buyTouchesView {
    buyTouchesView = nil;
}

-(void)closeButtonPressedInView:(BuyTouchesView *)buyTouchesView {
    
}

-(void)moreTouchesBought:(NSUInteger)totalTouchesAvailable inView:(BuyTouchesView *)buyTouchesView {
    [TouchesObject sharedInstance].totalTouches = totalTouchesAvailable;
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %d", [TouchesObject sharedInstance].totalTouches];
    [self enableButtons];
    
    //Remove the date when there was no touches left
    [self removeSavedDateInUserDefaults];
}

#pragma mark - Notification Handlers

-(void)newTouchesNotificationReceived:(NSNotification *)notification {
    [self enableButtons];
    self.touchesAvailableLabel.text = [NSString stringWithFormat:@"Touches left: %d", [TouchesObject sharedInstance].totalTouches];
}

@end
