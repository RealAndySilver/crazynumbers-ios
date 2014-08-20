//
//  TutorialViewController.m
//  NumeroLoco
//
//  Created by Developer on 1/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialCell.h"
#import "AudioPlayer.h"
@import AVFoundation;

@interface TutorialViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *tutorialImagesArray;
@property (strong, nonatomic) AVAudioPlayer *playerBackSound;
@end

@implementation TutorialViewController {
    CGRect screenBounds;
}

#pragma mark - Lazy Instantiation 

-(NSArray *)tutorialImagesArray {
    if (!_tutorialImagesArray) {
        _tutorialImagesArray = @[@"TutorialPhoneR4_1.png", @"TutorialPhoneR4_2.png", @"TutorialPhoneR4_3.png", @"TutorialPhoneR4_4.png", @"TutorialPhoneR4_5.png"];
    }
    return _tutorialImagesArray;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
    [self setupSounds];
}

-(void)setupSounds {
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"wav"];
    NSURL *soundFileURL = [NSURL URLWithString:soundFilePath];
    self.playerBackSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    [self.playerBackSound prepareToPlay];
}

-(void)setupUI {
    //CollectionView Setup
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.view.frame.size;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[TutorialCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.collectionView];
    
    //Close Button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(20.0, screenBounds.size.height - 60.0, 70.0, 40.0);
    [closeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [closeButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    closeButton.layer.cornerRadius = 10.0;
    closeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    closeButton.layer.borderWidth = 1.0;
    [self.view addSubview:closeButton];
    
    //PageContro setup
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 100.0, screenBounds.size.height - 50.0, 200.0, 30.0)];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.pageControl.numberOfPages = [self.tutorialImagesArray count];
    [self.view addSubview:self.pageControl];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.tutorialImagesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TutorialCell *cell = (TutorialCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:self.tutorialImagesArray[indexPath.item]];
    return cell;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"Terminé de moverme");
    NSUInteger pageWidth = screenBounds.size.width;
    NSUInteger currentPage = scrollView.contentOffset.x/pageWidth;
    self.pageControl.currentPage = currentPage;
}

#pragma mark - Actions 

-(void)dismissVC {
    /*if (self.viewControllerAppearedFromInitialLaunching) {
        //This is the first time the user launches the app, so
        //post a notification to display game center
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"FirstTimeTutorialNotification" object:nil];
    }*/
    [[AudioPlayer sharedInstance] playBackSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
