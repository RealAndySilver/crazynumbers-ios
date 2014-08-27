//
//  NoTouchesAlertView.h
//  NumeroLoco
//
//  Created by Diego Vidal on 21/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoTouchesAlertView;

@protocol NoTouchesAlertDelegate <NSObject>
-(void)buyTouchesButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert;
-(void)waitButtonPressedInAlert:(NoTouchesAlertView *)multiplayerAlert;
-(void)noTouchesAlertDidDissapear:(NoTouchesAlertView *)multiplayerAlert;
@end

@interface NoTouchesAlertView : UIView
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UIButton *acceptButton;
@property (strong, nonatomic) id <NoTouchesAlertDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
