//
//  MultiplayerAlertView.m
//  NumeroLoco
//
//  Created by Developer on 14/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "MultiplayerAlertView.h"
#import "AppInfo.h"

@interface MultiplayerAlertView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation MultiplayerAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.0;
        self.layer.cornerRadius = 10.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Message
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, frame.size.width - 40.0, 60.0)];
        message.text = @"Are you sure you want to restart both games?";
        message.textColor = [UIColor darkGrayColor];
        message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        message.textAlignment = NSTextAlignmentCenter;
        message.numberOfLines = 0;
        [self addSubview:message];
        
        //Accept button
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
        acceptButton.frame = CGRectMake(20.0, frame.size.height - 70.0, frame.size.width/2.0 - 40.0, 50.0);
        [acceptButton setTitle:@"Restart" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
        acceptButton.layer.cornerRadius = 10.0;
        [acceptButton addTarget:self action:@selector(restartButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:acceptButton];
        
        //Cancel button
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(frame.size.width/2.0 + 20.0, frame.size.height - 70.0, frame.size.width/2.0 - 40.0, 50.0);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        cancelButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        cancelButton.layer.cornerRadius = 10.0;
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
    }
    return self;
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions 

-(void)restartButtonPressed {
    [self.delegate restartButtonPressedInMultiplayerAlert:self];
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.opacityView.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.opacityView removeFromSuperview];
                         self.opacityView = nil;
                         [self.delegate multiplayerAlertDidDissapear:self];
                     }];
}

-(void)cancelButtonPressed {
    [self.delegate cancelButtonPressedInMultiplayerAlert:self];
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.opacityView.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.opacityView removeFromSuperview];
                         self.opacityView = nil;
                         [self removeFromSuperview];
                         [self.delegate multiplayerAlertDidDissapear:self];
                     }];
}

@end
