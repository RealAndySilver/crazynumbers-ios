//
//  WordsChaptersViewController.m
//  NumeroLoco
//
//  Created by Developer on 18/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "WordsChaptersViewController.h"
#import "WordsGameViewController.h"
#import "FileSaver.h"
#import "ChaptersCell.h"
#import "AppInfo.h"

@interface WordsChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *wordGamesFinishedArray;
@end

@implementation WordsChaptersViewController {
    NSUInteger numberOfChapters;
    CGRect screenBounds;
}

#pragma mark - Lazy Instantiation

-(NSArray *)colorGamesFinishedArray {
    if (!_wordGamesFinishedArray) {
        FileSaver *fileSaver = [[FileSaver alloc] init];
        _wordGamesFinishedArray = [fileSaver getDictionary:@"WordChaptersDic"][@"WordChaptersArray"];
    }
    return _wordGamesFinishedArray;
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
                                                 name:@"WordGameWonNotification"
                                               object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"WordsGamesDatabase2" ofType:@"plist"];
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
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
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

#pragma mark - Actions 

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de movemer");
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = currentPage;
}

-(void)goToGameVCWithSelectedGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    WordsGameViewController *wordsGameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WordsGame"];
    wordsGameVC.selectedChapter = chapter;
    wordsGameVC.selectedGame = game;
    wordsGameVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:wordsGameVC animated:YES completion:nil];
}

-(BOOL)checkIfUserCanPlayGame:(NSUInteger)game inChapter:(NSUInteger)chapter {
    FileSaver *fileSaver = [[FileSaver alloc] init];
    NSArray *chaptersArray = [fileSaver getDictionary:@"WordChaptersDic"][@"WordChaptersArray"];
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
    BOOL userCanPlayGame = [self checkIfUserCanPlayGame:game + 1 inChapter:self.pageControl.currentPage];
    NSLog(@"Se seleccionó el juego %lu", (unsigned long)game);
    if (userCanPlayGame) {
        [self goToGameVCWithSelectedGame:game inChapter:self.pageControl.currentPage];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You haven't unlock this game yet!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    NSLog(@"Se seleccionó el juego %lu", (unsigned long)game);
}

#pragma mark - Notification Handlers

-(void)gameWonNotificationReceived:(NSNotification *)notification {
    NSLog(@"Recibí la notificación de juego ganado");
    //Get the won games in file saver
    FileSaver *fileSaver = [[FileSaver alloc] init];
    self.wordGamesFinishedArray = [fileSaver getDictionary:@"WordChaptersDic"][@"WordChaptersArray"];
    [self.collectionView reloadData];
}

@end
