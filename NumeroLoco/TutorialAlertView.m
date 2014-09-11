//
//  TutorialAlertView.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "TutorialAlertView.h"
#import "AppInfo.h"

@interface TutorialAlertView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation TutorialAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        // Initialization code
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, frame.size.height - 80.0)];
        self.textView.textColor = [UIColor darkGrayColor];
        self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        self.textView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textView];
        
        //accept button
        self.acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - 40.0, frame.size.height - 60.0, 80.0, 40.0)];
        [self.acceptButton setTitle:@"Ok" forState:UIControlStateNormal];
        [self.acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.acceptButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        self.acceptButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        self.acceptButton.layer.cornerRadius = 10.0;
        [self.acceptButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.acceptButton];
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
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)closeView {
    [self.delegate acceptButtonPressedInAlert:self];
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

@end
