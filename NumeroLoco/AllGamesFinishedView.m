//
//  AllGamesFinishedView.m
//  NumeroLoco
//
//  Created by Developer on 12/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AllGamesFinishedView.h"
#import "AppInfo.h"

@interface AllGamesFinishedView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation AllGamesFinishedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        //Close Button
        self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.closeButton.frame = CGRectMake(frame.size.width/2.0 - 75.0, frame.size.height - 130.0, 150.0, 60.0);
        [self.closeButton setTitle:@"Accept" forState:UIControlStateNormal];
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.closeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        self.closeButton.layer.cornerRadius = 10.0;
        self.closeButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        [self.closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        //Congratulations label
        self.congratsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, frame.size.width - 40.0, 30.0)];
        self.congratsLabel.text = @"Congratulations!";
        self.congratsLabel.textColor = [UIColor whiteColor];
        self.congratsLabel.textAlignment = NSTextAlignmentCenter;
        self.congratsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0];
        [self addSubview:self.congratsLabel];
        
        //Message label
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 120.0, frame.size.width - 40.0, 100.0)];
        self.messageLabel.text = @"You have completed all games! Wait for more games soon!";
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        [self addSubview:self.messageLabel];
    }
    return self;
}

#pragma mark - Actions 

-(void)closeView {
    [self.delegate gameFinishedViewWillDissapear:self];
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
                         [self.delegate gameFinishedViewDidDissapear:self];
                     }];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 1.0;
                         self.opacityView.alpha = 0.9;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL success){}];
}

@end
