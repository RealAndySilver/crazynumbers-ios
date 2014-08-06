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

@interface ColorsGameViewController () <ColorPatternViewDelegate, GameWonAlertDelegate>
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

//CoreData
@property (strong, nonatomic) UIManagedDocument *databaseDocument;
@property (strong, nonatomic) NSURL *databaseDocumentURL;

@end

#define FONT_NAME @"HelveticaNeue-Light"
#define DOCUMENT_NAME @"MyDocument";

@implementation ColorsGameViewController {
    CGRect screenBounds;
    NSUInteger numberOfTaps;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    BOOL isPad;
    float maxScore;
    float maxTime;
    float timeElapsed;
    BOOL managedDocumentIsReady;
}

#pragma mark - Lazy Instantiation

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
    
    [self openCoreDataDocument];
    
    NSLog(@"Tamaño de la matriz: %d", matrixSize);
    screenBounds = [UIScreen mainScreen].bounds;
    NSLog(@"Seleccioné el juego %d en el capítulo %d", self.selectedGame, self.selectedChapter);
    [self setupUI];
    
    //[self createSquareMatrixOf:matrixSize];
    [self initGame];
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
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [FlurryAds removeAdFromSpace:@"GAME_TOP_BANNER"];
    [FlurryAds setAdDelegate:nil];
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
    backButton.frame = CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0);
    backButton.layer.cornerRadius = 4.0;
    backButton.layer.borderWidth = 1.0;
    backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    //Reset Button
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.frame = CGRectMake(screenBounds.size.width - 90, screenBounds.size.height - 60.0, 70.0, 40.0);
    resetButton.layer.cornerRadius = 4.0;
    resetButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    resetButton.layer.borderWidth = 1.0;
    [resetButton setTitle:@"Restart" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [resetButton addTarget:self action:@selector(initGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    //Color patern button
    UIButton *colorPattern = [UIButton buttonWithType:UIButtonTypeSystem];
    colorPattern.frame = CGRectMake(screenBounds.size.width/2.0 - 35.0, screenBounds.size.height - 60.0, 70.0, 40.0);
    colorPattern.layer.cornerRadius = 4.0;
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
    self.maxScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height - 110.0, 300.0, 40.0)];
    self.maxScoreLabel.textColor = [UIColor lightGrayColor];
    self.maxScoreLabel.textAlignment = NSTextAlignmentCenter;
    self.maxScoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    [self.view addSubview:self.maxScoreLabel];
}

#pragma mark - Custom Methods

-(void)resetGame {
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
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
    timeElapsed = 0;
    self.maxScoreLabel.text = [NSString stringWithFormat:@"Best Score: %d/%d", [self getScoredStoredInCoreData], (int)maxScore];
    
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
    
    //[self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    [self.columnsButtonsArray[column][row] setBackgroundColor:buttonColor];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row + 1]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column][row + 1]];
        //[self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray[column][row + 1] setBackgroundColor:buttonColor];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row - 1]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column][row - 1]];

        //[self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray[column][row - 1] setBackgroundColor:buttonColor];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column - 1][row]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column - 1][row]];

        //[self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray[column - 1][row] setBackgroundColor:buttonColor];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column + 1][row]];
        buttonColor = [self getNewColorForButton:self.columnsButtonsArray[column + 1][row]];
        
        //[self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray[column + 1][row] setBackgroundColor:buttonColor];
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
        cornerRadius = 4.0;
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
    NSLog(@"Oprimí el boton con tag %d", numberButton.tag);
    NSUInteger index = numberButton.tag - 1000;
    NSInteger column = index / matrixSize;
    NSInteger row = index % matrixSize;
    
    NSString *buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row]];
    //[self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    UIColor *buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row]];
    [self.columnsButtonsArray[column][row] setBackgroundColor:buttonColor];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row + 1]];
        //[self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row + 1]];
        [self.columnsButtonsArray[column][row + 1] setBackgroundColor:buttonColor];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column][row - 1]];
        //[self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column][row - 1]];
        [self.columnsButtonsArray[column][row - 1] setBackgroundColor:buttonColor];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column - 1][row]];
        //[self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column - 1][row]];
        [self.columnsButtonsArray[column - 1][row] setBackgroundColor:buttonColor];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray[column + 1][row]];
        //[self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column + 1][row]];
        [self.columnsButtonsArray[column + 1][row] setBackgroundColor:buttonColor];
    }
    numberOfTaps += 1;
    [self checkIfUserWon];
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
            if (![[self.columnsButtonsArray[i][j] backgroundColor] isEqual:[UIColor whiteColor]]) {
                return;
            }
        }
    }
    //Get Points won
    NSUInteger pointsWon = [self pointsWonForTime:timeElapsed];
    NSLog(@"Point Woooon %d", pointsWon);
    
    //Cancel timer
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    //[self userWon];
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];}

-(NSUInteger)pointsWonForTime:(float)time {
    float pointsWon = 0;
    NSLog(@"*********** Max Time: %f", maxTime);
    NSLog(@"*********** Max Score: %f", maxScore);
    NSLog(@"*********** Time Elapsed: %f", time);
    //pointsWon = 1/((1/maxTime)*time - 1) + (float)maxScore;
    float pendiente = (0 - maxScore) / (maxTime - 0);
    NSLog(@"********** Pendiente: %f", pendiente);
    pointsWon = pendiente * time + maxScore;
    
    if (pointsWon < 0) {
        pointsWon = 0;
    }
    return (int)pointsWon;
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
    BOOL scoreWasImproved = [self checkIfScoredWasImprovedInCoreDataWithNewScore:[self pointsWonForTime:timeElapsed]];
    
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
    if (self.selectedGame == 8) {
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
    
    NSString *winMessage = [NSString stringWithFormat:@"You finished the game in %0.1f seconds. you scored %d points", timeElapsed, [self pointsWonForTime:timeElapsed]];
    GameWonAlert *gameWonAlert = [[GameWonAlert alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, self.view.bounds.size.height/2.0 - 200.0, 250.0, 400.0)];
    gameWonAlert.message = winMessage;
    gameWonAlert.delegate = self;
    [gameWonAlert showAlertInView:self.view];
    
    //[GameWonAlert showInView:self.view];
    //[self performSelector:@selector(prepareNextGame) withObject:nil afterDelay:2.5];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareNextGame {
    self.selectedGame += 1;
    [self initGame];
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
    ChallengeFriendsViewController *challengeFriendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChallengeFriends"];
    if (isPad) challengeFriendsVC.modalPresentationStyle = UIModalPresentationFormSheet;
    challengeFriendsVC.score = [self pointsWonForTime:timeElapsed];
    [self presentViewController:challengeFriendsVC animated:YES completion:nil];
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
        [Score scoreWithIdentifier:gameIdentifier type:@"colors" value:@([self pointsWonForTime:timeElapsed]) inManagedObjectContext:context];
        
    } else {
        //Error in the document state, alert the user.
    }
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

@end
