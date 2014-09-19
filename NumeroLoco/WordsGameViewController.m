//
//  WordsGameViewController.m
//  NumeroLoco
//
//  Created by Developer on 18/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "WordsGameViewController.h"
#import "AppInfo.h"
#import "FlurryAds.h"
#import "Flurry.h"
#import "FileSaver.h"
#import "GameWonAlert.h"

@interface WordsGameViewController ()
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray; //Of UIButton
@property (strong, nonatomic) NSArray *wordsArray;
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) UILabel *numberOfTapsLabel;
@property (strong, nonatomic) UILabel *maxTapsLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *resetButton;
@end

#define FONT_NAME @"HelveticaNeue-Light"

@implementation WordsGameViewController {
    CGRect screenBounds;
    NSUInteger numberOfTaps;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
    BOOL isPad;
}

#pragma mark - Lazy Instantiation

-(NSArray *)wordsArray {
    if (!_wordsArray) {
        _wordsArray = [[AppInfo sharedInstance] wordsArray];
        NSLog(@"Words Array: %@", _wordsArray);
    }
    return _wordsArray;
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
    } else {
        isPad = NO;
    }
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"WordsGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][self.selectedChapter];
    screenBounds = [UIScreen mainScreen].bounds;
    NSLog(@"Seleccioné el juego %lu en el capítulo %lu", (unsigned long)self.selectedGame, (unsigned long)self.selectedChapter);
    [self setupUI];
    NSLog(@"Tamaño de la matriz: %lu", (unsigned long)matrixSize);
    //[self createSquareMatrixOf:matrixSize];
    [self initGame];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FlurryAds setAdDelegate:self];
    [FlurryAds fetchAndDisplayAdForSpace:@"GAME_TOP_BANNER" view:self.view size:BANNER_TOP];
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
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 40.0, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            } else {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/8.11, screenBounds.size.width, 40.0)];
                self.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
            }
        }
        labelsFontSize = 18.0;
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %lu - Game %lu", self.selectedChapter + 1, self.selectedGame + 1];
    self.titleLabel.textColor = [UIColor whiteColor];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    //Back Button
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0);
    self.backButton.layer.cornerRadius = 4.0;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    //Reset Button
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(screenBounds.size.width - 90, screenBounds.size.height - 60.0, 70.0, 40.0);
    self.resetButton.layer.cornerRadius = 4.0;
    self.resetButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.resetButton.layer.borderWidth = 1.0;
    [self.resetButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.resetButton addTarget:self action:@selector(initGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
    
    //Number of taps label
    self.numberOfTapsLabel.text = @"Number of taps: 0";
    self.numberOfTapsLabel.textAlignment = NSTextAlignmentCenter;
    self.numberOfTapsLabel.textColor = [UIColor whiteColor];
    self.numberOfTapsLabel.font = [UIFont fontWithName:FONT_NAME size:labelsFontSize];
    [self.view addSubview:self.numberOfTapsLabel];
    
    //Max taps label
    self.maxTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 150.0, self.numberOfTapsLabel.frame.origin.y + self.numberOfTapsLabel.frame.size.height, 300.0, 20.0)];
    self.maxTapsLabel.textColor = [UIColor whiteColor];
    self.maxTapsLabel.textAlignment = NSTextAlignmentCenter;
    self.maxTapsLabel.font = [UIFont fontWithName:FONT_NAME size:labelsFontSize];
    [self.view addSubview:self.maxTapsLabel];
    
    //Buttons container view
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"WordsGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    
    /*self.buttonsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, screenBounds.size.height/5.68, matrixSize*53.33333, matrixSize*53.33333)];
     self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);*/
    self.buttonsContainerView = [[UIView alloc] init];
    [self.view addSubview:self.buttonsContainerView];
}

-(void)resetGame {
    
    [self.buttonsContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.columnsButtonsArray removeAllObjects];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"WordsGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    if (self.selectedGame >= [chaptersDataArray[self.selectedChapter] count]) {
        self.selectedChapter += 1;
        self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][self.selectedChapter];
        self.selectedGame = 0;
    }
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    
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
}

-(void)initGame {
    [self resetGame];
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %lu - Game %lu", self.selectedChapter + 1, self.selectedGame + 1];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"WordsGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    self.pointsArray = chaptersDataArray[self.selectedChapter][self.selectedGame][@"puntos"];
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSUInteger row = [self.pointsArray[i][@"fila"] intValue] - 1;
        NSUInteger column = [self.pointsArray[i][@"columna"] intValue] - 1;
        [self addOneToButtonAtRow:row column:column];
        //NSUInteger buttonTag = [self tagForButtonAtRow:row column:column];
        //[self addOneToButtonWithTag:buttonTag];
    }
    self.maxTapsLabel.text = [NSString stringWithFormat:@"Taps for perfect score: %lu", (unsigned long)[self.pointsArray count]];
    self.numberOfTapsLabel.text = @"Number of taps: 0";
    numberOfTaps = 0;
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
    //NSString *newTitle = [NSString stringWithFormat:@"%i", [button.currentTitle intValue] + 1];
    //return newTitle;
    NSString *buttonTitle = button.titleLabel.text;
    NSUInteger currentTitleIndex;
    for (int i = 0; i < [self.wordsArray count]; i++) {
        NSString *word = self.wordsArray[i];
        if ([buttonTitle isEqualToString:word]) {
            currentTitleIndex = i;
            break;
        }
    }
    NSString *nextWord = self.wordsArray[currentTitleIndex + 1];
    return nextWord;
}

-(NSString *)substractOneForButton:(UIButton *)button {
    /*NSInteger newbuttonValue = [button.currentTitle intValue] - 1;
    if (newbuttonValue < 0) {
        newbuttonValue = maxNumber;
    }
    return [NSString stringWithFormat:@"%i", newbuttonValue];*/
    NSString *buttonTitle = button.titleLabel.text;
    NSUInteger currentTitleIndex;
    for (int i = 0; i < [self.wordsArray count]; i++) {
        NSString *word = self.wordsArray[i];
        if ([buttonTitle isEqualToString:word]) {
            currentTitleIndex = i;
            break;
        }
    }
    
    if (currentTitleIndex == 0) {
        NSString *newString = self.wordsArray[maxNumber];
        return newString;
    } else {
        NSString *newString = self.wordsArray[currentTitleIndex - 1];
        return newString;
    }

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
        cornerRadius = 4.0;
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
            [button setTitle:self.wordsArray[0] forState:UIControlStateNormal];
            if (matrixSize < 5) {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:80.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:10.0];
            } else {
                if (isPad) button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:70.0];
                else button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:10.0];
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
    numberOfTaps += 1;
    [self updateUI];
    [self checkIfUserWon];
}

-(void)updateUI {
    self.numberOfTapsLabel.text = [NSString stringWithFormat:@"Number of taps: %lu", (unsigned long)numberOfTaps];
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
    [self performSelector:@selector(userWon) withObject:nil afterDelay:0.35];
}

-(void)userWon {
    //Send data to Flurry
    [Flurry logEvent:@"WordsGameWon" withParameters:@{@"Chapter" : @(self.selectedChapter), @"Game" : @(self.selectedGame)}];
    
    //Unlock the next game saving the game number with FileSaver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSMutableArray *chaptersArray = [fileSaver getDictionary:@"WordChaptersDic"][@"WordChaptersArray"];
    NSLog(@"Agregando el número %lu a filesaver porque gané", self.selectedGame + 2);
    
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
            [fileSaver setDictionary:@{@"WordChaptersArray" : chaptersArray} withName:@"WordChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WordGameWonNotification" object:nil];
            
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
            [fileSaver setDictionary:@{@"WordChaptersArray" : chaptersArray} withName:@"WordChaptersDic"];
            
            //Post a notification to update the color of the buttons in ChaptersViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WordGameWonNotification" object:nil];
            
        } else {
            NSLog(@"No guardé la info del juego ganado orque el usuario ya lo había ganado");
        }
    }
    
    //[GameWonAlert showInView:self.view];
    [self performSelector:@selector(prepareNextGame) withObject:nil afterDelay:2.5];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareNextGame {
    self.selectedGame += 1;
    [self initGame];
}


@end
