//
//  TwoButtonsAlert.h
//  MiRed
//
//  Created by Diego Vidal on 22/08/14.
//  Copyright (c) 2014 Diego Fernando Vidal Illera. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TwoButtonsAlert;

@protocol TwoButtonsAlertDelegate <NSObject>
-(void)leftButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert;
-(void)rightButtonPressedInAlert:(TwoButtonsAlert *)twoButtonsAlert;
-(void)twoButtonsAlertDidDisappear:(TwoButtonsAlert *)twoButtonsAlert;
@end

@interface TwoButtonsAlert : UIView
@property (strong, nonatomic)id <TwoButtonsAlertDelegate> delegate;
@property (strong, nonatomic) NSString *alertText;
@property (strong, nonatomic) NSString *leftButtonTitle;
@property (strong, nonatomic) NSString *rightButtonTitle;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;
-(void)showInView:(UIView *)view;
@end
