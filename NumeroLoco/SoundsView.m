//
//  SoundsView.m
//  NumeroLoco
//
//  Created by Developer on 18/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SoundsView.h"
#import "AppInfo.h"

@interface SoundsView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation SoundsView

#define FONT_NAME @"HelveticaNeue-UltraLight"
#define ANIMATION_DURATION 0.5

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        
        //Title
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, frame.size.width, 40.0)];
        titleLabel.text = @"Sounds";
        titleLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
        titleLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        closeButton.layer.borderWidth = 1.0;
        closeButton.layer.cornerRadius = 10.0;
        [closeButton addTarget:self action:@selector(closeAlert) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //In-Game music label
        UILabel *musicLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 30.0, 170.0, 40.0)];
        musicLabel.text = @"In-Game Music";
        musicLabel.textColor = [UIColor darkGrayColor];
        musicLabel.font = [UIFont fontWithName:FONT_NAME size:25.0];
        [self addSubview:musicLabel];
        
        //music switch
        UISwitch *musicSwitch = [[UISwitch alloc] init];
        musicSwitch.on = [self getMusicSelectionInUserDefaults];
        musicSwitch.center = CGPointMake(frame.size.width - 50.0, musicLabel.center.y);
        musicSwitch.onTintColor = [[AppInfo sharedInstance] appColorsArray][0];
        [musicSwitch addTarget:self action:@selector(musicSwitchPressed:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:musicSwitch];
        
        //Tic-Toc label
        UILabel *tictocLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 100.0, 170.0, 40.0)];
        tictocLabel.text = @"Tic-Toc Sound";
        tictocLabel.textColor = [UIColor darkGrayColor];
        tictocLabel.font = [UIFont fontWithName:FONT_NAME size:25.0];
        [self addSubview:tictocLabel];
        
        //Tic Toc Switch
        UISwitch *tictocSwitch = [[UISwitch alloc] init];
        tictocSwitch.on = [self getTictocSelectionInUserDefaults];
        tictocSwitch.center = CGPointMake(frame.size.width - 50.0, tictocLabel.center.y);
        tictocSwitch.onTintColor = [[AppInfo sharedInstance] appColorsArray][0];
        [tictocSwitch addTarget:self action:@selector(tictocSwitchPressed:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:tictocSwitch];

    }
    return self;
}

#pragma mark - Actions 

-(void)tictocSwitchPressed:(UISwitch *)theSwitch {
    //Save bool value in UserDefaults
    [self saveTictocSelectionInUserDefaults:[theSwitch isOn]];
}

-(void)musicSwitchPressed:(UISwitch *)theSwitch {
    [self saveMusicSelectionInUserDefaults:[theSwitch isOn]];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.7;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:nil];
}

-(void)closeAlert {
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.opacityView.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [self.opacityView removeFromSuperview];
                             [self removeFromSuperview];
                         }
                     }];
}

#pragma mark - UserDefaults 

-(BOOL)getTictocSelectionInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tictocActive"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"tictocActive"] boolValue];
    } else {
        return YES;
    }
}

-(BOOL)getMusicSelectionInUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"musicActive"]) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"musicActive"] boolValue];
    } else {
        return YES;
    }
}

-(void)saveTictocSelectionInUserDefaults:(BOOL)tictocActive {
    [[NSUserDefaults standardUserDefaults] setObject:@(tictocActive) forKey:@"tictocActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveMusicSelectionInUserDefaults:(BOOL)musicActive {
    [[NSUserDefaults standardUserDefaults] setObject:@(musicActive) forKey:@"musicActive"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
