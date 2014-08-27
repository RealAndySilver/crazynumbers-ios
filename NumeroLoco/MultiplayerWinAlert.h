//
//  MultiplayerWinAlert.h
//  NumeroLoco
//
//  Created by Developer on 5/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MultiplayerWinAlert;

@protocol MultiplayerWinAlertDelegate <NSObject>
-(void)acceptButtonPressedInWinAlert:(MultiplayerWinAlert *)winAlert;
-(void)multiplayerWinAlertDidDissapear:(MultiplayerWinAlert *)winAlert;
@end

@interface MultiplayerWinAlert : UIView
@property (strong, nonatomic) id <MultiplayerWinAlertDelegate> delegate;
@property (strong, nonatomic) NSString *alertMessage;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *acceptButton;
@property (assign, nonatomic) CGFloat messageTextSize;
-(void)showAlertInView:(UIView *)view;
@end
