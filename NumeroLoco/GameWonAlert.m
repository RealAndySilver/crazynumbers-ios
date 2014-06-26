//
//  GameWonAlert.m
//  NumeroLoco
//
//  Created by Developer on 26/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameWonAlert.h"

@implementation GameWonAlert

/*- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
        self.layer.cornerRadius = 4.0;
        
        //Title Label
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 40.0)];
        titleLabel.text = @"Game Won!";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [self addSubview:titleLabel];
    }
    return self;
}*/

+(void)showInView:(UIView *)view {
    UIView *alert = [[UIView alloc] initWithFrame:CGRectMake(view.frame.size.width, view.frame.size.height/2.0 - 75.0, 250.0, 150.0)];
    alert.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
    alert.layer.cornerRadius = 10.0;
    [view addSubview:alert];
    
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, alert.frame.size.width, alert.frame.size.height)];
    mainTitle.text = @"Game Won!";
    mainTitle.textColor = [UIColor whiteColor];
    mainTitle.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:35.0];
    mainTitle.textAlignment = NSTextAlignmentCenter;
    [alert addSubview:mainTitle];
    alert.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         alert.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         alert.transform = CGAffineTransformMakeTranslation(-(view.frame.size.width/2.0 + alert.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:3.0 animations:^(){} completion:^(BOOL finished){
                             [UIView animateWithDuration:1.0
                                                   delay:0.0
                                  usingSpringWithDamping:0.7
                                   initialSpringVelocity:0.0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^(){
                                                  alert.transform = CGAffineTransformMakeScale(0.5, 0.5);
                                                  alert.transform = CGAffineTransformMakeTranslation(-(view.frame.size.width + alert.frame.size.width*2), 0.0);

                                              } completion:^(BOOL finished){
                                                  [alert removeFromSuperview];
                                              }];
                         }];
                     }];
}

@end
