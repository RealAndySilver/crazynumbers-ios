//
//  NoTouchesAlertView.m
//  NumeroLoco
//
//  Created by Diego Vidal on 21/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "NoTouchesAlertView.h"
#import "AppInfo.h"

@interface NoTouchesAlertView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation NoTouchesAlertView

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
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 30.0, frame.size.width - 40.0, 80.0)];
        self.message.text = @"You have no more touches left! you can wait one hour to have more or buy some!";
        self.message.textColor = [UIColor darkGrayColor];
        self.message.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        self.message.textAlignment = NSTextAlignmentCenter;
        self.message.numberOfLines = 0;
        [self addSubview:self.message];
        
        //Accept button
        self.acceptButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.acceptButton.frame = CGRectMake(20.0, frame.size.height - 70.0, frame.size.width/2.0 - 40.0, 50.0);
        [self.acceptButton setTitle:@"Buy" forState:UIControlStateNormal];
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        self.acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        self.acceptButton.layer.cornerRadius = 10.0;
        [self.acceptButton addTarget:self action:@selector(buyTouchesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.acceptButton];
        
        //Cancel button
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelButton.frame = CGRectMake(frame.size.width/2.0 + 20.0, frame.size.height - 70.0, frame.size.width/2.0 - 40.0, 50.0);
        [cancelButton setTitle:@"Wait" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        cancelButton.backgroundColor = [UIColor lightGrayColor];
        cancelButton.layer.cornerRadius = 10.0;
        [cancelButton addTarget:self action:@selector(waitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
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

-(void)buyTouchesButtonPressed {
    [self.delegate buyTouchesButtonPressedInAlert:self];
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
                         [self.delegate noTouchesAlertDidDissapear:self];
                     }];
}

-(void)waitButtonPressed {
    [self.delegate waitButtonPressedInAlert:self];
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
                         [self.delegate noTouchesAlertDidDissapear:self];
                     }];
}


@end
