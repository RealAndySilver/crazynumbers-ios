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

@interface ChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate>
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@property (strong, nonatomic) NSArray *chaptersGamesFinishedArray;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

@implementation ChaptersViewController {
    CGRect screenBounds;
    NSUInteger numberOfChapters;
    NSUInteger selectedGame;
}

#pragma mark - Lazy Instantiation 

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
    self.view.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameWonNotificationReceived:)
                                                 name:@"GameWonNotification"
                                               object:nil];
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    numberOfChapters = [chaptersArray count];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Animate CollectionView
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.6
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
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 4.0;
    backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    [backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
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
        cell.button1.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button1.backgroundColor = [UIColor whiteColor];
        [cell.button1 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];

    } else {
        cell.button1.backgroundColor = [UIColor clearColor];
        cell.button1.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@2]) {
        cell.button2.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button2.backgroundColor = [UIColor whiteColor];
        [cell.button2 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button2.backgroundColor = [UIColor clearColor];
        cell.button2.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@3]) {
        cell.button3.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button3.backgroundColor = [UIColor whiteColor];
        [cell.button3 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button3.backgroundColor = [UIColor clearColor];
        cell.button3.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@4]) {
        cell.button4.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button4.backgroundColor = [UIColor whiteColor];
        [cell.button4 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button4.backgroundColor = [UIColor clearColor];
        cell.button4.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@5]) {
        cell.button5.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button5.backgroundColor = [UIColor whiteColor];
        [cell.button5 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button5.backgroundColor = [UIColor clearColor];
        cell.button5.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@6]) {
        cell.button6.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button6.backgroundColor = [UIColor whiteColor];
        [cell.button6 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button6.backgroundColor = [UIColor clearColor];
        cell.button6.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button6 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@7]) {
        cell.button7.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button7.backgroundColor = [UIColor whiteColor];
        [cell.button7 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button7.backgroundColor = [UIColor clearColor];
        cell.button7.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button7 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@8]) {
        cell.button8.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button8.backgroundColor = [UIColor whiteColor];
        [cell.button8 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button8.backgroundColor = [UIColor clearColor];
        cell.button8.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button8 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    if ([gamesFinishedArray containsObject:@9]) {
        cell.button9.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][indexPath.item]).CGColor;
        cell.button9.backgroundColor = [UIColor whiteColor];
        [cell.button9 setTitleColor:[[AppInfo sharedInstance] appColorsArray][indexPath.item] forState:UIControlStateNormal];
    } else {
        cell.button9.backgroundColor = [UIColor clearColor];
        cell.button9.layer.borderColor = [UIColor whiteColor].CGColor;
        [cell.button9 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - Actions 

-(void)dismissVC {
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
    BOOL userCanPlayGame = [self checkIfUserCanPlayGame:game + 1 inChapter:self.pageControl.currentPage];
    NSLog(@"Se seleccionó el juego %d", game);
    if (userCanPlayGame) {
        selectedGame = game;
        [self goToGameVCWithSelectedGame:game inChapter:self.pageControl.currentPage];

    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You haven't unlocked this game yet!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

#pragma mark - Notification Handlers

-(void)gameWonNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificación de juego ganado");
    //Get the won games in file saver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    self.chaptersGamesFinishedArray = [fileSaver getDictionary:@"NumberChaptersDic"][@"NumberChaptersArray"];
    [self.collectionView reloadData];
}

@end
