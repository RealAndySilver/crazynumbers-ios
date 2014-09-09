//
//  FacebookRankingList.m
//  NumeroLoco
//
//  Created by Diego Vidal on 8/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FacebookRankingList.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface FacebookRankingList()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation FacebookRankingList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 47.0, -32.0, 80.0, 80.0)];
        [closeButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];

        //Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 40.0)];
        title.text = @"Rankings";
        title.textColor = [UIColor colorWithRed:56.0/255.0 green:78.0/255.0 blue:140.0/255.0 alpha:1.0];
        title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        //Invite friends button
        UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 24.0, 70.0, 35.0)];
        [inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        inviteButton.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:78.0/255.0 blue:140.0/255.0 alpha:1.0];
        inviteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        inviteButton.layer.cornerRadius = 10.0;
        [inviteButton addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:inviteButton];
    }
    return self;
}

-(void)inviteFriends {
    [FBWebDialogs presentRequestsDialogModallyWithSession:[PFFacebookUtils session] message:@"Hey! I'm playing Cross for iOS, try to beat my score!"
                                                    title:nil parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                        
                                                    }];
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
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.8;
                     } completion:nil];
}

-(void)closeView {
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

@end
