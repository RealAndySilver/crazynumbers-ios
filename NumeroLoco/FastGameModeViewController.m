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

@interface FastGameModeViewController () <FastGameAlertDelegate, BuyLivesViewDelegate, NoTouchesAlertDelegate, MultiplayerWinAlertDelegate, AllGamesFinishedViewDelegate, FastGamesViewDelegate>
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) NSTimer *gameTimer;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *timeLeftLabel;
@property (strong, nonatomic) UILabel *heartNumberLabel;
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray;
@property (strong, nonatomic) NSNumberFormatter *purchasesPriceFormatter;
@property (strong, nonatomic) NSString *gameType;
@property (strong, nonatomic) NSArray *colorPaletteArray;
@property (assign, nonatomic) NSUInteger currentGame;
@property (strong, nonatomic) NSArray *chaptersDataArray;
@property (strong, nonatomic) NSString *gamesDatabasePath;
@end

#define FONT_LIGHT @"HelveticaNeue-Light"
#define FONT_ULTRALIGHT @"HelveticaNeue-UltraLight"

@implementation FastGameModeViewController {
    CGRect screenBounds;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    NSUInteger maxTime;
    NSUInteger timeLeft;
    NSUInteger totalGames;
    BOOL isPad;
    BOOL userCanPlay;
    BOOL userBoughtInfiniteMode;
}

-(NSArray *)colorPaletteArray {
    if (!_colorPaletteArray) {
        _colorPaletteArray = [[AppInfo sharedInstance] arrayOfChaptersColorsArray][0];
    }
    return _colorPaletteArray;
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
    self.gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"FastGamesDatabase" ofType:@"plist"];
    self.chaptersDataArray = [NSArray arrayWithContentsOfFile:self.gamesDatabasePath];
    totalGames = [self.chaptersDataArray count];
    self.currentGame = [self getLastUnlockedLevelInUserDefaults] - 1;
    if ([self userBoughtInfiniteMode]) userBoughtInfiniteMode = YES;
    else userBoughtInfiniteMode = NO;
    screenBounds = [UIScreen mainScreen].bounds;
    if ([self getLivesFromUserDefaults] == 0) userCanPlay = NO;
    else userCanPlay = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) isPad = YES;
    else isPad = NO;
    [self setupUI];
    [self initGame];
    if (!userCanPlay && !userBoughtInfiniteMode) {
        [self disableGame];
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
    if (!userCanPlay && !userBoughtInfiniteMode) {
        [self showBuyMoreLivesAlert];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}

-(void)setupUI {
    //Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, screenBounds.size.height - 50.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
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
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, screenBounds.size.width, 50.0)];
        self.titleLabel.font = [UIFont fontWithName:FONT_ULTRALIGHT size:40.0];
    }
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:self.titleLabel];
    
    //Time left label
    self.timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 70.0, screenBounds.size.height - 50.0, 140.0, 40.0)];
    self.timeLeftLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLeftLabel.textColor = [UIColor darkGrayColor];
    self.timeLeftLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    self.timeLeftLabel.layer.cornerRadius = 10.0;
    self.timeLeftLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.timeLeftLabel.layer.borderWidth = 1.0;
    [self.view addSubview:self.timeLeftLabel];
    
    //Games button
    UIButton *gamesButton = [[UIButton alloc] initWithFrame:CGRectMake(screenBounds.size.width - 80.0, screenBounds.size.height - 50.0, 70.0, 40.0)];
    [gamesButton setTitle:@"Games" forState:UIControlStateNormal];
    [gamesButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    gamesButton.titleLabel.font = [UIFont fontWithName:FONT_LIGHT size:15.0];
    gamesButton.layer.cornerRadius = 10.0;
    gamesButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    gamesButton.layer.borderWidth = 1.0;
    [gamesButton addTarget:self action:@selector(showGamesView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gamesButton];
    
    //Heart image view
    UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    heartImageView.frame = CGRectMake(10.0, screenBounds.size.height - 110.0, 50.0, 50.0);
    [self.view addSubview:heartImageView];
    
    //HEart number label
    self.heartNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(heartImageView.frame.origin.x + heartImageView.frame.size.width, screenBounds.size.height - 110.0, 100.0, 50.0)];
    self.heartNumberLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    if (userBoughtInfiniteMode)
        self.heartNumberLabel.text = @"x Infinite";
    else
        self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
    self.heartNumberLabel.font = [UIFont fontWithName:FONT_LIGHT size:20.0];
    [self.view addSubview:self.heartNumberLabel];
    
    //Buttons container view
    self.buttonsContainerView = [[UIView alloc] init];
    self.buttonsContainerView.layer.cornerRadius = 10.0;
    [self.view addSubview:self.buttonsContainerView];
}

-(void)initGame {
    [self resetGame];
    self.titleLabel.text = [NSString stringWithFormat:@"Game %u", self.currentGame + 1];
    
    self.pointsArray = self.chaptersDataArray[self.currentGame][@"puntos"];
    NSLog(@"numero de puntos: %d", [self.pointsArray count]);
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        if ([self.gameType isEqualToString:@"number"])
            [self addOneToButtonAtRow:row column:column];
        else
            [self addColorToButtonAtRow:row column:column];
    }
    
    //Start the game timer
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

-(void)resetGame {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.columnsButtonsArray removeAllObjects];
    
    matrixSize = [self.chaptersDataArray[self.currentGame][@"matrixSize"] intValue];
    maxNumber = [self.chaptersDataArray[self.currentGame][@"maxNumber"] intValue];
    maxTime = [self.chaptersDataArray[self.currentGame][@"maxTime"] intValue];
    self.gameType = self.chaptersDataArray[self.currentGame][@"type"];
    if ([self.gameType isEqualToString:@"number"]) {
        self.buttonsContainerView.backgroundColor = [UIColor whiteColor];
    } else {
        self.buttonsContainerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
    timeLeft = maxTime;
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %lus", (unsigned long)timeLeft];
 
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
    NSUInteger randomColorIndex = arc4random()%3;
    
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

#pragma mark - Actions 

-(void)showGamesView {
    //Invaldiate timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    FastGamesView *fastGamesView;
    if (isPad) {
        fastGamesView = [[FastGamesView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 280.0/2.0, screenBounds.size.height/2.0 - 528.0/2.0, 280.0, 528.0)];
    } else {
         fastGamesView = [[FastGamesView alloc] initWithFrame:CGRectMake(20.0, 20.0, self.view.bounds.size.width - 40.0, self.view.bounds.size.height - 40.0)];
    }
    fastGamesView.delegate = self;
    [fastGamesView showInView:self.view];
}

-(void)colorButtonPressed:(UIButton *)numberButton {
    
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
    [self checkIfUserWonAtColorsGame];
}

-(void)numberButtonPressed:(UIButton *)numberButton {
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
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %lus", (unsigned long)timeLeft];
    if (timeLeft == 0) {
        //User loss
        [self userLost];
    }
}

#pragma mark - Winning & Lossing

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
            [self saveCurrentDateInUserDefaults];
        } else {
            [self showLossAlert];
        }
    } else {
        //Show loss alert
        [self showLossAlert];
    }
}

#pragma mark - Enabling and disabling buttons 

-(void)disableGame {
    [self disableButtons];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}

-(void)enableButtons {
    for (UIButton *button in self.buttonsContainerView.subviews) {
        button.userInteractionEnabled = YES;
        button.alpha = 1.0;
    }
}

-(void)disableButtons {
    for (UIButton *button in self.buttonsContainerView.subviews) {
        button.userInteractionEnabled = NO;
        button.alpha = 0.5;
    }
}

-(void)enableTimer {
    timeLeft = 10.0;
    self.timeLeftLabel.text = [NSString stringWithFormat:@"Time left: %lus", (unsigned long)timeLeft];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
}

#pragma mark - NSUserDefaults

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

-(void)saveCurrentDateInUserDefaults {
    NSLog(@"Fecha actual: %@", [NSDate date]);
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"NoLivesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)reduceLivesInUserDefaults {
    NSUInteger currentLives = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
    currentLives--;
    [[NSUserDefaults standardUserDefaults] setObject:@(currentLives) forKey:@"lives"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSUInteger)getLivesFromUserDefaults {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
}

-(void)removeSavedDateInUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NoLivesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Actions 

-(void)showAllGamesWonAlert {
    AllGamesFinishedView *allGamesWonAlert = [[AllGamesFinishedView alloc] initWithFrame:self.view.bounds];
    allGamesWonAlert.messageLabel.text = @"You have completed all fast mode games! Wait for more games soon!";
    allGamesWonAlert.messageLabel.transform = CGAffineTransformMakeTranslation(0.0, 100.0);
    allGamesWonAlert.closeButton.transform = CGAffineTransformMakeTranslation(0.0, -100.0);
    allGamesWonAlert.congratsLabel.transform = CGAffineTransformMakeTranslation(0.0, 60.0);
    allGamesWonAlert.delegate = self;
    [allGamesWonAlert showInView:self.view];
}

-(void)showBuyMoreLivesAlert {
    NoTouchesAlertView *noLivesAlert = [[NoTouchesAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 100.0, 280.0, 200.0)];
    noLivesAlert.message.text = @"You have no more lives left! You can buy more right now or wait one hour.";
    [noLivesAlert.acceptButton setTitle:@"Buy Lives" forState:UIControlStateNormal];
    noLivesAlert.delegate = self;
    [noLivesAlert showInView:self.view];
}

-(void)showWinAlert {
    FastGameWinAlert *fastGameWinAlert = [[FastGameWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    fastGameWinAlert.delegate = self;
    fastGameWinAlert.tag = 1;
    fastGameWinAlert.alertLabel.text = [NSString stringWithFormat:@"You have won game %lu, keep going!", (unsigned long)self.currentGame + 1];
    [fastGameWinAlert showInView:self.view];
}

-(void)showLossAlert {
    FastGameWinAlert *lossAlert = [[FastGameWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 140.0, 280.0, 280.0)];
    lossAlert.delegate = self;
    lossAlert.tag = 2;
    [lossAlert.continueButton setTitle:@"Try again" forState:UIControlStateNormal];
    lossAlert.alertLabel.text = [NSString stringWithFormat:@"You have lost game %lu. Try to be faster next time!", (unsigned long)self.currentGame + 1];
    [lossAlert showInView:self.view];
}

-(void)showStartGameAlert {
    MultiplayerWinAlert *startGameAlert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, self.view.bounds.size.height/2.0 - 85.0, 280.0, 170.)];
    startGameAlert.delegate = self;
    startGameAlert.alertMessage = @"Congratulations! You have more lives available, start playing!";
    [startGameAlert.acceptButton setTitle:@"Start Game" forState:UIControlStateNormal];
    startGameAlert.messageLabel.font = [UIFont fontWithName:FONT_LIGHT size:17.0];
    [startGameAlert showAlertInView:self.view];
}

-(void)dismissVC {
    [[AudioPlayer sharedInstance] playBackSound];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayMusicNotification" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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
        }
    }];
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
    [[AudioPlayer sharedInstance] playBackSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)continueButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert {
    if (fastGameWinAlert.tag == 1) {
        self.currentGame++;
        [self initGame];
    } else if (fastGameWinAlert.tag == 2){
        [self initGame];
    }
}

-(void)buyLivesButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert {
    [self getPricesForPurchases];
}

#pragma mark - BuyLivesViewDelegate

-(void)moreLivesBought:(NSUInteger)livesAvailable inView:(BuyLivesView *)buyLivesView {
    self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)livesAvailable];
    [self enableButtons];
    [self removeSavedDateInUserDefaults];
}

-(void)infiniteModeBoughtInView:(BuyLivesView *)buyLivesView {
    userBoughtInfiniteMode = YES;
    self.heartNumberLabel.text = @"x Infinite";
    [self enableButtons];
    [self removeSavedDateInUserDefaults];
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
}

-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert {
    winAlert = nil;
}

#pragma mark - AllGamesFinishedViewDleegat

-(void)gameFinishedViewWillDissapear:(AllGamesFinishedView *)gamesFinishedView {
    
}

-(void)gameFinishedViewDidDissapear:(AllGamesFinishedView *)gamesFinishedView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FastGamesViewDelegate

-(void)gameSelected:(NSUInteger)game inFastGamesView:(FastGamesView *)fastGamesView {
    NSLog(@"Seleccioné el juego %lu", (unsigned long)game);
    self.currentGame = game;
    [self initGame];
    if (!userCanPlay) {
        [self disableGame];
    }
}

-(void)closeButtonPressedInFastGameView:(FastGamesView *)fastGamesView {
    if (userCanPlay) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(substractTime) userInfo:nil repeats:YES];
    }
}

#pragma mark - Notification Handlers 

-(void)newLivesNotificationReceived:(NSNotification *)notification {
    self.heartNumberLabel.text = [NSString stringWithFormat:@"x %lu", (unsigned long)[self getLivesFromUserDefaults]];
    [self enableButtons];
    [self showStartGameAlert];
}

@end
