//
//  GameWonAlert.m
//  NumeroLoco
//
//  Created by Developer on 26/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameWonAlert.h"

@interface GameWonAlert()
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation GameWonAlert

#pragma mark - Setters & Getters 

-(void)setMessage:(NSString *)message {
    _message = message;
    self.detailLabel.text = message;
}

#pragma mark - Initialization Stuff

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Title Label
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 40.0)];
        titleLabel.text = @"Game Won!";
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0];
        [self addSubview:titleLabel];
        
        //Detail Label
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 80.0, frame.size.width - 20.0, 80.0)];
        self.detailLabel.textColor = [UIColor lightGrayColor];
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.detailLabel];
        
        //Faebook button
        UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeSystem];
        facebookButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        facebookButton.frame = CGRectMake(10.0, self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 40.0, frame.size.width - 40.0, 30.0);
        [facebookButton setTitle:@"Share on Facebook" forState:UIControlStateNormal];
        [facebookButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        facebookButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        [facebookButton addTarget:self action:@selector(facebookButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:facebookButton];
        
        //Facebook ImageView
        UIImageView *fbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, facebookButton.frame.origin.y - 3.0, 35.0, 35.0)];
        fbImageView.image = [UIImage imageNamed:@"FacebookLogo.png"];
        [self addSubview:fbImageView];
        
        //Twitter button
        UIButton *twitterButton = [UIButton buttonWithType:UIButtonTypeSystem];
        twitterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        twitterButton.frame = CGRectMake(10.0, facebookButton.frame.origin.y + facebookButton.frame.size.height + 10.0 , frame.size.width - 40.0, 30.0);
        [twitterButton setTitle:@"Share on Twitter" forState:UIControlStateNormal];
        [twitterButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        twitterButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        [twitterButton addTarget:self action:@selector(twitterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:twitterButton];
        
        //Twitter ImageView
        UIImageView *twitterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, twitterButton.frame.origin.y, 35.0, 35.0)];
        twitterImageView.image = [UIImage imageNamed:@"TwitterLogo.gif"];
        [self addSubview:twitterImageView];
        
        //Challenge button
        UIButton *challengeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        challengeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        challengeButton.frame = CGRectMake(10.0, twitterButton.frame.origin.y + twitterButton.frame.size.height + 10.0, frame.size.width - 40.0, 30.0);
        [challengeButton setTitle:@"Challenge Friends" forState:UIControlStateNormal];
        [challengeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        challengeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        [challengeButton addTarget:self action:@selector(challengeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:challengeButton];
        
        //Challenge ImageView
        UIImageView *challengeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, challengeButton.frame.origin.y, 35.0, 35.0)];
        challengeImageView.image = [UIImage imageNamed:@"ChallengeIcon.png"];
        [self addSubview:challengeImageView];
        
        //Continue Button
        UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeSystem];
        continueButton.frame = CGRectMake(20.0, frame.size.height - 60.0, frame.size.width - 40.0, 40.0);
        [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [continueButton setTitleColor:[UIColor colorWithRed:0.380 green:0.870 blue:1.000 alpha:1.0] forState:UIControlStateNormal];
        continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0];
        [continueButton addTarget:self action:@selector(closeAlertInView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:continueButton];
    }
    return self;
}

#pragma mark - Actions

-(void)facebookButtonPressed {
    [self.delegate facebookButtonPressedInAlert:self];
}

-(void)twitterButtonPressed {
    [self.delegate twitterButtonPressedInAlert:self];
}

-(void)challengeButtonPressed {
    [self.delegate challengeButtonPressedInAlert:self];
}

-(void)closeAlertInView:(UIView *)view {
    [self.delegate continueButtonPressedInAlert:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.opacityView.alpha = 0.0;
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self.opacityView removeFromSuperview];
                         [view removeFromSuperview];
                         [self.delegate gameWonAlertDidDissapear:self];
                     }];
}

-(void)showAlertInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.opacityView.alpha = 0.8;
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){
                         [self.delegate gameWonAlertDidApper:self];
                     }];
}

/*+(void)showInView:(UIView *)view {
    UIView *opacityView = [[UIView alloc] initWithFrame:view.frame];
    opacityView.backgroundColor = [UIColor blackColor];
    opacityView.alpha = 0.0;
    [view addSubview:opacityView];
    
    UIView *alert = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width, view.frame.size.height/2.0 - 75.0, 250.0, 150.0)];
    alert.backgroundColor = [UIColor whiteColor];
    alert.layer.cornerRadius = 10.0;
    [view addSubview:alert];
    
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, alert.frame.size.width, alert.frame.size.height)];
    mainTitle.text = @"Game Won!";
    mainTitle.textColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    mainTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:35.0];
    mainTitle.textAlignment = NSTextAlignmentCenter;
    [alert addSubview:mainTitle];
    alert.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         opacityView.alpha = 0.8;
                         alert.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         alert.transform = CGAffineTransformMakeTranslation(-(view.frame.size.width/2.0 + alert.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:1.0 animations:^(){
                             alert.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             alert.transform = CGAffineTransformMakeTranslation(-(view.frame.size.width/2.0 + alert.frame.size.width/2.0), 0.0);
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:1.0
                                                   delay:0.0
                                  usingSpringWithDamping:0.7
                                   initialSpringVelocity:0.0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^(){
                                                  alert.transform = CGAffineTransformMakeScale(0.5, 0.5);
                                                  alert.transform = CGAffineTransformMakeTranslation(-(view.frame.size.width + alert.frame.size.width*2), 0.0);
                                                  opacityView.alpha = 0.0;

                                              } completion:^(BOOL finished){
                                                  [opacityView removeFromSuperview];
                                                  [alert removeFromSuperview];
                                              }];
                         }];
                     }];
}*/

@end
