//
//  AllGamesFinishedView.h
//  NumeroLoco
//
//  Created by Developer on 12/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AllGamesFinishedView;

@protocol AllGamesFinishedViewDelegate <NSObject>
-(void)gameFinishedViewWillDissapear:(AllGamesFinishedView *)gamesFinishedView;
-(void)gameFinishedViewDidDissapear:(AllGamesFinishedView *)gamesFinishedView;
@end

@interface AllGamesFinishedView : UIView
@property (strong, nonatomic) id <AllGamesFinishedViewDelegate> delegate;
@property (strong, nonatomic) UILabel *messageLabel;
-(void)showInView:(UIView *)view;
@end
