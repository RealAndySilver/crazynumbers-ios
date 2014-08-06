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

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //OpacityView
        
        //Winning Label
        UILabel *winLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.size.height/2.0 - 15.0, frame.size.width, 30.0)];
        winLabel.text = @"You Won!";
        winLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0];
        winLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:winLabel];
        
        //Accept Button
        UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
        acceptButton.frame = CGRectMake(frame.size.width/2.0 - 40.0, frame.size.height - 50.0, 80.0, 50.0);
        [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
        [acceptButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
        acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regulat" size:20.0];
        [acceptButton addTarget:self action:@selector(closeAlertInView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:acceptButton];
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
