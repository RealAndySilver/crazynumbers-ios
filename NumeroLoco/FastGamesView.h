//
//  FastGamesView.h
//  NumeroLoco
//
//  Created by Diego Vidal on 2/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  FastGamesView;

@protocol FastGamesViewDelegate <NSObject>
-(void)closeButtonPressedInFastGameView:(FastGamesView *)fastGamesView;
-(void)gameSelected:(NSUInteger)game inFastGamesView:(FastGamesView *)fastGamesView;
@end

@interface FastGamesView : UIView
@property (strong, nonatomic) id <FastGamesViewDelegate> delegate;
-(void)showInView:(UIView *)view;
@end