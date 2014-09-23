//
//  MultiplayerWinAlert.m
//  NumeroLoco
//
//  Created by Developer on 5/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MultiplayerWinAlert.h"
#import "AppInfo.h"

@interface MultiplayerWinAlert()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MultiplayerWinAlert

#pragma mark - Setters & Getters 

-(void)setMessageTextSize:(CGFloat)messageTextSize {
    _messageTextSize = messageTextSize;
    self.messageLabel.font = [UIFont fontWithName:@"HelventicaNeue-Light" size:messageTextSize];
}

-(void)setAlertMessage:(NSString *)alertMessage {
    _alertMessage = alertMessage;
    self.messageLabel.text = alertMessage;
}

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //OpacityView
        
        //Winning Label
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, frame.size.width - 20.0, 50.0)];
        self.messageLabel.text = NSLocalizedString(@"You Won!", @"You won message");
        self.messageLabel.textColor = [UIColor darkGrayColor];
        self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        [self addSubview:self.messageLabel];
        
        //Accept Button
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.acceptButton.frame = CGRectMake(frame.size.width/2.0 - 60.0, frame.size.height - 60.0, 120.0, 50.0);
        [self.acceptButton setTitle:NSLocalizedString(@"Ok", @"Accept button") forState:UIControlStateNormal];
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        self.acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        [self.acceptButton addTarget:self action:@selector(closeAlertInView:) forControlEvents:UIControlEventTouchUpInside];
        self.acceptButton.layer.cornerRadius = 10.0;
        [self addSubview:self.acceptButton];
    }
    return self;
}

-(void)showAlertInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.8;
                     } completion:^(BOOL finished){}];
}

-(void)closeAlertInView:(UIView *)view {
    [self.delegate acceptButtonPressedInWinAlert:self];
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.opacityView.alpha = 0.0;
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self removeFromSuperview];
                         self.opacityView = nil;
                         [self.delegate multiplayerWinAlertDidDissapear:self];
                     }];
}

@end
