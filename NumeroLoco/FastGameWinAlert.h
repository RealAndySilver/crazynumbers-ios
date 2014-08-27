//
//  FastGameWinAlert.h
//  NumeroLoco
//
//  Created by Diego Vidal on 25/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FastGameWinAlert;

@protocol FastGameAlertDelegate <NSObject>
-(void)buyLivesButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert;
-(void)continueButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert;
-(void)exitButtonPressedInAlert:(FastGameWinAlert *)fastGameWinAlert;
@end

@interface FastGameWinAlert : UIView
@property (strong, nonatomic) id <FastGameAlertDelegate> delegate;
@property (strong, nonatomic) UIButton *continueButton;
@property (strong, nonatomic) UILabel *alertLabel;
-(void)showInView:(UIView *)view;
@end
