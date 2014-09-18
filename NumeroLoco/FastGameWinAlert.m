//
//  FastGameWinAlert.m
//  NumeroLoco
//
//  Created by Diego Vidal on 25/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FastGameWinAlert.h"
#import "AppInfo.h"

@interface FastGameWinAlert()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation FastGameWinAlert

#define FONT_NAME @"HelveticaNeue-Light"

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10.0;
        self.backgroundColor = [UIColor whiteColor];
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.alpha = 0.0;
        
        self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 60.0)];
        self.alertLabel.numberOfLines = 0;
        self.alertLabel.textColor = [UIColor darkGrayColor];
        self.alertLabel.textAlignment = NSTextAlignmentCenter;
        self.alertLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.alertLabel];
        
        self.buyLivesButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 100.0, frame.size.width - 80.0, 40.0)];
        [self.buyLivesButton setTitle:@"Buy Lives" forState:UIControlStateNormal];
        [self.buyLivesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buyLivesButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        self.buyLivesButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][1];
        self.buyLivesButton.layer.cornerRadius = 10.0;
        [self.buyLivesButton addTarget:self action:@selector(buyLivesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.buyLivesButton];
        
        self.continueButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 150.0, frame.size.width - 80.0, 40.0)];
        [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.continueButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        self.continueButton.layer.cornerRadius = 10.0;
        self.continueButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][1];
        [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.continueButton];
        
        UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(40.0, 200.0, frame.size.width - 80.0, 40.0)];
        [exitButton setTitle:@"Exit Fast Mode" forState:UIControlStateNormal];
        [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        exitButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        exitButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        exitButton.layer.cornerRadius = 10.0;
        [exitButton addTarget:self action:@selector(exitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:exitButton];
    }
    return self;
}

-(void)showInView:(UIView *)view {
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
                     animations:^{
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Actions 

-(void)closeView {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished){
                         [self.opacityView removeFromSuperview];
                         self.opacityView = nil;
                         [self removeFromSuperview];
                     }];
}

-(void)continueButtonPressed {
    [self.delegate continueButtonPressedInAlert:self];
    [self closeView];
}

-(void)exitButtonPressed {
    [self.delegate exitButtonPressedInAlert:self];
    [self closeView];
}

-(void)buyLivesButtonPressed {
    [self.delegate buyLivesButtonPressedInAlert:self];
    //[self closeView];
}

@end
