//
//  MultiplayerAlertView.h
//  NumeroLoco
//
//  Created by Developer on 14/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MultiplayerAlertView;

@protocol MultiplayerAlertDelegate <NSObject>
-(void)cancelButtonPressedInMultiplayerAlert:(MultiplayerAlertView *)multiplayerAlert;
-(void)restartButtonPressedInMultiplayerAlert:(MultiplayerAlertView *)multiplayerAlert;
-(void)multiplayerAlertDidDissapear:(MultiplayerAlertView *)multiplayerAlert;
@end

@interface MultiplayerAlertView : UIView
@property (strong, nonatomic) id <MultiplayerAlertDelegate> delegate;
-(void)showInView:(UIView *)view;
@end
