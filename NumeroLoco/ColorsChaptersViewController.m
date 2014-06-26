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
@import GLKit;

@interface ColorsChaptersViewController () <UICollectionViewDataSource, UICollectionViewDelegate, ChaptersCellDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *chaptersNamesArray;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) CGFloat lastContentOffset;
@end

@implementation ColorsChaptersViewController {
    NSUInteger numberOfChapters;
    CGRect screenBounds;
}

#pragma mark - Lazy Instantiation

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
    self.view.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"ColorGamesDatabase2" ofType:@"plist"];
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
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 100.0, screenBounds.size.height - 130.0, 200.0, 30.0)];
    self.pageControl.numberOfPages = numberOfChapters;
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
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
    ChaptersCell *cell = (ChaptersCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.chapterNameLabel.text = self.chaptersNamesArray[indexPath.item];
    cell.chapterNameLabel.textColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
    cell.buttonsBackgroundColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
    cell.buttonsBorderColor = [[AppInfo sharedInstance] appColorsArray][indexPath.item];
    cell.buttonsTitleColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - Actions 

-(void)dismissVC {
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

#pragma mark - ChaptersCellDelegate

-(void)chaptersCellDidSelectGame:(NSUInteger)game {
    NSLog(@"Se seleccionó el juego %d", game);
    ColorsGameViewController *colorsGameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorsGame"];
    colorsGameVC.selectedChapter = self.pageControl.currentPage;
    colorsGameVC.selectedGame = game;
    colorsGameVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorsGameVC animated:YES completion:nil];
}

@end
