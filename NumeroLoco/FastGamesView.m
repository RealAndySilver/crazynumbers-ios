//
//  FastGamesView.m
//  NumeroLoco
//
//  Created by Diego Vidal on 2/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FastGamesView.h"
#import "AppInfo.h"
#import "GameCell.h"

@interface FastGamesView() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) NSUInteger numberOfGames;
@property (assign, nonatomic) NSUInteger gamesCompleted;
@end

@implementation FastGamesView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.0;
        self.layer.cornerRadius = 10.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        //Number of games
        NSString *gamesDatabasePath = [[NSBundle mainBundle] pathForResource:@"FastGamesDatabase" ofType:@"plist"];
        NSArray *fastGamesArray = [NSArray arrayWithContentsOfFile:gamesDatabasePath];
        self.numberOfGames = [fastGamesArray count];
        
        //Get the games completed
        self.gamesCompleted = [[[NSUserDefaults standardUserDefaults] objectForKey:@"unlockedFastGames"] intValue];
        NSLog(@"unlcoked games: %lu", (unsigned long)self.gamesCompleted);
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        closeButton.layer.cornerRadius = 10.0;
        closeButton.layer.borderWidth = 1.0;
        [closeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //Title label
        UILabel *fastGamesTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 40.0, frame.size.width - 40.0, 50.0)];
        fastGamesTitle.text = @"Fast Games";
        fastGamesTitle.textColor = [UIColor darkGrayColor];
        fastGamesTitle.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35.0];
        fastGamesTitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:fastGamesTitle];
        
        //Collectionview
        UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewFlowLayout.itemSize = CGSizeMake(50.0, 50.0);
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 110.0, frame.size.width, frame.size.height - 110.0)collectionViewLayout:collectionViewFlowLayout];
        self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 20.0, 20.0, 20.0);
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.layer.cornerRadius = 10.0;
        [self.collectionView registerClass:[GameCell class] forCellWithReuseIdentifier:@"identifier"];
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfGames;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GameCell *cell = (GameCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"identifier" forIndexPath:indexPath];
    cell.gameNumberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    if (self.gamesCompleted >= indexPath.row + 1) {
        cell.gameNumberLabel.layer.borderColor = self.viewColor.CGColor;
        cell.gameNumberLabel.backgroundColor = self.viewColor;
        cell.gameNumberLabel.textColor = [UIColor whiteColor];
        cell.userInteractionEnabled = YES;
    } else {
        cell.gameNumberLabel.backgroundColor = [UIColor whiteColor];
        cell.gameNumberLabel.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        cell.gameNumberLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.8;
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate gameSelected:indexPath.row inFastGamesView:self];
    [self closeAlert];
}

#pragma mark - Actions 

-(void)closeButtonPressed {
    [self.delegate closeButtonPressedInFastGameView:self];
    [self closeAlert];
}

-(void)closeAlert {
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

@end
