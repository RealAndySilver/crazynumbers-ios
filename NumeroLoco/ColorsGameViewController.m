//
//  ColorsGameViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 20/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ColorsGameViewController.h"
#import "AppInfo.h"

@interface ColorsGameViewController ()
@property (strong, nonatomic) NSMutableArray *columnsButtonsArray; //Of UIButton
@property (strong, nonatomic) UIView *buttonsContainerView;
@property (strong, nonatomic) UILabel *numberOfTapsLabel;
@property (strong, nonatomic) UILabel *maxTapsLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSArray *pointsArray;
@property (strong, nonatomic) NSArray *colorPaletteArray;
@end

#define FONT_NAME @"ArialRoundedMTBold"

@implementation ColorsGameViewController {
    CGRect screenBounds;
    NSUInteger numberOfTaps;
    NSUInteger matrixSize;
    NSUInteger maxNumber;
}

#pragma mark - Lazy Instantiation

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
    screenBounds = [UIScreen mainScreen].bounds;
    NSLog(@"Seleccioné el juego %d en el capítulo %d", self.selectedGame, self.selectedChapter);
    [self setupUI];
    
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    maxNumber = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"maxNumber"] intValue];
    NSLog(@"Tamaño de la matriz: %d", matrixSize);
    [self createSquareMatrixOf:matrixSize];
    [self initGame];
}

-(void)setupUI {
    //Setup MainTitle
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 70.0, screenBounds.size.width, 40.0)];
    self.titleLabel.text = [NSString stringWithFormat:@"Chapter %i - Game %i", self.selectedChapter + 1, self.selectedGame + 1];
    self.titleLabel.textColor = [UIColor lightGrayColor];
    self.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30.0];
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
    backButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15.0];
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
    resetButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:13.0];
    [resetButton addTarget:self action:@selector(initGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    //Number of taps label
    self.numberOfTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, screenBounds.size.height - 135.0, 200.0, 20.0)];
    self.numberOfTapsLabel.text = @"Number of taps: 0";
    self.numberOfTapsLabel.textColor = [UIColor lightGrayColor];
    self.numberOfTapsLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.view addSubview:self.numberOfTapsLabel];
    
    //Max taps label
    self.maxTapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(45.0, screenBounds.size.height - 110.0, 200.0, 20.0)];
    self.maxTapsLabel.textColor = [UIColor lightGrayColor];
    self.maxTapsLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
    [self.view addSubview:self.maxTapsLabel];
    
    //Buttons container view
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersDataArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    matrixSize = [chaptersDataArray[self.selectedChapter][self.selectedGame][@"matrixSize"] intValue];
    
    self.buttonsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 100.0, matrixSize*53.33333, matrixSize*53.33333)];
    self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
    //self.buttonsContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.buttonsContainerView];
}

#pragma mark - Custom Methods

-(void)resetGame {
    
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
    
    //self.buttonsContainerView.frame = CGRectMake(0.0, 100.0, matrixSize*53.33333, matrixSize*53.33333);
    if (matrixSize < 5) {
        self.buttonsContainerView.frame = CGRectMake(35.0, 110.0, screenBounds.size.width - 70.0, screenBounds.size.width - 70.0);
    } else if (matrixSize == 5) {
        self.buttonsContainerView.frame = CGRectMake(10.0, 110.0, screenBounds.size.width - 20.0, screenBounds.size.width - 20.0);
    }
    self.buttonsContainerView.center = CGPointMake(screenBounds.size.width/2.0, screenBounds.size.height/2.0);
    
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
    NSUInteger buttonSize = (self.buttonsContainerView.frame.size.width - ((matrixSize + 1)*10)) / matrixSize;
    NSLog(@"Tamaño del boton: %d", buttonSize);
    
    int h = 1000;
    for (int i = 0; i < size; i++) {
        NSMutableArray *filaButtonsArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < size; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = 4.0;
            //button.layer.borderColor = [UIColor lightGrayColor].CGColor;
            //button.layer.borderWidth = 1.0;
            button.frame = CGRectMake(10 + (i*buttonSize + 10.0*i), 10 + (j*buttonSize + 10*j), buttonSize, buttonSize);
            button.backgroundColor = self.colorPaletteArray[0];
            //[button setTitle:@"0" forState:UIControlStateNormal];
            if (matrixSize < 5) {
                button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
            } else {
                button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
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
       // [self.columnsButtonsArray[column + 1][row] setTitle:buttonTitle forState:UIControlStateNormal];
        
        buttonColor = [self substractColorForButton:self.columnsButtonsArray[column + 1][row]];
        [self.columnsButtonsArray[column + 1][row] setBackgroundColor:buttonColor];
    }
    numberOfTaps += 1;
    [self updateUI];
    [self checkIfUserWon];
}

-(void)updateUI {
    self.numberOfTapsLabel.text = [NSString stringWithFormat:@"Number of taps: %i", numberOfTaps];
}

-(void)checkIfUserWon {
    for (int i = 0; i < matrixSize; i++) {
        for (int j = 0; j < matrixSize; j++) {
            if (![[self.columnsButtonsArray[i][j] backgroundColor] isEqual:[UIColor whiteColor]]) {
                return;
            }
        }
    }
    [self userWon];
}

-(void)userWon {
    [[[UIAlertView alloc] initWithTitle:@"Game Won!" message:@"Congratulations! you have won this game!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.selectedGame += 1;
    [self initGame];
}

@end
