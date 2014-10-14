//
//  FastGameModeViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 25/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FastGameModeViewController.h"
#import "AppInfo.h"
#import "FastGameWinAlert.h"
#import "MBProgressHUD.h"
#import "CPIAPHelper.h"
#import "IAPProduct.h"
#import "BuyLivesView.h"
#import "NoTouchesAlertView.h"
#import "MultiplayerWinAlert.h"
#import "AllGamesFinishedView.h"
#import "FastGamesView.h"
#import "AudioPlayer.h"
#import "TwoButtonsAlert.h"
#import "OneButtonAlert.h"
#import "FileSaver.h"
#import "TutorialContainerViewController.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "FlurryAdDelegate.h"

@interface FastGameModeViewController () <FastGameAlertDelegate, BuyLivesViewDelegate, NoTouchesAlertDelegate, MultiplayerWinAlertDelegate, AllGamesFinishedViewDelegate, FastGamesViewDelegate, TwoButtonsAlertDelegate>
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLeftLabel;
@property (strong, nonatomic) UILabel *heartNumberLabel;
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) UIButton *restartButton;
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray;
@property (strong, nonatomic) NSNumberFormatter *purchasesPriceFormatter;
@property (strong, nonatomic) NSString *gameType;
@property (strong, nonatomic) NSArray *colorPaletteArray;
@property (assign, nonatomic) NSUInteger currentGame;
@property (strong, nonatomic) NSArray *chaptersDataArray;
@property (strong, nonatomic) NSString *gamesDatabasePath;
@property (strong, nonatomic) UIButton *gamesButton;
@property (strong, nonatomic) UIImageView *heartImageView;
@end

#define FONT_LIGHT @"HelveticaNeue-Light"
#define FONT_ULTRALIGHT @"HelveticaNeue-UltraLight"
#define TIME_FOR_NEW_LIVES 7200

@implementation FastGameModeViewController {
    CGRect screenBounds;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    NSUInteger maxTime;
    NSUInteger timeLeft;
    NSUInteger totalGames;
    NSUInteger selectedGameInFastView;
    NSUInteger randomColorIndex;
    NSUInteger fastGameWinAlertActiveTag;
    float timeAnimationDuration;
    BOOL timeLabelAnimationActive;
    
    BOOL isPad;
    BOOL userCanPlay;
    BOOL userBoughtInfiniteMode;
    BOOL ticTocSoundActivated;
    BOOL initialFastGamesViewLaunch;
}

-(NSNumberFormatter *)purchasesPriceFormatter {
    if (!_purchasesPriceFormatter) {
        _purchasesPriceFormatter = [[NSNumberFormatter alloc] init];
        _purchasesPriceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        _purchasesPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    return _purchasesPriceFormatter;
}

-(NSMutableArray *)columnsButtonsArray {
    if (!_columnsButtonsArray) {
        _columnsButtonsArray = [[NSMutableArray alloc] init];
    }
    return _columnsButtonsArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    initialFastGamesViewLaunch = YES;
    ticTocSoundActivated = [self getTicTocSelectionInUserDefaults];
    timeAnimationDuration = 0.5;
    self.gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"FastGamesDatabase" ofType:@"plist"];
    self.chaptersDataArray = [NSArray arrayWithContentsOfFile:self.gamesDatabasePath];
    totalGames = [self.chaptersDataArray count];
    //self.currentGame = [self getLastUnlockedLevelInUserDefaults] - 1;
    if ([self userBoughtInfiniteMode]) {
        userBoughtInfiniteMode = YES;
        NSLog(@"Tengo modo infinito");
    } else {
        NSLog(@"No tengo modo infinito");
        userBoughtInfiniteMode = NO;

    } screenBounds = [UIScreen mainScreen].bounds;
    if ([self getLivesFromUserDefaults] == 0) userCanPlay = NO;
    else userCanPlay = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) isPad = YES;
    else isPad = NO;
    [self setupUI];
    [self initGame];
    if (!userCanPlay && !userBoughtInfiniteMode) {
        [self disableGame];
    }
    
    [self performSelector:@selector(checkLives) withObject:nil afterDelay:0.5];
    
    //Flurry
    if (!userBoughtInfiniteMode) {
        //Add adds from Flurry
        [FlurryAds setAdDelegate:self];
        if ([FlurryAds adReadyForSpace:@"FullScreenAd2"]) {
            NSLog(@"Mostraré el ad");
            //[FlurryAds displayAdForSpace:@"FullScreenAd" onView:self.view];
        } else {
            NSLog(@"No mostraré el ad sino que lo cargaré");
            [FlurryAds fetchAdForSpace:@"FullScreenAd2" frame:self.view.frame size:FULLSCREEN];
        }
    }
    
    //Check if this is the first time the user launch the app
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![[fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"] boolValue]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        [fileSaver setDictionary:@{@"FirstAppLaunchKey" : @YES} withName:@"FirstAppLaunchDic"];
        NSLog(@"Iré al tutorial");
        [self performSelector:@selector(goToTutorialVC) withObject:nil afterDelay:0.5];
    } else {
        NSLog(@"No iré al tutorial");
    }
}

-(void)checkLives {
    if (!userCanPlay && !userBoughtInfiniteMode) {
        [self showBuyMoreLivesAlert];
    } else  {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
        if ([self userOpenFastModeForFirstTime]) {
            [self showStartAlert];
            [self saveUserOpenFastModeFirstTimeKey];
        } else {
            [self showGamesView];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newLivesNotificationReceived:)
                                                 name:@"NewLivesAvailable"
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    timeLabelAnimationActive = NO;
}

-(void)setupUI {
    //Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, screenBounds.size.height - 50.0, 70.0, 40.0)];
    [backButton setTitle:NSLocalizedString(@"Back", @"Title for a button that returns the user to the previous screen") forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    backButton.layer.cornerRadius = 10.0;
    backButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //Title label
    if (isPad) {
        NSLog(@"IPAAAAAAAD");
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 100.0, screenBounds.size.width, 100.0)];
        self.titleLabel.font = [UIFont fontWithName:FONT_ULTRALIGHT size:80.0];
    } else {
        NSLog(@"NO IPAAAAAD");
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/11.36 - 10.0, screenBounds.size.width, 50.0)];
        self.titleLabel.font = [UIFont fontWithName:FONT_ULTRALIGHT size:40.0];
    }
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.titleLabel];
    
    //Time left label
    //self.timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 70.0, screenBounds.size.height - 50.0, 140.0, 40.0)];
    self.timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 45.0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, 90.0, 40.0)];
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.timeLeftLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.timeLeftLabel.font = [UIFont fontWithName:FONT_LIGHT size:28.0];
    [self.view addSubview:self.timeLeftLabel];
    
    //Restart button
    self.restartButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width - 80.0, screenBounds.size.height - 50.0, 70.0, 40.0)];
    [self.restartButton setTitle:NSLocalizedString(@"Reset", @"Title for a button that reset the game") forState:UIControlStateNormal];
    [self.restartButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.restartButton.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    self.restartButton.layer.cornerRadius = 10.0;
    self.restartButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.restartButton.layer.borderWidth = 1.0;
    [self.restartButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.restartButton];
    
    //Games button
    self.gamesButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 35.0, screenBounds.size.height - 50.0, 70.0, 40.0)];
    [self.gamesButton setTitle:NSLocalizedString(@"Games", @"Title for a button that opens the list of games") forState:UIControlStateNormal];
    [self.gamesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.gamesButton.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    self.gamesButton.layer.cornerRadius = 10.0;
    self.gamesButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.gamesButton.layer.borderWidth = 1.0;
    [self.gamesButton addTarget:self action:@selector(showGamesView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.gamesButton];
    
    //Heart image view
    UIImage *heartImage = [UIImage imageNamed:@"heart.png"];
    heartImage = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.heartImageView = [[UIImageView alloc] initWithImage:heartImage];
    self.heartImageView.frame = CGRectMake(10.0, screenBounds.size.height - 110, 50.0, 50.0);
    [self.view addSubview:self.heartImageView];
    
    //HEart number label
    self.heartNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.heartImageView.frame.origin.x + self.heartImageView.frame.size.width, screenBounds.size.height - 110, 100.0, 50.0)];
    if (userBoughtInfiniteMode) {
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %@", NSLocalizedString(@"Infinite", @"Infinite")];
        self.heartNumberLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    }
    else {
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
        self.heartNumberLabel.font = [UIFont fontWithName:FONT_LIGHT size:20.0];
    }
    [self.view addSubview:self.heartNumberLabel];
    
    //Buttons container view
    self.buttonsContainerView = [[UIView alloc] init];
    self.buttonsContainerView.layer.cornerRadius = 10.0;
    [self.view addSubview:self.buttonsContainerView];
}

-(void)initGame {
    randomColorIndex = arc4random()%4;
    [self resetGame];
    NSLog(@"RANDOM COLOR INDEX EN EL INIT GAME: %lu", (unsigned long)randomColorIndex);
    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Game %lu", @"The current game"), self.currentGame + 1];
    self.heartNumberLabel.textColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    self.heartImageView.tintColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    
    self.pointsArray = self.chaptersDataArray[self.currentGame][@"puntos"];
    //NSLog(@"numero de puntos: %lu", (unsigned long)[self.pointsArray count]);
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        if ([self.gameType isEqualToString:@"number"])
            [self addOneToButtonAtRow:row column:column];
        else
            [self addColorToButtonAtRow:row column:column];
    }
    
    if ([self.gameType isEqualToString:@"number"]) {
        maxNumber = [self getMaxNumber];
    } else {
        maxNumber = [self getMaxNumberFromColor];
    }
}

-(NSUInteger)getMaxNumberFromColor {
    NSUInteger max = 0;
    
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            UIButton *button = self.columnsButtonsArray[i][j];
            UIColor *currentColor = button.backgroundColor;
            NSUInteger currentColorIndex;
            for (int i = 0; i < [self.colorPaletteArray count]; i++) {
                UIColor *color = self.colorPaletteArray[i];
                if ([currentColor isEqual:color]) {
                    currentColorIndex = i;
                    if (currentColorIndex > max) {
                        max = currentColorIndex;
                    }
                    break;
                }
            }
        }
    }
    
    return max;
}

-(NSUInteger)getMaxNumber {
    NSUInteger max = 0;
    
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            UIButton *button = self.columnsButtonsArray[i][j];
            NSUInteger buttonNumber = [button.currentTitle intValue];
            if (buttonNumber > max) {
                max = buttonNumber;
            }
        }
    }
    
    return max;
}

-(void)startTimer {
    timeLeft = maxTime;
    //NSLog(@"*************TIME LEFT: %d", timeLeft);
    //self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %lus", (unsigned long)timeLeft];
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)timeLeft];
    
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

-(void)resetGame {
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.columnsButtonsArray removeAllObjects];
    
    matrixSize = [self.chaptersDataArray[self.currentGame][@"matrixSize"] intValue];
    //maxNumber = [self.chaptersDataArray[self.currentGame][@"maxNumber"] intValue];
    //maxTime = [self.chaptersDataArray[self.currentGame][@"maxTime"] intValue];
    if (self.currentGame < 100) {
        maxTime = 15.0;
    } else if (self.currentGame < 200) {
        maxTime = 25.0;
    } else  {
        maxTime = 30.0;
    }
    self.gameType = self.chaptersDataArray[self.currentGame][@"type"];
    //NSUInteger randColor = arc4random()%4;
    self.colorPaletteArray = [[AppInfo sharedInstance] arrayOfChaptersColorsArray][randomColorIndex];
    if ([self.gameType isEqualToString:@"number"]) {
        self.buttonsContainerView.backgroundColor = [UIColor whiteColor];
    } else {
        self.buttonsContainerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
 
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
    
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            if ([self.gameType isEqualToString:@"number"]) {
                [self.columnsButtonsArray[i][j] setTitle:@"0" forState:UIControlStateNormal];
            } else {
                //[(UIButton *)self.columnsButtonsArray[i][j] setBackgroundColor:[UIColor whiteColor]];
            }
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
}

-(void)createSquareMatrixOf:(NSUInteger)size {
    NSLog(@"RANDOM COLOR INDEX EN EL CREATE SQUARE: %lu", (unsigned long)randomColorIndex);
    
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
            if ([self.gameType isEqualToString:@"number"])
                button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
            else
                button.backgroundColor = self.colorPaletteArray[0];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = cornerRadius;
            button.frame = CGRectMake(buttonDistance + (i*buttonSize + buttonDistance*i), buttonDistance + (j*buttonSize + buttonDistance*j), buttonSize, buttonSize);
            if ([self.gameType isEqualToString:@"number"]) [button setTitle:@"0" forState:UIControlStateNormal];

            if (matrixSize < 5) {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:40.0];
            } else {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:70.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:30.0];
            }
            
            if ([self.gameType isEqualToString:@"number"]) {
                [button addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            button.tag = h;
            [self.buttonsContainerView addSubview:button];
            [filaButtonsArray addObject:button];
            h+=1;
        }
        [self.columnsButtonsArray addObject:filaButtonsArray];
    }
}

#pragma mark - Colors

-(void)addColorToButtonAtRow:(NSInteger)row column:(NSInteger)column {
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

#pragma mark -

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
    NSLog(@"nuevo titulo: %@", newTitle);
    return newTitle;
}

-(NSString *)substractOneForButton:(UIButton *)button {
    NSInteger newbuttonValue = [button.currentTitle intValue] - 1;
    if (newbuttonValue < 0) {
        newbuttonValue = maxNumber;
    }
    return [NSString stringWithFormat:@"%li", (long)newbuttonValue];
}

#pragma mark - Sounds 

-(void)playShakerSound {
    if (ticTocSoundActivated) {
        [[AudioPlayer sharedInstance] playShakeSound];
    }
}

#pragma mark - Actions 

-(void)goToTutorialVC {
    TutorialContainerViewController *tutContainerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TutorialContainer"];
    [self presentViewController:tutContainerVC animated:YES completion:nil];
}

-(void)exitGame {
    [[AudioPlayer sharedInstance] playRestartSound];
    [[AudioPlayer sharedInstance] stopShakeSound];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayMusicNotification" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)restartGame {
    [[AudioPlayer sharedInstance] playRestartSound];
    [self initGame];
}

-(void)showGamesView {
    //Invaldiate timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    [[AudioPlayer sharedInstance] pauseShakeSound];
    
    FastGamesView *fastGamesView;
    if (isPad) {
        fastGamesView = [[FastGamesView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 280.0/2.0, screenBounds.size.height/2.0 - 528.0/2.0, 280.0, 528.0)];
    } else {
         fastGamesView = [[FastGamesView alloc] initWithFrame:CGRectMake(20.0, 20.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 40.0)];
    }
    fastGamesView.viewColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    fastGamesView.delegate = self;
    fastGamesView.initialCell = [self getLastUnlockedLevelInUserDefaults] - 1;
    if (initialFastGamesViewLaunch) {
        fastGamesView.closeButton.hidden = YES;
    } else {
        fastGamesView.closeButton.hidden = NO;
    }
    [fastGamesView showInView:self.view];
}

-(void)colorButtonPressed:(UIButton *)numberButton {
    [[AudioPlayer sharedInstance] playButtonPressSound];
    
    NSLog(@"Oprimí el boton con tag %ld", (long)numberButton.tag);
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
    [self checkIfUserWonAtColorsGame];
}

-(void)numberButtonPressed:(UIButton *)numberButton {
    [[AudioPlayer sharedInstance] playButtonPressSound];
    
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
    
    [self checkIfUserWon];
}

-(void)showLivesPurchases {
    [self.gameTimer invalidate];
}

#pragma mark - Timers Stuff

-(void)substractTime {
    timeLeft--;
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)timeLeft];
    
    if (maxTime == 15.0) {
        if (timeLeft >= 10.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
        } else if (timeLeft < 10.0 && timeLeft >= 5.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.4;
        } else if (timeLeft < 5.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.8;
        }
        
    } else if (maxTime == 25.0) {
        if (timeLeft >= 15.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
        } else if (timeLeft < 15.0 && timeLeft >= 5.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.4;
        } else if (timeLeft < 5.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.8;
        }
    
    } else if (maxTime == 30.0) {
        if (timeLeft >= 20.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
        } else if (timeLeft < 20.0 && timeLeft >= 10.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.4;
        } else if (timeLeft < 10.0) {
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.8;
        }
    }
    
    if (timeLeft == 0) {
        //User loss
        [self userLost];
    }
}

#pragma mark - Animation 

-(void)startTimeLabelAnimation {
    if (maxTime == 15.0) {
        if (timeLeft > 10.0) {
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            timeAnimationDuration = 0.5;
            
        }else if (timeLeft <= 10.0 && timeLeft > 5.0) {
            timeAnimationDuration = 0.25;
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            
        } else if (timeLeft <= 5.0) {
            timeAnimationDuration = 0.125;
            self.timeLeftLabel.textColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
        }
    
    } else  if (maxTime == 25.0) {
        if (timeLeft > 15.0) {
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            timeAnimationDuration = 0.5;
            
        }else if (timeLeft <= 15.0 && timeLeft > 5.0) {
            timeAnimationDuration = 0.25;
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            
        } else if (timeLeft <= 5.0) {
            timeAnimationDuration = 0.125;
            self.timeLeftLabel.textColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
        }
    
    }  if (maxTime == 30.0) {
        if (timeLeft > 20.0) {
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            timeAnimationDuration = 0.5;
            
        }else if (timeLeft <= 20.0 && timeLeft > 10.0) {
            timeAnimationDuration = 0.25;
            self.timeLeftLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            
        } else if (timeLeft <= 10.0) {
            timeAnimationDuration = 0.125;
            self.timeLeftLabel.textColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
        }
    }
    
    if (timeLabelAnimationActive) {
        //NSLog(@"11 ESTÁ ACTIVO EL TIMELABEL ANIMATION ACTIVE");
        [UIView animateWithDuration:timeAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(){
                             self.timeLeftLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                         } completion:^(BOOL finished){
                             //NSLog(@"LLAMARE AL SECONDTIMELABELANIMATION");
                             [self secondTimeLabelAnimation];
                         }];
    } else {
        //NSLog(@"11 NO ESTÁ ACTIVO EL TIME LABEL ANIMATION ACTIVE");
    }
}

-(void)secondTimeLabelAnimation {
    if (timeLabelAnimationActive) {
        //NSLog(@"22 ESTÁ ACTIV EL TIME LABEL ANIMATION ACTIVE");
        [UIView animateWithDuration:timeAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.timeLeftLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
                         } completion:^(BOOL finished) {
                             [self startTimeLabelAnimation];
                         }];
    } else {
        //NSLog(@"22 NO ESTA ACTIVO EL TIME LABEL ANIMATION ACTIVE");
    }
}

#pragma mark - Winning & Lossing

-(void)prepareNextGame {
    NSLog(@"Entré al prepare next gameeeeeee");
    [[AudioPlayer sharedInstance] playRestartSound];
    
    if (fastGameWinAlertActiveTag == 1) {
        self.currentGame++;
        [self initGame];
        [self startTimer];
        [self playShakerSound];
        timeLabelAnimationActive = YES;
        [self startTimeLabelAnimation];
        
    } else if (fastGameWinAlertActiveTag == 2){
        [self initGame];
        [self startTimer];
        [self playShakerSound];
        timeLabelAnimationActive = YES;
        [self startTimeLabelAnimation];
    }
}

-(void)checkIfUserWonAtColorsGame {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            if (![((UIButton *)[self.columnsButtonsArray[i][j] backgroundColor]) isEqual:[UIColor whiteColor]]) {
                return;
            }
        }
    }
    //User won
    //Play sound
    [[AudioPlayer sharedInstance] playWinSound];
    
    //Cancel timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];
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
    //Play sound
    [[AudioPlayer sharedInstance] playWinSound];
    
    //Cancel timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];
}

-(void)userWon {
    timeLabelAnimationActive = NO;
    [[AudioPlayer sharedInstance] stopShakeSound];
    [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
    
    if (self.currentGame == totalGames - 1) {
        NSLog(@"Ganaste el ultim juego");
        [self showAllGamesWonAlert];
    } else {
        //NSLog(@"Current game: %lu", (unsigned long)self.currentGame + 1);
        //NSLog(@"Nivel desbloqueado en user defaults: %lu", (unsigned long)[self getLastUnlockedLevelInUserDefaults]);
        if (self.currentGame + 1 >= [self getLastUnlockedLevelInUserDefaults]) {
            [self saveNewUnlockedGameInUserDefaults];
        }
        [self showWinAlert];
    }
}

-(void)userLost {
    timeLabelAnimationActive = NO;
    [[AudioPlayer sharedInstance] stopShakeSound];
    [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
    [[AudioPlayer sharedInstance] playAlarmSound];
    [AudioPlayer sharedInstance].alarmSound.volume = 1.0;
    
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    
    if (!userBoughtInfiniteMode) {
        [self reduceLivesInUserDefaults];
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
        if ([self getLivesFromUserDefaults] == 0) {
            //Show buy more lives alert
            [self showBuyMoreLivesAlert];
            [self disableButtons];
            userCanPlay = NO;
            //[self saveCurrentDateInUserDefaults];
        } else {
            [self showLossAlert];
        }
    } else {
        //Show loss alert
        [self showLossAlert];
    }
    
    //Fade out thr alarm sound
    [self performSelector:@selector(fadeOutAlarm) withObject:nil afterDelay:2.0];
}

-(void)fadeOutAlarm {
    if ([AudioPlayer sharedInstance].alarmSound.volume > 0.0) {
        NSLog(@"entre acaaaa");
        [AudioPlayer sharedInstance].alarmSound.volume -= 0.02;
        [self performSelector:@selector(fadeOutAlarm) withObject:nil afterDelay:0.01];
    }
}

#pragma mark - Enabling and disabling buttons 

-(void)disableGame {
    NSLog(@"ENTRE AL DISABLE GAMEEEEEEEEEEE");
    
    [self disableButtons];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    timeLabelAnimationActive = NO;
}

-(void)enableButtons {
    self.gamesButton.userInteractionEnabled = YES;
    self.gamesButton.alpha = 1.0;
    
    for (UIButton *button in self.buttonsContainerView.subviews) {
        //button.userInteractionEnabled = YES;
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        if ([self.gameType isEqualToString:@"number"]) {
            [button addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }        button.alpha = 1.0;
    }
    self.restartButton.userInteractionEnabled = YES;
    self.restartButton.alpha = 1.0;
}

-(void)disableButtons {
    self.gamesButton.alpha = 0.5;
    self.gamesButton.userInteractionEnabled = NO;
    
    for (UIButton *button in self.buttonsContainerView.subviews) {
        //button.userInteractionEnabled = NO;
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(showBuyMoreLivesAlert) forControlEvents:UIControlEventTouchUpInside];
        button.alpha = 0.5;
    }
    self.restartButton.userInteractionEnabled = NO;
    self.restartButton.alpha = 0.5;
}

-(void)enableTimer {
    if (self.currentGame < 100) {
        timeLeft = 15.0;
    } else if (self.currentGame < 200) {
        timeLeft = 25.0;
    } else  {
        timeLeft = 30.0;
    }
    
    self.timeLeftLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)timeLeft];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

#pragma mark - NSUserDefaults

-(BOOL)getTicTocSelectionInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tictocActive"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"tictocActive"] boolValue];
    } else {
        return YES;
    }
}

-(NSUInteger)getLastUnlockedLevelInUserDefaults {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"unlockedFastGames"] intValue];
}

-(void)saveNewUnlockedGameInUserDefaults {
    NSLog(@"NUEVO JUEGO DESBLOQUEADO: %lu", (unsigned long)self.currentGame + 2);
    [[NSUserDefaults standardUserDefaults] setObject:@(self.currentGame + 2) forKey:@"unlockedFastGames"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)userBoughtInfiniteMode {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"infiniteMode"] boolValue]) {
        return YES;
    } else {
        return NO;
    }
}

-(void)reduceLivesInUserDefaults {
    NSUInteger currentLives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
    //Checkear si hay menos de cinco vidas y guardar como fcha una hora mas tarde para
    //devolverle las vidas
    if (currentLives <= 5.0 && !userBoughtInfiniteMode) {
        //Guardar una hora despues de la ultima hora guardada. Si no hay ninguna hora guardada, guardar
        //una hora despues de la actual
        if ([self getLastSaveDateInUserDefaults]) {
            NSLog(@"SI EXISTIA UNA HORA GUARDADA");
            NSDate *lastSavedDate = [self getLastSaveDateInUserDefaults];
            NSDate *oneHourLaterDate = [lastSavedDate dateByAddingTimeInterval:TIME_FOR_NEW_LIVES];
            [self saveDateInUserDefaults:oneHourLaterDate];
            
            //Save a notification to show the user that the new lives are available
            [self removeLivesLocalNotifications];
            [self saveLocalNotificationWithFireDate:oneHourLaterDate];
            
        } else {
            NSLog(@"NO EXISTIA UNA HORA GUARDADA");
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:TIME_FOR_NEW_LIVES];
            [self saveDateInUserDefaults:date];
            [self removeLivesLocalNotifications];
            [self saveLocalNotificationWithFireDate:date];
        }
    }
    
    currentLives--;
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLives) forKey:@"lives"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveDateInUserDefaults:(NSDate *)date {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"]) {
        NSLog(@"YA EXISTIA EL ARREGLO DE FECHAS");
        NSArray *savedDatesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"];
        NSMutableArray *giveTouchesDatesArray = [[NSMutableArray alloc] initWithArray:savedDatesArray];
        if (giveTouchesDatesArray) {
            NSLog(@"EL ARREGLO DE FECHAS ESTÁ BIEN, Y TIENE %lu FECHAS GUARDADAS", (unsigned long)[giveTouchesDatesArray count]);
        } else {
            NSLog(@"EL ARREGLO DE FECHAS ESTA EN NIL");
        }
        [giveTouchesDatesArray addObject:date];
        NSLog(@"PUDE AGREGAR LA NUEVA FECHA AL ARREGLO");
        [[NSUserDefaults standardUserDefaults] setObject:giveTouchesDatesArray forKey:@"GiveLivesDatesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (NSDate *date in giveTouchesDatesArray) {
            NSLog(@"FECHA GUARDADA: %@", date);
        }
        
    } else {
        NSLog(@"NO EXISTIA EL ARREGLO DE FECHAS");
        NSMutableArray *giveTouchesDatesArray = [[NSMutableArray alloc] init];
        [giveTouchesDatesArray addObject:date];
        [[NSUserDefaults standardUserDefaults] setObject:giveTouchesDatesArray forKey:@"GiveLivesDatesArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        for (NSDate *date in giveTouchesDatesArray) {
            NSLog(@"FECHA GUARDADA: %@", date);
        }
    }
}

-(NSDate *)getLastSaveDateInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"]) {
        NSMutableArray *giveTouchesDatesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"GiveLivesDatesArray"];
        NSDate *lastSavedDate = [giveTouchesDatesArray lastObject];
        return lastSavedDate;
    } else {
        return nil;
    }
}

-(NSUInteger)getLivesFromUserDefaults {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
}

-(void)saveUserOpenFastModeFirstTimeKey {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"userOpenFastMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)userOpenFastModeForFirstTime {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userOpenFastMode"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"userOpenFastMode"] boolValue];
    } else {
        return YES;
    }
}

#pragma mark - Actions 

-(void)showExitWarningAlert {
    TwoButtonsAlert *warningAlert = [[TwoButtonsAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    warningAlert.alertText = NSLocalizedString(@"Warning! If you exit while the game is in progress, you will lose one life.", @"Message to inform the user that he will lose one life");
    warningAlert.leftButtonTitle = NSLocalizedString(@"Exit", @"Title for the exit button");
    warningAlert.rightButtonTitle = NSLocalizedString(@"Cancel", @"Title for the cancel button");
    warningAlert.tag = 2;
    warningAlert.delegate = self;
    warningAlert.messageLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    warningAlert.rightButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    warningAlert.leftButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    [warningAlert showInView:self.view];
}

-(void)showLivesWarningAlert {
    TwoButtonsAlert *warningAlert = [[TwoButtonsAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    warningAlert.alertText = NSLocalizedString(@"Warning! if you exit the last unlocked game while the game is in progress, you will lose one life.", @"Warning message that appears if the user tries to exit while the last unlocked game is in course");
    warningAlert.leftButtonTitle = NSLocalizedString(@"Exit", @"Title for the exit button");
    warningAlert.rightButtonTitle = NSLocalizedString(@"Cancel", @"Title for the cancel button");
    warningAlert.tag = 3;
    warningAlert.delegate = self;
    warningAlert.rightButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    warningAlert.leftButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    warningAlert.messageLabel.frame = CGRectMake(20.0, 40.0, warningAlert.bounds.size.width - 40.0, 60.0);
    warningAlert.messageLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    [warningAlert showInView:self.view];
}

-(void)showStartAlert {
    TwoButtonsAlert *startAlert = [[TwoButtonsAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    startAlert.alertText = NSLocalizedString(@"Welcome to Fast Mode! You have just few seconds (10s - 30s) to complete each level! Be fast!", @"Welcome message");
    startAlert.leftButtonTitle = NSLocalizedString(@"Start!", @"Title for the start fast game button");
    startAlert.rightButtonTitle = NSLocalizedString(@"Exit", @"Title for the exit fast game button");
    startAlert.tag = 1;
    startAlert.delegate = self;
    startAlert.leftButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    startAlert.rightButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    startAlert.messageLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    startAlert.messageLabel.frame = CGRectMake(20.0, 20.0, startAlert.bounds.size.width - 40.0, 100.0);
    [startAlert showInView:self.view];
}

-(void)showAllGamesWonAlert {
    AllGamesFinishedView *allGamesWonAlert = [[AllGamesFinishedView alloc] initWithFrame:self.view.bounds];
    allGamesWonAlert.messageLabel.text = NSLocalizedString(@"You have completed all fast mode games! Wait for more games soon!", @"Message that appears when the user completes all games");
    allGamesWonAlert.messageLabel.transform = CGAffineTransformMakeTranslation(0.0, 100.0);
    allGamesWonAlert.closeButton.transform = CGAffineTransformMakeTranslation(0.0, -100.0);
    allGamesWonAlert.congratsLabel.transform = CGAffineTransformMakeTranslation(0.0, 60.0);
    allGamesWonAlert.delegate = self;
    [allGamesWonAlert showInView:self.view];
}

-(void)showBuyMoreLivesAlert {
    NoTouchesAlertView *noLivesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 100.0, 280.0, 200.0)];
    noLivesAlert.message.text = NSLocalizedString(@"You have no more lives left! Every two hours you'll get one life. You can wait or buy some!", @"Message that appears when the user has no more lives left");
    [noLivesAlert.acceptButton setTitle:NSLocalizedString(@"Buy Lives", @"Title for the buy lives button") forState:UIControlStateNormal];
    noLivesAlert.acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    noLivesAlert.delegate = self;
    [noLivesAlert showInView:self.view];
}

-(void)showWinAlert {
    FastGameWinAlert *fastGameWinAlert = [[FastGameWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    fastGameWinAlert.delegate = self;
    fastGameWinAlert.tag = 1;
    fastGameWinAlertActiveTag = 1;
    fastGameWinAlert.buyLivesButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    fastGameWinAlert.continueButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    fastGameWinAlert.alertLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You have won game %lu, keep going!", @"Message that appears when the user wins a game"), (unsigned long)self.currentGame + 1];
    [fastGameWinAlert showInView:self.view];
}

-(void)showLossAlert {
    FastGameWinAlert *lossAlert = [[FastGameWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    lossAlert.delegate = self;
    lossAlert.tag = 2;
    fastGameWinAlertActiveTag = 2;
    lossAlert.buyLivesButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    lossAlert.continueButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    [lossAlert.continueButton setTitle:NSLocalizedString(@"Try Again", @"Title for the try again button") forState:UIControlStateNormal];
    lossAlert.alertLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You have lost one life. Try to be faster next time!", @"Message that appears when the user lost the game")];
    [lossAlert showInView:self.view];
}

-(void)showStartGameAlert {
    MultiplayerWinAlert *startGameAlert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 85.0, 280.0, 170.)];
    startGameAlert.delegate = self;
    startGameAlert.alertMessage = NSLocalizedString(@"Congratulations! You have more lives available, start playing!", @"Message that appears when the user buy lives");
    [startGameAlert.acceptButton setTitle:NSLocalizedString(@"Start Game", @"Title for the start game button") forState:UIControlStateNormal];
    startGameAlert.messageLabel.font = [UIFont fontWithName:FONT_LIGHT size:17.0];
    [startGameAlert showAlertInView:self.view];
}

-(void)dismissVC {
    [[AudioPlayer sharedInstance] pauseShakeSound];
    
    NSLog(@"ENTRE AL DISMISSSSSS");
    //Check if the user is trying to exit the last game
    if (self.currentGame == [self getLastUnlockedLevelInUserDefaults] - 1 && [self getLivesFromUserDefaults] > 0 && !userBoughtInfiniteMode && self.currentGame != totalGames - 1) {
        NSLog(@"Trying to exit the last game");
        [self showExitWarningAlert];
        [self disableTimer];
    } else {
        [[AudioPlayer sharedInstance] stopShakeSound];
        [[AudioPlayer sharedInstance] playBackSound];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayMusicNotification" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)disableTimer {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
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
                if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.fivelives"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"priceForFive"];
                    
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.twentylives"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"priceForTwenty"];
                    
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.sixtylives"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"priceForSixty"];
                    
                } else if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
                    NSString *price = [self.purchasesPriceFormatter stringFromNumber:product.skProduct.price];
                    [pricesDic setObject:price forKey:@"infinitemode"];
                }
            }
            [self showBuyLivesViewUsingPricesDic:pricesDic];
        } else {
            [self showErrorAlert];
        }
    }];
}

-(void)showErrorAlert {
    OneButtonAlert *errorAlert = [[OneButtonAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, screenBounds.size.height/2.0 - 85.0, 280.0, 170.0)];
    errorAlert.alertText = NSLocalizedString(@"Oops! There was a network error. Please check that you're connected to the internet.", @"A message that appears when there's a network error");
    errorAlert.button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][randomColorIndex];
    errorAlert.buttonTitle = NSLocalizedString(@"Ok", @"Title for the accept button");
    errorAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    errorAlert.messageLabel.center = CGPointMake(errorAlert.messageLabel.center.x, 70.0);
    [errorAlert showInView:self.view];
}

-(void)showBuyLivesViewUsingPricesDic:(NSDictionary *)pricesDic {
    BuyLivesView *buyLivesView;
    if (isPad) {
        buyLivesView = [[BuyLivesView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 280.0/2.0, screenBounds.size.height/2.0 - 528.0/2.0, 280.0, 528.0) pricesDic:pricesDic];
    } else {
           buyLivesView = [[BuyLivesView alloc] initWithFrame:CGRectMake(20.0, 20.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 40.0) pricesDic:pricesDic];
    }
    buyLivesView.delegate = self;
    [buyLivesView showInView:self.view];
}

#pragma mark - FastGameWinAlertDelegate

-(void)exitButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert {
    [self exitGame];
}

-(void)continueButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert {
    [self performSelector:@selector(showFlurryAds) withObject:nil afterDelay:0.3];
}

-(void)buyLivesButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert {
    [self getPricesForPurchases];
}

#pragma mark - BuyLivesViewDelegate

-(void)moreLivesBought:(NSUInteger)livesAvailable inView:(BuyLivesView *)buyLivesView {
    if (!userBoughtInfiniteMode) {
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)livesAvailable];
    }
    [self enableButtons];
}

-(void)infiniteModeBoughtInView:(BuyLivesView *)buyLivesView {
    userBoughtInfiniteMode = YES;
    self.heartNumberLabel.text = [NSString stringWithFormat:@"x %@", NSLocalizedString(@"Infinite", @"Infinite")];
    self.heartNumberLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    [self enableButtons];
}

-(void)buyLivesViewDidDisappear:(BuyLivesView *)buyLivesView {
    if (!userCanPlay) {
        if ([self getLivesFromUserDefaults] > 0) {
            userCanPlay = YES;
            [self showStartGameAlert];
        }
    }
}

#pragma mark - NoTouchesAlert

-(void)waitButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert {
    
}

-(void)buyTouchesButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert {
    [self getPricesForPurchases];
}

-(void)noTouchesAlertDidDissapear:(NoTouchesAlertView *)multiplayerAlert {
    multiplayerAlert = nil;
}

#pragma mark - MultiplayerWinAlerDelegate

-(void)acceptButtonPressedInWinAlert:(MultiplayerWinAlert *)winAlert {
    [self enableTimer];
    timeLabelAnimationActive = YES;
    [self startTimeLabelAnimation];
}

-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert {
    winAlert = nil;
}

#pragma mark - AllGamesFinishedViewDleegat

-(void)gameFinishedViewWillDissapear:(AllGamesFinishedView *)gamesFinishedView {
    
}

-(void)gameFinishedViewDidDissapear:(AllGamesFinishedView *)gamesFinishedView {
    [self dismissVC];
}

#pragma mark - FastGamesViewDelegate

-(void)gameSelected:(NSUInteger)game inFastGamesView:(FastGamesView *)fastGamesView {
    selectedGameInFastView = game;
    
    NSLog(@"Seleccioné el juego %lu", (unsigned long)game);
    if (self.currentGame == game) {
        if (initialFastGamesViewLaunch) {
            timeLabelAnimationActive = YES;
            [self startTimer];
            [self startTimeLabelAnimation];
            initialFastGamesViewLaunch = NO;
            [self playShakerSound];
        } else {
            NSLog(@"Escogí el mismo juego, que siga corriendo el timer");
            self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
            [self playShakerSound];
        }

    } else if (self.currentGame == [self getLastUnlockedLevelInUserDefaults] - 1) {
        NSLog(@"Intentado hacer trampaaaaaaa");
        [self showLivesWarningAlert];
    
    } else {
        if (initialFastGamesViewLaunch) {
            NSLog(@"SSSSSSSSSSSSSSSSSSS");
            [[AudioPlayer sharedInstance] playRestartSound];
            [[AudioPlayer sharedInstance] stopShakeSound];
            [self playShakerSound];
            self.currentGame = game;
            timeLabelAnimationActive = YES;
            [self initGame];
            [self startTimer];
            [self startTimeLabelAnimation];
            initialFastGamesViewLaunch = NO;
            
        } else {
            [[AudioPlayer sharedInstance] playRestartSound];
            [[AudioPlayer sharedInstance] stopShakeSound];
            [self playShakerSound];
            self.currentGame = game;
            [self initGame];
            [self startTimer];
        }
    }
    if (!userCanPlay && !userBoughtInfiniteMode) {
        NSLog(@"ENTRE A ESTE !USERCANPLAY");
        [self disableGame];
    }
}

-(void)closeButtonPressedInFastGameView:(FastGamesView *)fastGamesView {
    if (userCanPlay) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
        [self playShakerSound];
    }
}

#pragma mark - OneButtonAlertDelegate

/*-(void)oneButtonAlertDidDisappear:(OneButtonAlert *)oneButtonAlert {
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

-(void)buttonClickedInAlert:(OneButtonAlert *)oneButtonAlert {
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}*/

#pragma mark - TwoButtonsAlert 

-(void)leftButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert {
    if (twoButtonsAlert.tag == 1) {
        timeLabelAnimationActive = YES;
        [self playShakerSound];
        [self startTimer];
        [self startTimeLabelAnimation];
        
    } else if (twoButtonsAlert.tag == 2) {
        //The user exit the game in course. Dismiss VC and reduce one life
        [self reduceLivesInUserDefaults];
        [self exitGame];
        
    } else if (twoButtonsAlert.tag == 3) {
        [self reduceLivesInUserDefaults];
        if (!userBoughtInfiniteMode) {
            self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
        }
        self.currentGame = selectedGameInFastView;
        if ([self getLivesFromUserDefaults] == 0) {
            userCanPlay = NO;
            [self initGame];
            [self disableGame];
            [self performSelector:@selector(showBuyMoreLivesAlert) withObject:nil afterDelay:1.0];
        } else {
            [self startTimer];
            [self initGame];
            [[AudioPlayer sharedInstance] stopShakeSound];
            [AudioPlayer sharedInstance].shakerPlayer.rate = 1.0;
            [self playShakerSound];
        }
    }
}

-(void)rightButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert {
    if (twoButtonsAlert.tag == 1) {
        [self exitGame];
    } else if (twoButtonsAlert.tag == 2 || twoButtonsAlert.tag == 3) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
        [self playShakerSound];
    }
}

-(void)twoButtonsAlertDidDisappear:(TwoButtonsAlert *)twoButtonsAlert {
    if (twoButtonsAlert.tag == 1) {
        [self startTimer];
        timeLabelAnimationActive = YES;
        [self startTimeLabelAnimation];
        
    } else if (twoButtonsAlert.tag == 2 || twoButtonsAlert.tag == 3) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
        [self playShakerSound];
    }
}

#pragma mark - Notification Handlers 

-(void)newLivesNotificationReceived:(NSNotification *)notification {
    if (!userBoughtInfiniteMode) {
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
    }
    [self enableButtons];
    //[self showStartGameAlert];
}

#pragma mark - Local Notification Stuff

-(void)saveLocalNotificationWithFireDate:(NSDate *)date {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertAction = NSLocalizedString(@"New Lives!", @"New lives message");
    localNotification.alertBody = NSLocalizedString(@"All your lives have been restored!", @"Message that informs the user that the lives have been restored");
    localNotification.fireDate = date;
    localNotification.userInfo = @{@"notificationID" : @"livesNotification"};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)removeLivesLocalNotifications {
    NSArray *notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i = 0; i < [notificationsArray count]; i++) {
        UILocalNotification *notification = notificationsArray[i];
        NSDictionary *notificationDic = notification.userInfo;
        if ([[notificationDic objectForKey:@"notificationID"] isEqualToString:@"livesNotification"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
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
        if ([FlurryAds adReadyForSpace:@"FullScreenAd2"]) {
            NSLog(@"Mostraré el ad");
            [FlurryAds displayAdForSpace:@"FullScreenAd2" onView:self.view viewControllerForPresentation:self];
        } else {
            NSLog(@"No mostraré el ad sino que lo cargaré");
            [FlurryAds fetchAdForSpace:@"FullScreenAd2" frame:self.view.frame size:FULLSCREEN];
            
            //Go to the next game
            [self prepareNextGame];
        }
    }
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial {
    NSLog(@"Entré al spaceDidDismiss");
    if (interstitial) {
        // Resume app state here
        NSLog(@"**************Entraré al prepare next game ***************");
        [self prepareNextGame];
    }
}

@end
