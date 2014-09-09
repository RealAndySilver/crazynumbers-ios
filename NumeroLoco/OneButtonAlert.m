//
//  OneButtonAlert.m
//  MiRed
//
//  Created by Diego Vidal on 22/08/14.
//  Copyright (c) 2014 Diego Fernando Vidal Illera. All rights reserved.
//

#import "OneButtonAlert.h"
#import "AppInfo.h"

#define FONT_NAME @"HelveticaNeue-Light"
#define ANIMATION_DURATION 0.3

@interface OneButtonAlert()
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *button;
@end

@implementation OneButtonAlert

#pragma mark - Setters & Getters 

-(void)setAlertText:(NSString *)alertText {
    _alertText = alertText;
    self.messageLabel.text = alertText;
}

-(void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.button setTitle:buttonTitle forState:UIControlStateNormal];
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        //Message label
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, frame.size.width - 40.0, 60.0)];
        self.messageLabel.textColor = [UIColor darkGrayColor];
        self.messageLabel.font = [UIFont fontWithName:FONT_NAME size:18.0];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.messageLabel];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(-32.0, -32.0, 80.0, 80.0)];
        [closeButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //Camera button
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - 50.0, frame.size.height - 50.0, 100.0, 40.0)];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        self.button.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:75.0/255.0 blue:139.0/255.0 alpha:1.0];
        self.button.layer.cornerRadius = 5.0;
        [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions 

-(void)buttonPressed {
    [self.delegate buttonClickedInAlert:self];
    [self closeView];
}

-(void)closeView {
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished){
                         if (finished) {
                             [self.opacityView removeFromSuperview];
                             self.opacityView = nil;
                             [self removeFromSuperview];
                         }
                     }];
}


@end