//
//  TutorialAlertView.h
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  TutorialAlertView;

@protocol TutorialAlertDelegate <NSObject>
-(void)acceptButtonPressedInAlert:(TutorialAlertView *)tutorialAlertView;
@end

@interface TutorialAlertView : UIView
@property (strong, nonatomic) id <TutorialAlertDelegate> delegate;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *acceptButton;
-(void)showInView:(UIView *)view;
@end
