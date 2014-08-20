//
//  ColorsChaptersViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 20/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ColorsChaptersViewController.h"
#import "ColorsGameViewController.h"
#import "ChaptersCell.h"
#import "AppInfo.h"
#import "FileSaver.h"
#import "MultiplayerWinAlert.h"
#import "AudioPlayer.h"
@import AVFoundation;

@interface ColorsChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate, MultiplayerWinAlertDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *colorGamesFinishedArray;
@property (strong, nonatomic) AVAudioPlayer *backSoundPlayer;
@property (strong, nonatomic) AVAudioPlayer *buttonPressedPlayer;
@end

@implementation ColorsChaptersViewController {
    NSUInteger numberOfChapters;
    CGRect screenBounds;
}

#pragma mark - Lazy Instantiation

-(NSArray *)colorGamesFinishedArray {
    if (!_colorGamesFinishedArray) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        _colorGamesFinishedArray = [fileSaver getDictionary:@"ColorChaptersDic"][@"ColorChaptersArray"];
    }
    return _colorGamesFinishedArray;
}

-(NSArray *)chaptersNamesArray {
    if (!_chaptersNamesArray) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ColorsChaptersNames" ofType:@"plist"];
        _chaptersNamesArray = [NSArray arrayWithContentsOfFile:filePath];
    }
    return _chaptersNamesArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWonNotificationReceived:)
                                                 name:@"ColorGameWonNotification"
                                               object:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
    NSArray *chaptersArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    numberOfChapters = [chaptersArray count];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
    [self setupSounds];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Animate CollectionView
    [UIView animateWithDuration:1.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.collectionView.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width + 200.0), 0.0);
                     } completion:^(BOOL finished){}];

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
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:self.pageControl];
    
    //Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 10.0;
    backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return numberOfChapters;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChaptersCell *cell = (ChaptersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.chapterNameLabel.text = self.chaptersNamesArray[indexPath.item];
    cell.chapterNameLabel.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
    cell.buttonsTitleColor = [UIColor whiteColor];
    cell.delegate = self;
    
    NSArray *colorGamesFinished = self.colorGamesFinishedArray[indexPath.item];
    
    if ([colorGamesFinished containsObject:@1]) {
        cell.button1.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button1.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button1.backgroundColor = [UIColor lightGrayColor];
        cell.button1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@2]) {
        cell.button2.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button2.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button2.backgroundColor = [UIColor lightGrayColor];
        cell.button2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@3]) {
        cell.button3.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button3.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button3.backgroundColor = [UIColor lightGrayColor];
        cell.button3.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@4]) {
        cell.button4.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button4.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button4.backgroundColor = [UIColor lightGrayColor];
        cell.button4.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@5]) {
        cell.button5.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button5.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button5.backgroundColor = [UIColor lightGrayColor];
        cell.button5.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@6]) {
        cell.button6.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button6.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button6.backgroundColor = [UIColor lightGrayColor];
        cell.button6.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@7]) {
        cell.button7.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button7.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button7.backgroundColor = [UIColor lightGrayColor];
        cell.button7.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@8]) {
        cell.button8.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button8.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button8.backgroundColor = [UIColor lightGrayColor];
        cell.button8.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    if ([colorGamesFinished containsObject:@9]) {
        cell.button9.backgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
        cell.button9.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
    } else {
        cell.button9.backgroundColor = [UIColor lightGrayColor];
        cell.button9.layer.borderColor = [UIColor lightGrayColor].CGColor;
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

#pragma mark - UIScrollViewViewDelegate


/*-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static BOOL scrollingLeft = NO;
    static BOOL scrollingRight = NO;
    
    NSLog(@"Scrolleandooooooo con un offset en x: %f", scrollView.contentOffset.x);
    NSArray *visibleCells = [self.collectionView visibleCells];
    if ([visibleCells count] == 1) {
        ChaptersCell *firstCell = [visibleCells firstObject];
        NSLog(@"Solo se ve una celda con indexpath de %d", [self.collectionView indexPathForCell:firstCell].item);
    } else if ([visibleCells count] == 2) {
        NSUInteger firstCellIndex = [self.collectionView indexPathForCell:[visibleCells firstObject]].item;
        NSUInteger secondCellIndex = [self.collectionView indexPathForCell:[visibleCells lastObject]].item;
        ChaptersCell *leftCell;
        ChaptersCell *rightCell;
        if (firstCellIndex > secondCellIndex) {
            leftCell = [visibleCells lastObject];
            rightCell = [visibleCells firstObject];
        } else {
            leftCell = [visibleCells firstObject];
            rightCell = [visibleCells lastObject];
        }
        NSLog(@"Se ven dos celdas con indexpath de %d y %d y currentpage: %d", [self.collectionView indexPathForCell:leftCell].item, [self.collectionView indexPathForCell:rightCell].item, self.pageControl.currentPage);
        
        if (self.lastContentOffset > scrollView.contentOffset.x) {
            NSLog(@"Scrolleando a la izquierdaaaa");
            leftCell.button1.alpha = -(scrollView.contentOffset.x - 320.0*self.pageControl.currentPage)/320.0;
            rightCell.button1.alpha = 1.0 + (scrollView.contentOffset.x - 320.0*self.pageControl.currentPage)/320.0;
            
        } else {
            NSLog(@"Scrolleando a la derechaaa");
            leftCell.button1.alpha = 1.0 - (scrollView.contentOffset.x - 320.0*self.pageControl.currentPage)/320.0;
            rightCell.button1.alpha = (scrollView.contentOffset.x - 320.0*self.pageControl.currentPage)/320.0;
        }
        self.lastContentOffset = scrollView.contentOffset.x;
        //leftCell.button1.transform = CGAffineTransformMakeRotation(GLKMathDegreesToRadians(scrollView.contentOffset.x*(360.0/320.0)));
        //rightCell.button1.transform = CGAffineTransformMakeRotation(GLKMathDegreesToRadians(360.0 - scrollView.contentOffset.x*(360.0/320.0)));
        
    }
}*/

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de movemer");
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = currentPage;
}

-(void)goToGameVCWithSelectedGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    ColorsGameViewController *colorsGameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorsGame"];
    colorsGameVC.selectedChapter = chapter;
    colorsGameVC.selectedGame = game;
    colorsGameVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorsGameVC animated:YES completion:nil];
}

-(BOOL)checkIfUserCanPlayGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSArray *chaptersArray = [fileSaver getDictionary:@"ColorChaptersDic"][@"ColorChaptersArray"];
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

#pragma mark - ChaptersCellDelegate

-(void)chaptersCellDidSelectGame:(NSUInteger)game {
    [self playButtonPressedSound];
    
    BOOL userCanPlayGame = [self checkIfUserCanPlayGame:game + 1 inChapter:self.pageControl.currentPage];
    NSLog(@"Se seleccionó el juego %d", game);
    if (userCanPlayGame) {
        [self goToGameVCWithSelectedGame:game inChapter:self.pageControl.currentPage];
    } else {
        MultiplayerWinAlert *alert = [[MultiplayerWinAlert alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 125.0, self.view.bounds.size.height/2.0 - 75.0, 250.0, 150.0)];
        alert.alertMessage = @"Oops! You haven't unlocked this game yet!";
        alert.messageTextSize = 15.0;
        alert.delegate = self;
        [alert showAlertInView:self.view];
    }
    NSLog(@"Se seleccionó el juego %d", game);
}

#pragma mark - Notification Handlers

-(void)gameWonNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificación de juego ganado");
    //Get the won games in file saver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    self.colorGamesFinishedArray = [fileSaver getDictionary:@"ColorChaptersDic"][@"ColorChaptersArray"];
    [self.collectionView reloadData];
}

#pragma mark - MultiplayerWinAlertDelegate

-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert {
    winAlert = nil;
}

-(void)acceptButtonPressedInWinAlert:(MultiplayerWinAlert *)winAlert {
    
}

@end
