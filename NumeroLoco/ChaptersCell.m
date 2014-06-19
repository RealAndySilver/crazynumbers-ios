//
//  ChaptersCell.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ChaptersCell.h"
#import "GameNumberCell.h"

@interface ChaptersCell() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation ChaptersCell 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chapterNameLabel = [[UILabel alloc] init];
        self.chapterNameLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:30.0];
        self.chapterNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.chapterNameLabel];
        
        //Setup CollectionViewFlowLayout
        UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewFlowLayout.itemSize = CGSizeMake(70.0, 70.0);
        collectionViewFlowLayout.minimumInteritemSpacing = 10;
        collectionViewFlowLayout.minimumLineSpacing = 10;
        
        //Setup CollectionView
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewFlowLayout];
        [self.collectionView registerClass:[GameNumberCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentBounds = self.contentView.bounds;
    self.chapterNameLabel.frame = CGRectMake(20.0, 30.0, contentBounds.size.width - 40.0, 30.0);
    self.collectionView.frame = CGRectMake(45.0, 100.0, contentBounds.size.width - 90.0, contentBounds.size.width - 90.0);
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GameNumberCell *cell = (GameNumberCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.gameLabel.text = [NSString stringWithFormat:@"%d", indexPath.item + 1];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate chaptersCellDidSelectGame:indexPath.item];
}

@end
