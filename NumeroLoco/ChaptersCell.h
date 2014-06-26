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
@property (strong, nonatomic) UIColor *buttonsBackgroundColor;
@property (strong, nonatomic) UIColor *buttonsBorderColor;
@property (strong, nonatomic) UIColor *buttonsTitleColor;
@property (strong, nonatomic) NSMutableArray *buttonsArray;

@property (strong, nonatomic) UIButton *button1;
@property (strong, nonatomic) UIButton *button2;
@property (strong, nonatomic) UIButton *button3;
@property (strong, nonatomic) UIButton *button4;
@property (strong, nonatomic) UIButton *button5;
@property (strong, nonatomic) UIButton *button6;
@property (strong, nonatomic) UIButton *button7;
@property (strong, nonatomic) UIButton *button8;
@property (strong, nonatomic) UIButton *button9;

@end
