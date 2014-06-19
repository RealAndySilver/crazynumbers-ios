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

@interface ChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate>
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@end

@implementation ChaptersViewController {
    CGRect screenBounds;
    NSUInteger numberOfChapters;
}

#pragma mark - Lazy Instantiation 

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
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"GamesDatabase2" ofType:@"plist"];
    NSArray *chaptersArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
    numberOfChapters = [chaptersArray count];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)setupUI {
    //Setup CollectionViewFlowLayout
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout.minimumInteritemSpacing = 0;
    collectionViewFlowLayout.minimumLineSpacing = 0;
    collectionViewFlowLayout.itemSize = CGSizeMake(screenBounds.size.width, screenBounds.size.width + 100.0);
    
    //Setup CollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenBounds.size.width, screenBounds.size.height) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    [self.collectionView registerClass:[ChaptersCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Setup PageControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 100.0, screenBounds.size.height - 100.0, 200.0, 30.0)];
    self.pageControl.numberOfPages = numberOfChapters;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0];
    [self.view addSubview:self.pageControl];
    
    //Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.layer.cornerRadius = 4.0;
    backButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
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
    cell.delegate = self;
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

#pragma mark - UIScrollViewViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de movemer");
    CGFloat pageWidth = self.collectionView.frame.size.width;
    NSUInteger currentPage = self.collectionView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = currentPage;
}

#pragma mark - ChaptersCellDelegate

-(void)chaptersCellDidSelectGame:(NSUInteger)game {
    NSLog(@"Se seleccionó el juego %d", game);
    [self goToGameVCWithSelectedGame:game inChapter:self.pageControl.currentPage];
}

@end
