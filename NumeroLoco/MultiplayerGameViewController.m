//
//  MultiplayerGameViewController.m
//  NumeroLoco
//
//  Created by Developer on 30/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MultiplayerGameViewController.h"
#import "FileSaver.h"
#import "AppInfo.h"
#import "GameKitHelper.h"
#import "GameWonAlert.h"
#import "MultiplayerWinAlert.h"

@interface MultiplayerGameViewController () <GameWonAlertDelegate, UIAlertViewDelegate, MultiplayerWinAlertDelegate>
@property (weak, nonatomic) IBOutlet UILabel *gamesWonTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesWonBottomLabel;
@property (weak, nonatomic) IBOutlet UIView *topSideVIew;
@property (weak, nonatomic) IBOutlet UIView *bottomSideView;
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray;
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray2;
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIView *buttonsContainerView2;
@property (strong, nonatomic) UIButton *startButtonTop;
@property (strong, nonatomic) UIButton *startButtonBottom;
@property (strong, nonatomic) NSTimer *startGameTimer;
@property (strong, nonatomic) UILabel *counterLabel;
@property (strong, nonatomic) UIButton *singlePlayerButton;
@property (weak, nonatomic) IBOutlet UIImageView *bottomHand;
@property (weak, nonatomic) IBOutlet UIImageView *topHand;
@property (strong, nonatomic) UIButton *multiplayerButton;
@end

@implementation MultiplayerGameViewController {
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    float maxTime;
    float maxScore;
    float timeElapsed;
    CGRect screenBounds;
    BOOL startButtonTopPressed;
    BOOL startButtonBottomPressed;
    NSUInteger startGameCount;
    BOOL topUserWon;
    BOOL gameInProgress;
    NSUInteger gamesWonTopUser;
    NSUInteger gamesWonBottomUser;
    NSUInteger selectedChapter;
    NSUInteger selectedGame;
}

#pragma mark - Lazy Instantiation

-(NSMutableArray *)columnsButtonsArray {
    if (!_columnsButtonsArray) {
        _columnsButtonsArray = [[NSMutableArray alloc] init];
    }
    return _columnsButtonsArray;
}

-(NSMutableArray *)columnsButtonsArray2 {
    if (!_columnsButtonsArray2) {
        _columnsButtonsArray2 = [[NSMutableArray alloc] init];
    }
    return _columnsButtonsArray2;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    gamesWonBottomUser = 0;
    gamesWonTopUser = 0;
    startGameCount = 3;
    selectedChapter = arc4random()%4;
    selectedGame = arc4random()%9;
    screenBounds = [UIScreen mainScreen].bounds;
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[selectedChapter][selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[selectedChapter][selectedGame][@"maxNumber"] intValue];
    
    [self setupUI];
    [self initGame];
}

-(void)setupUI {
    //Bottom and top side views
    NSUInteger rand1 = arc4random()%5;
    NSUInteger rand2 = rand1;
    while (rand2 == rand1) {
        rand2 = arc4random()%5;
    }
    
    self.topSideVIew.backgroundColor = [[AppInfo sharedInstance] appColorsArray][rand1];
    self.bottomSideView.backgroundColor = [[AppInfo sharedInstance] appColorsArray][rand2];
    
    //Game won labels
    self.gamesWonTopLabel.transform = CGAffineTransformMakeRotation(M_PI);
    
    //COunter Label
    self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 250.0, screenBounds.size.height/2.0 - 100.0, 500.0, 200.0)];
    self.counterLabel.text = @"3";
    self.counterLabel.textColor = [UIColor whiteColor];
    self.counterLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:160.0];
    self.counterLabel.hidden = YES;
    self.counterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.counterLabel];
    
    //Start button bottom
    self.startButtonBottom = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButtonBottom.tag = 2;
    self.startButtonBottom.frame = CGRectMake(screenBounds.size.width - 120.0, screenBounds.size.height - 80.0, 90.0, 50.0);
    [self.startButtonBottom setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButtonBottom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButtonBottom.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0];
    [self.startButtonBottom addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.startButtonBottom addTarget:self action:@selector(startButtonUnpressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButtonBottom addTarget:self action:@selector(startButtonUnpressed:) forControlEvents:UIControlEventTouchUpOutside];
    self.startButtonBottom.layer.cornerRadius = 4.0;
    self.startButtonBottom.layer.borderWidth = 1.0;
    self.startButtonBottom.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.startButtonBottom];
    
    //Start button top
    self.startButtonTop = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButtonTop.tag = 1;
    self.startButtonTop.layer.cornerRadius = 4.0;
    self.startButtonTop.layer.borderWidth = 1.0;
    self.startButtonTop.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.startButtonTop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButtonTop.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0];
    self.startButtonTop.transform = CGAffineTransformMakeRotation(M_PI);
    self.startButtonTop.frame = CGRectMake(30.0, 30.0, 90.0, 50.0);
    [self.startButtonTop setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButtonTop addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.startButtonTop addTarget:self action:@selector(startButtonUnpressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.startButtonTop addTarget:self action:@selector(startButtonUnpressed:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:self.startButtonTop];
    
    //Another Game BUtton
    UIButton *anotherGameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    anotherGameButton.frame = CGRectMake(30.0, screenBounds.size.height/2.0 + 30, 150.0, 50.0);
    [anotherGameButton setTitle:@"New Game" forState:UIControlStateNormal];
    [anotherGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    anotherGameButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0];
    anotherGameButton.layer.borderColor = [UIColor whiteColor].CGColor;
    anotherGameButton.layer.borderWidth = 1.0;
    anotherGameButton.layer.cornerRadius = 4.0;
    [anotherGameButton addTarget:self action:@selector(startRandomGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:anotherGameButton];
    
    //Back Button
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(30.0, screenBounds.size.height - 80.0, 90.0, 50.0);
    self.backButton.layer.cornerRadius = 4.0;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0];
    [self.backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    //Buttons Container views
    self.buttonsContainerView = [[UIView alloc] init];
    self.buttonsContainerView.alpha = 0.4;
    self.buttonsContainerView.userInteractionEnabled = NO;
    [self.view addSubview:self.buttonsContainerView];
    
    self.buttonsContainerView2 = [[UIView alloc] init];
    self.buttonsContainerView2.alpha = 0.4;
    self.buttonsContainerView2.userInteractionEnabled = NO;
    [self.view addSubview:self.buttonsContainerView2];
    
    //Hands
    self.bottomHand.transform = CGAffineTransformMakeRotation(M_PI);
    [self animateHands];
}

-(void)animateHands {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.bottomHand.center = CGPointMake(self.bottomHand.center.x, 360.0);
                         self.topHand.center = CGPointMake(self.topHand.center.x, 150.0);
                     } completion:^(BOOL success){
                         [self animateHandsSecondStep];
                     }];
}

-(void)animateHandsSecondStep {
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.bottomHand.center = CGPointMake(self.bottomHand.center.x, 380.0);
                         self.topHand.center = CGPointMake(self.topHand.center.x, 130.0);
                     } completion:^(BOOL success){
                         [self animateHands];
                     }];
}

-(void)initGame {
    [self resetGame];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    self.pointsArray = chaptersDataArray[selectedChapter][selectedGame][@"puntos"];
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        [self addOneToButtonAtRow:row column:column];
    }
}

-(void)addOneToButtonAtRow:(NSInteger)row column:(NSInteger)column {
    NSString *buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row]];
    [self.columnsButtonsArray[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    [self.columnsButtonsArray2[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row + 1]];
        [self.columnsButtonsArray[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray2[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column][row - 1]];
        [self.columnsButtonsArray[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray2[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column - 1][row]];
        [self.columnsButtonsArray[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray2[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self getNewValueForButton:self.columnsButtonsArray[column + 1][row]];
        [self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        [self.columnsButtonsArray2[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

-(NSString *)getNewValueForButton:(UIButton *)button {
    NSString *newTitle = [NSString stringWithFormat:@"%i", [button.currentTitle intValue] + 1];
    return newTitle;
}

-(void)resetGame {
    [self.buttonsContainerView2.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.buttonsContainerView.alpha = 0.4;
    self.buttonsContainerView.userInteractionEnabled = NO;
    self.buttonsContainerView2.alpha = 0.4;
    self.buttonsContainerView2.userInteractionEnabled = NO;
    
    [self.columnsButtonsArray removeAllObjects];
    [self.columnsButtonsArray2 removeAllObjects];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    if (selectedGame >= [chaptersDataArray[selectedChapter] count]) {
        selectedChapter += 1;
        self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][selectedChapter];
        selectedGame = 0;
    }
    matrixSize = [chaptersDataArray[selectedChapter][selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[selectedChapter][selectedGame][@"maxNumber"] intValue];
    maxScore = [chaptersDataArray[selectedChapter][selectedGame][@"maxScore"] floatValue];
    maxTime = [chaptersDataArray[selectedChapter][selectedGame][@"maxTime"] floatValue];
    timeElapsed = 0;
    
    if (matrixSize < 5) {
        self.buttonsContainerView.frame = CGRectMake(screenBounds.size.width/2.0 - 150.0, 100.0, 300.0, 300.0);
        self.buttonsContainerView2.frame = CGRectMake(screenBounds.size.width/2.0 - 150.0, screenBounds.size.height/2.0 + 100.0, 300.0, 300.0);

    } else {
        self.buttonsContainerView.frame = CGRectMake(screenBounds.size.width/2.0 - 200.0, 60.0, 400.0, 400.0);
        self.buttonsContainerView2.frame = CGRectMake(screenBounds.size.width/2.0 - 200.0, screenBounds.size.height/2.0 + 60.0, 400.0, 400.0);
    }
    
    [self createSquareMatrixOf:matrixSize];
    
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            [self.columnsButtonsArray[i][j] setTitle:@"0" forState:UIControlStateNormal];
            [self.columnsButtonsArray2[i][j] setTitle:@"0" forState:UIControlStateNormal];
            CGPoint originalButtonCenter = [self.columnsButtonsArray[i][j] center];
            CGPoint originalButtonCenter2 = [self.columnsButtonsArray2[i][j] center];
            CGPoint randomCenter = CGPointMake(arc4random()%1000, arc4random()%500);
            [self.columnsButtonsArray[i][j] setCenter:randomCenter];
            [self.columnsButtonsArray2[i][j] setCenter:randomCenter];
            [UIView animateWithDuration:0.8
                                  delay:0.0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(){
                                 [self.columnsButtonsArray[i][j] setCenter:originalButtonCenter];
                                 [self.columnsButtonsArray2[i][j] setCenter:originalButtonCenter2];
                             } completion:^(BOOL finished){}];
            
        }
    }
}

-(void)createSquareMatrixOf:(NSUInteger)size {
    NSUInteger fontSize = 0;
    NSUInteger buttonDistance;
    NSUInteger cornerRadius;
    buttonDistance = 20.0;
    cornerRadius = 10.0;
    
    if (matrixSize == 3) fontSize = 60.0;
    else if (matrixSize == 4) fontSize = 40.0;
    else if (matrixSize == 5) fontSize = 40.0;
    else if (matrixSize == 6) fontSize = 30.0;
    
    NSUInteger buttonSize = (self.buttonsContainerView.frame.size.width - ((matrixSize + 1)*buttonDistance)) / matrixSize;
    NSLog(@"Tamaño del boton: %d", buttonSize);
    
    int h = 1000;
    for (int i = 0; i < size; i++) {
        NSMutableArray *filaButtonsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < size; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = cornerRadius;
            button.backgroundColor = [UIColor whiteColor];
            button.frame = CGRectMake(buttonDistance + (i*buttonSize + buttonDistance*i), buttonDistance + (j*buttonSize + buttonDistance*j), buttonSize, buttonSize);
            [button setTitle:@"0" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontSize];
            [button addTarget:self action:@selector(topNumberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = h;
            [self.buttonsContainerView addSubview:button];
            [filaButtonsArray addObject:button];
            h+=1;
        }
        [self.columnsButtonsArray addObject:filaButtonsArray];
    }
    
    ///////////////////////////////////////////////////////////
    h = 2000;
    for (int i = 0; i < size; i++) {
        NSMutableArray *filaButtonsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < size; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = cornerRadius;
            button.backgroundColor = [UIColor whiteColor];
            button.frame = CGRectMake(buttonDistance + (i*buttonSize + buttonDistance*i), buttonDistance + (j*buttonSize + buttonDistance*j), buttonSize, buttonSize);
            [button setTitle:@"0" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:fontSize];
            [button addTarget:self action:@selector(bottomNumberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = h;
            [self.buttonsContainerView2 addSubview:button];
            [filaButtonsArray addObject:button];
            h+=1;
        }
        [self.columnsButtonsArray2 addObject:filaButtonsArray];
    }
    self.buttonsContainerView.transform = CGAffineTransformMakeRotation(M_PI);
}

#pragma mark - Actions

-(void)startRandomGame {
    [self prepareNextGame];
}

-(void)startButtonUnpressed:(UIButton *)button {
    self.counterLabel.hidden = YES;
    self.counterLabel.text = @"3";
    
    if (button.tag == 1) {
        startButtonTopPressed = NO;
    } else if (button.tag == 2) {
        startButtonBottomPressed = NO;
    }
    
    if (!gameInProgress) {
        self.topHand.hidden = NO;
        self.bottomHand.hidden = NO;
    }
    
    //Invalidate Timer
    [self.startGameTimer invalidate];
    self.startGameTimer = nil;
    
    startGameCount = 3;
}

-(void)startButtonPressed:(UIButton *)button {
    if (button.tag == 1) {
        startButtonTopPressed = YES;
        self.topHand.hidden = YES;
    } else if (button.tag == 2) {
        startButtonBottomPressed = YES;
        self.bottomHand.hidden = YES;
    }
    
    if (startButtonBottomPressed && startButtonTopPressed && self.buttonsContainerView.userInteractionEnabled == NO) {
        //Start timer
        self.counterLabel.hidden = NO;
        self.startGameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    }
}

-(void)countDown {
    static float count = 1.0;
    self.counterLabel.transform = CGAffineTransformMakeRotation(M_PI * count);
    
    startGameCount--;
    NSLog(@"Start game count: %d", startGameCount);
    
    if (startGameCount <= 0) {
        NSLog(@"Game begins!!!");
        self.counterLabel.text = @"Start!";
        self.buttonsContainerView2.alpha = 1.0;
        self.buttonsContainerView2.userInteractionEnabled = YES;
        self.buttonsContainerView.alpha = 1.0;
        self.buttonsContainerView.userInteractionEnabled = YES;
        [self.startGameTimer invalidate];
        self.startGameTimer = nil;
        gameInProgress = YES;
        
    } else {
        self.counterLabel.text = [NSString stringWithFormat:@"%d", startGameCount];
    }
    
    count++;
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)topNumberButtonPressed:(UIButton *)numberButton {
    NSLog(@"Oprimí el boton con tag %d", numberButton.tag);
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
    [self checkIfTopUserWon];
}

-(void)bottomNumberButtonPressed:(UIButton *)numberButton {
    NSLog(@"Oprimí el boton con tag %d", numberButton.tag);
    NSUInteger index = numberButton.tag - 2000;
    NSInteger column = index / matrixSize;
    NSInteger row = index % matrixSize;
    
    NSString *buttonTitle = [self substractOneForButton:self.columnsButtonsArray2[column][row]];
    [self.columnsButtonsArray2[column][row] setTitle:buttonTitle forState:UIControlStateNormal];
    
    if (row + 1 < matrixSize) {
        //Down Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray2[column][row + 1]];
        [self.columnsButtonsArray2[column][row + 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (row - 1 >= 0) {
        //Up Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray2[column][row - 1]];
        [self.columnsButtonsArray2[column][row - 1] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column - 1 >= 0) {
        //Left button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray2[column - 1][row]];
        [self.columnsButtonsArray2[column - 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    
    if (column + 1 < matrixSize) {
        //Right Button
        buttonTitle = [self substractOneForButton:self.columnsButtonsArray2[column + 1][row]];
        [self.columnsButtonsArray2[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
    }
    [self checkIfBottomUserWon];
}

-(NSString *)substractOneForButton:(UIButton *)button {
    NSInteger newbuttonValue = [button.currentTitle intValue] - 1;
    if (newbuttonValue < 0) {
        newbuttonValue = maxNumber;
    }
    return [NSString stringWithFormat:@"%i", newbuttonValue];
}

-(void)checkIfBottomUserWon {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            NSString *buttonValue = [self.columnsButtonsArray2[i][j] currentTitle];
            if (![buttonValue isEqualToString:@"0"]) {
                return;
            }
        }
    }
    topUserWon = NO;
    [self userWon];
    //[self performSelector:@selector(userWon) withObject:nil afterDelay:0.3];
}

-(void)checkIfTopUserWon {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            NSString *buttonValue = [self.columnsButtonsArray[i][j] currentTitle];
            if (![buttonValue isEqualToString:@"0"]) {
                return;
            }
        }
    }
    topUserWon = YES;
    [self userWon];
}

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

-(void)updateUI {
    if (topUserWon) {
        gamesWonTopUser++;
        self.gamesWonTopLabel.text = [NSString stringWithFormat:@"Games Won: %d", gamesWonTopUser];
    } else {
        gamesWonBottomUser++;
        self.gamesWonBottomLabel.text = [NSString stringWithFormat:@"Games Won: %d", gamesWonBottomUser];
    }
}

-(void)userWon {
    [self updateUI];
    if (topUserWon) {
        MultiplayerWinAlert *winAlert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, 200.0, 250.0, 150.0)];
        winAlert.delegate = self;
        [winAlert showAlertInView:self.view];
        winAlert.transform = CGAffineTransformMakeRotation(M_PI);

    } else {
        MultiplayerWinAlert *winAlert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, 700.0, 250.0, 150.0)];
        winAlert.delegate = self;
        [winAlert showAlertInView:self.view];
    }
    
    //[[[UIAlertView alloc] initWithTitle:@"Game Won!" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
}

#pragma mark - GameWonAlert

-(void)gameWonAlertDidApper:(GameWonAlert *)gameWonAlert {
    //[self showFlurryAds];
}

-(void)facebookButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    //[self shareScoreOnSocialNetwork:@"facebook"];
}

-(void)challengeButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    //[self challengeFriends];
}

-(void)twitterButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    //[self shareScoreOnSocialNetwork:@"twitter"];
}

-(void)continueButtonPressedInAlert:(GameWonAlert *)gameWonAlert {
    NSLog(@"Presioné el botón de continuar");
    [self prepareNextGame];
}

-(void)gameWonAlertDidDissapear:(GameWonAlert *)gameWonAlert {

}

-(void)prepareNextGame {
    gameInProgress = NO;
    self.topHand.hidden = NO;
    self.bottomHand.hidden = NO;
    
    selectedGame = arc4random()%9;
    selectedChapter = arc4random()%4;
    [self initGame];
}

#pragma mark - UIAlertViewDelegate 

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //[self prepareNextGame];
}

#pragma mark - MultiplayerWinAlertDelegate

-(void)acceptButtonPressedInWinAlert:(MultiplayerWinAlert *)winAlert {
    //[self prepareNextGame];
}

-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert {
    winAlert = nil;
    [self prepareNextGame];
}

@end
