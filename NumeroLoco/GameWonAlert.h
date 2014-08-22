//
//  GameWonAlert.h
//  NumeroLoco
//
//  Created by Developer on 26/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameWonAlert;

@protocol GameWonAlertDelegate <NSObject>
-(void)continueButtonPressedInAlert:(GameWonAlert *)gameWonAlert;
-(void)gameWonAlertDidDissapear:(GameWonAlert *)gameWonAlert;
-(void)facebookButtonPressedInAlert:(GameWonAlert *)gameWonAlert;
-(void)twitterButtonPressedInAlert:(GameWonAlert *)gameWonAlert;
-(void)challengeButtonPressedInAlert:(GameWonAlert *)gameWonAlert;
-(void)gameWonAlertDidApper:(GameWonAlert *)gameWonAlert;
@end

@interface GameWonAlert : UIView
@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) NSUInteger touchesMade;
@property (assign, nonatomic) NSUInteger touchesForBestScore;
@property (assign, nonatomic) NSUInteger touchesScore;
@property (assign, nonatomic) NSUInteger maxTouchesScore;
@property (assign, nonatomic) float timeUsed;
@property (assign, nonatomic) float timeForBestScore;
@property (assign, nonatomic) NSUInteger bonusScore;
@property (assign, nonatomic) NSUInteger maxBonusScore;
@property (strong, nonatomic) id <GameWonAlertDelegate> delegate;
-(void)showAlertInView:(UIView *)view;
@end
