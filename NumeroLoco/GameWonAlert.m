//
//  GameWonAlert.m
//  NumeroLoco
//
//  Created by Developer on 26/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameWonAlert.h"
#import "AppInfo.h"

@interface GameWonAlert()
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UILabel *touchesMadeLabel;
@property (strong, nonatomic) UILabel *touchesBestScoreLabel;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UILabel *timeSpentLabel;
@property (strong, nonatomic) UILabel *idealTimeLabel;
@property (strong, nonatomic) UILabel *bonusScoreLabel;
@property (strong, nonatomic) UILabel *bigScoreLabel;
@end

#define FONT_NAME @"HelveticaNeue-Light"

@implementation GameWonAlert

#pragma mark - Setters & Getters 

-(void)setMessage:(NSString *)message {
    _message = message;
    self.detailLabel.text = message;
}

-(void)setTouchesMade:(NSUInteger)touchesMade {
    _touchesMade = touchesMade;
    self.touchesMadeLabel.text = [NSString stringWithFormat:@"Touches made: %lu", (unsigned long)touchesMade];
}

-(void)setTouchesForBestScore:(NSUInteger)touchesForBestScore {
    _touchesForBestScore = touchesForBestScore;
    self.touchesBestScoreLabel.text = [NSString stringWithFormat:@"Ideal touches: %lu", (unsigned long)touchesForBestScore];
}

-(void)setTouchesScore:(NSUInteger)touchesScore {
    _touchesScore = touchesScore;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %lu/%d", (unsigned long)touchesScore, self.maxTouchesScore];
}

-(void)setMaxTouchesScore:(NSUInteger)maxTouchesScore {
    _maxTouchesScore = maxTouchesScore;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d/%lu", self.touchesScore, (unsigned long)maxTouchesScore];
}

-(void)setTimeUsed:(float)timeUsed {
    _timeUsed = timeUsed;
    self.timeSpentLabel.text = [NSString stringWithFormat:@"Time Spent: %.1fs", timeUsed];
}

-(void)setTimeForBestScore:(float)timeForBestScore {
    _timeForBestScore = timeForBestScore;
    self.idealTimeLabel.text = [NSString stringWithFormat:@"Ideal time: %.1fs", timeForBestScore];
}

-(void)setBonusScore:(NSUInteger)bonusScore {
    _bonusScore = bonusScore;
    self.bonusScoreLabel.text = [NSString stringWithFormat:@"Time Bonus Score: %lu/%d", (unsigned long)bonusScore, self.maxBonusScore];
}

-(void)setMaxBonusScore:(NSUInteger)maxBonusScore {
    _maxBonusScore = maxBonusScore;
    self.bonusScoreLabel.text = [NSString stringWithFormat:@"Time Bonus Score: %d/%lu", self.bonusScore, (unsigned long)maxBonusScore];
    [self setTotalScoreLabel];
}

-(void)setTotalScoreLabel {
    self.bigScoreLabel.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)(self.touchesScore + self.bonusScore), (unsigned long)
                               (self.maxTouchesScore + self.maxBonusScore)];
}

#pragma mark - Initialization Stuff

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUInteger socialButtonsWidth = frame.size.height/8.8;

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
        titleLabel.font = [UIFont fontWithName:FONT_NAME size:25.0];
        [self addSubview:titleLabel];
        
        //Touches made label
        self.touchesMadeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 80.0, frame.size.width - 40.0, 30.0)];
        self.touchesMadeLabel.text = @"Touches made: 0";
        self.touchesMadeLabel.textColor = [UIColor darkGrayColor];
        self.touchesMadeLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.touchesMadeLabel];
        
        //Touches for best score label
        self.touchesBestScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 110.0, frame.size.width - 40.0, 30.0)];
        self.touchesBestScoreLabel.text = @"Ideal touches: 0";
        self.touchesBestScoreLabel.textColor = [UIColor darkGrayColor];
        self.touchesBestScoreLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.touchesBestScoreLabel];
        
        //Black line view
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 140.0, frame.size.width - 40.0, 1.0)];
        lineView.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
        [self addSubview:lineView];
        
        //Score label
        self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 140.0, frame.size.width - 40.0, 30.0)];
        self.scoreLabel.text = @"Score: 0/0";
        self.scoreLabel.textColor = [[AppInfo sharedInstance] appColorsArray][2];
        self.scoreLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.scoreLabel];
        
        //time spent label
        self.timeSpentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 190.0, frame.size.width - 40.0, 30.0)];
        self.timeSpentLabel.text = @"Time spent: 0.0s";
        self.timeSpentLabel.textColor = [UIColor darkGrayColor];
        self.timeSpentLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.timeSpentLabel];
        
        //Ideal time label
        self.idealTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 220.0, frame.size.width - 40.0, 30.0)];
        self.idealTimeLabel.text = @"Ideal time: 0.0s";
        self.idealTimeLabel.textColor = [UIColor darkGrayColor];
        self.idealTimeLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:self.idealTimeLabel];
        
        //Black line view
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(20.0, 250.0, frame.size.width - 40.0, 1.0)];
        lineView2.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
        [self addSubview:lineView2];
        
        //Bonus score label
        self.bonusScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 250.0, frame.size.width - 20.0, 30.0)];
        self.bonusScoreLabel.text = @"Time Bonus Score: 0/0";
        self.bonusScoreLabel.textColor = [[AppInfo sharedInstance] appColorsArray][2];
        self.bonusScoreLabel.font = [UIFont fontWithName:FONT_NAME size:18.0];
        [self addSubview:self.bonusScoreLabel];
        
        //Total Score label
        UILabel *totalScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, frame.size.height - frame.size.height/2.93, frame.size.width - 40.0, 20.0)];
        totalScoreLabel.text = @"Total Score";
        totalScoreLabel.textColor = [UIColor darkGrayColor];
        totalScoreLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        totalScoreLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:totalScoreLabel];
        
        //Big Score label
        self.bigScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, totalScoreLabel.frame.origin.y + totalScoreLabel.frame.size.height - 10.0, frame.size.width - 40.0, 60.0)];
        self.bigScoreLabel.text = @"0/0";
        self.bigScoreLabel.textAlignment = NSTextAlignmentCenter;
        self.bigScoreLabel.textColor = [[AppInfo sharedInstance] appColorsArray][2];
        self.bigScoreLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
        [self addSubview:self.bigScoreLabel];
        
        //Faebook button
        UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, frame.size.height - (socialButtonsWidth + 10.0), socialButtonsWidth, socialButtonsWidth)];
        [facebookButton setBackgroundImage:[UIImage imageNamed:@"FacebookLogo.png"] forState:UIControlStateNormal];
        [facebookButton addTarget:self action:@selector(facebookButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:facebookButton];
     
        //Twitter button
        UIButton *twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(facebookButton.frame.origin.x + facebookButton.frame.size.width + 10.0, frame.size.height - (socialButtonsWidth + 10.0), socialButtonsWidth, socialButtonsWidth)];
        [twitterButton setBackgroundImage:[UIImage imageNamed:@"TwitterLogo.gif"] forState:UIControlStateNormal];
        [twitterButton addTarget:self action:@selector(twitterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:twitterButton];
        
        //Challenge button
        UIButton *challengeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 100.0, frame.size.height - (socialButtonsWidth + 10.0), socialButtonsWidth, socialButtonsWidth)];
        [challengeButton setBackgroundImage:[UIImage imageNamed:@"ChallengeIcon.png"] forState:UIControlStateNormal];
        [challengeButton addTarget:self action:@selector(challengeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:challengeButton];
        
        //Share label
        UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, facebookButton.frame.origin.y - 30.0, 125.0, 30.0)];
        shareLabel.text = @"Share";
        shareLabel.textColor = [UIColor darkGrayColor];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:shareLabel];
        
        //Challenge label
        UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2.0, challengeButton.frame.origin.y - 30.0, frame.size.width/2.0, 30.0)];
        challengeLabel.text = @"Challenge";
        challengeLabel.textColor = [UIColor darkGrayColor];
        challengeLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        challengeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:challengeLabel];
        
        //Continue Button
        UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 47.0, -32.0, 80.0, 80.0)];
        [continueButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
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
                         [self removeFromSuperview];
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

@end
