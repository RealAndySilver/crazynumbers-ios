//
//  ChaptersViewController.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ChaptersViewController.h"
#import "ChaptersCell.h"
#import "GameViewController.h"
#import "AppInfo.h"
#import "FileSaver.h"
#import "MultiplayerGameViewController.h"
#import "Score+AddOns.h"
#import "MultiplayerWinAlert.h"
#import "AudioPlayer.h"
@import AVFoundation;

@interface ChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate, MultiplayerWinAlertDelegate>
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@property (strong, nonatomic) NSArray *chaptersGamesFinishedArray;
@property (strong, nonatomic) NSArray *gamesDataArray;
@property (strong, nonatomic) NSMutableArray *coreDataScores;
@property (strong, nonatomic) AVAudioPlayer *backSoundPlayer;
@property (strong, nonatomic) AVAudioPlayer *buttonPressedPlayer;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"
#define DOCUMENT_NAME @"MyDocument";

@implementation ChaptersViewController {
    CGRect screenBounds;
    NSUInteger numberOfChapters;
    NSUInteger selectedGame;
    BOOL isPad;
}

#pragma mark - Lazy Instantiation 

/*-(NSMutableArray *)coreDataScores {
    if (!_coreDataScores) {
        _coreDataScores = [[NSMutableArray alloc] init];
        for (int i = 0; i < numberOfChapters; i++) {
            NSMutableArray *chapterScoresArray = [[NSMutableArray alloc] init];
            for (int j = 0; j < 9; j++) {
                [chapterScoresArray addObject:@(0)];
            }
            [_coreDataScores addObject:chapterScoresArray];
        }
    }
    return _coreDataScores;
}*/

/*-(NSURL *)databaseDocumentURL {
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
}*/

-(NSArray *)gamesDataArray {
    if (!_gamesDataArray) {
        NSString *scoresFilePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
        _gamesDataArray = [NSArray arrayWithContentsOfFile:scoresFilePath];
    }
    return _gamesDataArray;
}

-(NSArray *)chaptersGamesFinishedArray {
    if (!_chaptersGamesFinishedArray) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        _chaptersGamesFinishedArray = [fileSaver getDictionary:@"NumberChaptersDic"][@"NumberChaptersArray"];
    }
    return _chaptersGamesFinishedArray;
}

-(NSArray *)chaptersNamesArray {
    if (!_chaptersNamesArray) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ChapterNames" ofType:@"plist"];
        _chaptersNamesArray = [NSArray arrayWithContentsOfFile:filePath];
    }
    return _chaptersNamesArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) isPad = YES;
    else isPad = NO;
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    numberOfChapters = [chaptersArray count];
    
    /*if (isPad) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scoreUpdatedNotificationReceived:) name:@"ScoreUpdatedNotification" object:nil];
        [self openCoreDataDocument];
    }*/
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWonNotificationReceived:)
                                                 name:@"GameWonNotification"
                                               object:nil];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
    [self setupSounds];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Animate CollectionView
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.collectionView.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width + 200.0), 0.0);
                     } completion:^(BOOL finished){}];
}

-(void)setupUI {
    //Setup CollectionViewFlowLayout
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.itemSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
    
    //Setup CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(screenBounds.size.width + 200.0, 0.0, screenBounds.size.width, screenBounds.size.height) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[ChaptersCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Setup PageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 100.0, screenBounds.size.height - (screenBounds.size.height/4.93), 200.0, 30.0)];
    self.pageControl.userInteractionEnabled = NO;
    self.pageControl.numberOfPages = numberOfChapters;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.view addSubview:self.pageControl];
    
    //Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, screenBounds.size.height - 57.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 10.0;
    backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

-(void)setupSounds {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"buttonpress" ofType:@"wav"];
    NSURL *soundFIleURL = [NSURL URLWithString:soundFilePath];
    self.buttonPressedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFIleURL error:nil];
    [self.buttonPressedPlayer prepareToPlay];
    
    soundFilePath = nil;
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"wav"];
    soundFIleURL = nil;
    soundFIleURL = [NSURL URLWithString:soundFilePath];
    self.backSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFIleURL error:nil];
    [self.backSoundPlayer prepareToPlay];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfChapters;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Index path %d", indexPath.item);
    ChaptersCell *cell = (ChaptersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
    cell.chapterNameLabel.text = self.chaptersNamesArray[indexPath.item];
    cell.chapterNameLabel.textColor = [UIColor whiteColor];
    cell.delegate = self;
    NSLog(@"juegos ganados en este capítulo: %d", [self.chaptersGamesFinishedArray[indexPath.item] count]);
    NSArray *gamesFinishedArray = self.chaptersGamesFinishedArray[indexPath.item];
    
    if ([gamesFinishedArray containsObject:@1]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][0] intValue],[self.gamesDataArray[indexPath.item][0][@"maxScore"] intValue]];
        //cell.label1.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        //cell.label1.text = labelString;
        cell.button1.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button1.backgroundColor = [UIColor whiteColor];
        [cell.button1 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];

    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][0][@"maxScore"] intValue]];
        //cell.label1.text = labelString;
        //cell.label1.textColor = [UIColor whiteColor];
        cell.button1.backgroundColor = [UIColor clearColor];
        cell.button1.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@2]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][1] intValue],[self.gamesDataArray[indexPath.item][1][@"maxScore"] intValue]];
        //cell.label2.text = labelString;
        //cell.label2.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button2.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button2.backgroundColor = [UIColor whiteColor];
        [cell.button2 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][1][@"maxScore"] intValue]];
        //cell.label2.text = labelString;
        //cell.label2.textColor = [UIColor whiteColor];
        cell.button2.backgroundColor = [UIColor clearColor];
        cell.button2.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@3]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][2] intValue],[self.gamesDataArray[indexPath.item][2][@"maxScore"] intValue]];
        //cell.label3.text = labelString;
        //cell.label3.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button3.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button3.backgroundColor = [UIColor whiteColor];
        [cell.button3 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][2][@"maxScore"] intValue]];
        //cell.label3.text = labelString;
        //cell.label3.textColor = [UIColor whiteColor];
        cell.button3.backgroundColor = [UIColor clearColor];
        cell.button3.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@4]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][3] intValue],[self.gamesDataArray[indexPath.item][3][@"maxScore"] intValue]];
        //cell.label4.text = labelString;
        //cell.label4.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button4.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button4.backgroundColor = [UIColor whiteColor];
        [cell.button4 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][3][@"maxScore"] intValue]];
        //cell.label4.text = labelString;
        //cell.label4.textColor = [UIColor whiteColor];
        cell.button4.backgroundColor = [UIColor clearColor];
        cell.button4.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@5]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][4] intValue],[self.gamesDataArray[indexPath.item][4][@"maxScore"] intValue]];
        //cell.label5.text = labelString;
        //cell.label5.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button5.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button5.backgroundColor = [UIColor whiteColor];
        [cell.button5 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][4][@"maxScore"] intValue]];
        //cell.label5.text = labelString;
        //cell.label5.textColor = [UIColor whiteColor];
        cell.button5.backgroundColor = [UIColor clearColor];
        cell.button5.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@6]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][5] intValue],[self.gamesDataArray[indexPath.item][5][@"maxScore"] intValue]];
        //cell.label6.text = labelString;
        //cell.label6.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button6.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button6.backgroundColor = [UIColor whiteColor];
        [cell.button6 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][5][@"maxScore"] intValue]];
        //cell.label6.text = labelString;
        //cell.label6.textColor = [UIColor whiteColor];
        cell.button6.backgroundColor = [UIColor clearColor];
        cell.button6.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button6 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@7]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][6] intValue],[self.gamesDataArray[indexPath.item][6][@"maxScore"] intValue]];
        //cell.label7.text = labelString;
        //cell.label7.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button7.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button7.backgroundColor = [UIColor whiteColor];
        [cell.button7 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][6][@"maxScore"] intValue]];
        //cell.label7.text = labelString;
        //cell.label7.textColor = [UIColor whiteColor];
        cell.button7.backgroundColor = [UIColor clearColor];
        cell.button7.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button7 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@8]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][7] intValue],[self.gamesDataArray[indexPath.item][7][@"maxScore"] intValue]];
        //cell.label8.text = labelString;
        //cell.label8.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button8.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button8.backgroundColor = [UIColor whiteColor];
        [cell.button8 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][7][@"maxScore"] intValue]];
        //cell.label8.text = labelString;
        //cell.label8.textColor = [UIColor whiteColor];
        cell.button8.backgroundColor = [UIColor clearColor];
        cell.button8.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button8 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@9]) {
        //NSString *labelString = [NSString stringWithFormat:@"Score: %d/%d", [self.coreDataScores[indexPath.item][8] intValue],[self.gamesDataArray[indexPath.item][8][@"maxScore"] intValue]];
        //cell.label9.text = labelString;
        //cell.label9.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button9.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button9.backgroundColor = [UIColor whiteColor];
        [cell.button9 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        //NSString *labelString = [NSString stringWithFormat:@"Score: 0/%d", [self.gamesDataArray[indexPath.item][8][@"maxScore"] intValue]];
        //cell.label9.text = labelString;
        //cell.label9.textColor = [UIColor whiteColor];
        cell.button9.backgroundColor = [UIColor clearColor];
        cell.button9.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button9 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - Sounds 

-(void)playButtonPressedSound {
    [self.buttonPressedPlayer stop];
    self.buttonPressedPlayer.currentTime = 0;
    [self.buttonPressedPlayer play];
}

-(void)playBackSound {
    [self.backSoundPlayer stop];
    self.backSoundPlayer.currentTime = 0;
    [self.backSoundPlayer play];
}

#pragma mark - Actions 

-(void)dismissVC {
    [[AudioPlayer sharedInstance] playBackSound];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayMusicNotification" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goToGameVCWithSelectedGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    GameViewController *gameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Game"];
    gameVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    gameVC.selectedChapter = chapter;
    gameVC.selectedGame = game;
    [self presentViewController:gameVC animated:YES completion:nil];
}

-(BOOL)checkIfUserCanPlayGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSArray *chaptersArray = [fileSaver getDictionary:@"NumberChaptersDic"][@"NumberChaptersArray"];
    if (chaptersArray) {
        NSLog(@"Existe el dic de capítulos");
        NSArray *chapterGamesArray = chaptersArray[chapter];
        if (chapterGamesArray) {
            NSLog(@"Existe e array de chapter");
            if ([chapterGamesArray containsObject:@(game)]) {
                NSLog(@"El usuario puede jugar este juego");
                return YES;
            } else {
                NSLog(@"El usuario no puede jugar");
                return  NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - CoreData

/*-(void)openCoreDataDocument {
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self.databaseDocumentURL path]];
    if (fileExist) {
        //Open the database document
        [self.databaseDocument openWithCompletionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Abrí el documento de core data");
                [self getCurrentScoresInCoreData];
            } else {
                NSLog(@"Error opening the document");
            }
        }];
    } else {
        //The database document did not exist, so create it.
        [self.databaseDocument saveToURL:self.databaseDocumentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                NSLog(@"Abrí el documento de core data");
                [self getCurrentScoresInCoreData];
            } else {
                NSLog(@"Error opening the document");
            }
        }];
    }
}

-(void)getCurrentScoresInCoreData {
    [self.coreDataScores removeAllObjects];
    
    if (self.databaseDocument.documentState == UIDocumentStateNormal) {
        //Get user scores
        
        NSManagedObjectContext *context = self.databaseDocument.managedObjectContext;
        NSArray *scores = [Score getAllScoresWithType:@"numbers" inManagedObjectContext:context];
        Score *lastGameUnlockesScore = [scores lastObject];
        //NSUInteger chapters = (int)[lastGameUnlockesScore.identifier intValue]/9;
        NSUInteger chapters = numberOfChapters;
        NSUInteger totalGames = (chapters+1)*9;
        for (int i = 0; i <= chapters; i++) {
            NSLog(@"**************************** CAPITULO %d *********************", i);
            NSMutableArray *chapterScores = [[NSMutableArray alloc] init];
            
            for (int j = 0; j < totalGames; j++) {
                if (j < [scores count]) {
                    Score *score = scores[j];
                    NSUInteger chapterForScore = 0;
                    NSLog(@"Score for game with id %@: %@", score.identifier, score.value);
                    if ([score.identifier intValue]%9 == 0) {
                        NSLog(@"This game is in chapter %d", (int)[score.identifier intValue]/9 - 1);
                        chapterForScore = ((int)[score.identifier intValue]/9) - 1;
                    } else {
                        NSLog(@"This game is in chapter %d", (int)[score.identifier intValue]/9);
                        chapterForScore = (int)[score.identifier intValue]/9;
                    }
                    if (chapterForScore == i) {
                        NSLog(@"Agregaré este juego al capítulo %d", i);
                        [chapterScores addObject:score.value];
                    } else {
                        NSLog(@"No agregué este puntaje al capitulo %d porque el chapterForScore es %d", i, chapterForScore);
                    }
                } else {
                    [chapterScores addObject:@0];
                }
            }
            [self.coreDataScores addObject:chapterScores];
        }
        for (int i = 0; i < [self.coreDataScores count]; i++) {
            NSArray *scoresForChapter = self.coreDataScores[i];
            for (int j = 0; j < [scoresForChapter count]; j++) {
                NSLog(@"Score para el juego %d del capítulo %d: %d", j, i, [scoresForChapter[j] intValue]);
            }
        }
        
        [self.collectionView reloadData];
    }
}*/

#pragma mark - UIScrollViewViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = currentPage;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger pageWidth = self.view.bounds.size.width;
    if (scrollView.contentOffset.x < 0) {
        self.view.backgroundColor = [[[AppInfo sharedInstance] appColorsArray] firstObject];
    } else if (scrollView.contentOffset.x > pageWidth*3) {
        self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    }
}

#pragma mark - ChaptersCellDelegate

-(void)chaptersCellDidSelectGame:(NSUInteger)game {
    [self playButtonPressedSound];
    
    BOOL userCanPlayGame = [self checkIfUserCanPlayGame:game + 1 inChapter:self.pageControl.currentPage];
    NSLog(@"Se seleccionó el juego %d", game);
    if (userCanPlayGame) {
        selectedGame = game;
        [self goToGameVCWithSelectedGame:game inChapter:self.pageControl.currentPage];

    } else {
        MultiplayerWinAlert *alert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, self.view.bounds.size.height/2.0 - 75.0, 250.0, 150.0)];
        alert.alertMessage = @"Oops! You haven't unlocked this game yet!";
        alert.messageTextSize = 15.0;
        alert.acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][self.pageControl.currentPage];
        alert.delegate = self;
        [alert showAlertInView:self.view];
    }
}

#pragma mark - MultiplayerWinAlertDelegate

-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert {
    winAlert = nil;
}

-(void)acceptButtonPressedInWinAlert:(MultiplayerWinAlert *)winAlert {
    
}

#pragma mark - Notification Handlers

/*-(void)scoreUpdatedNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificaion de puntaje actualizado");
    [self getCurrentScoresInCoreData];
}*/

-(void)gameWonNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificación de juego ganado");
    //Get the won games in file saver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    self.chaptersGamesFinishedArray = [fileSaver getDictionary:@"NumberChaptersDic"][@"NumberChaptersArray"];
    [self.collectionView reloadData];
}

@end
