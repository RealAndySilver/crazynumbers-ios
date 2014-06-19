//
//  ChaptersCell.h
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChaptersCellDelegate <NSObject>
-(void)chaptersCellDidSelectGame:(NSUInteger)game;
@end

@interface ChaptersCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *chapterNameLabel;
@property (strong, nonatomic) id <ChaptersCellDelegate> delegate;
@end
