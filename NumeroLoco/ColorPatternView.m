//
//  ColorPatternView.m
//  NumeroLoco
//
//  Created by Developer on 27/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ColorPatternView.h"

@interface ColorPatternView()
@property (strong, nonatomic) UIView *colorView1;
@property (strong, nonatomic) UIView *colorView2;
@property (strong, nonatomic) UIView *colorView3;
@property (strong, nonatomic) UIView *colorView4;
@property (strong, nonatomic) UIView *colorView5;
@property (strong, nonatomic) UIView *colorView6;
@end

@implementation ColorPatternView

-(instancetype)initWithFrame:(CGRect)frame colorsArray:(NSArray *)colorsArray {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.layer.cornerRadius = 10.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.alpha = 0.0;
        
        self.colorView1 = [[UIView alloc] initWithFrame:CGRectMake(20.0, 20.0, frame.size.width - 40.0, 50.0)];
        self.colorView1.backgroundColor = colorsArray[5];
        self.colorView1.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView1];
        
        self.colorView2 = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.colorView1.frame.origin.y + self.colorView1.frame.size.height + 10.0, frame.size.width - 40.0, 50.0)];
        self.colorView2.backgroundColor = colorsArray[4];
        self.colorView2.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView2];
        
        self.colorView3 = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.colorView2.frame.origin.y + self.colorView2.frame.size.height + 10.0, frame.size.width - 40.0, 50.0)];
        self.colorView3.backgroundColor = colorsArray[3];
        self.colorView3.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView3];
        
        self.colorView4 = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.colorView3.frame.origin.y + self.colorView3.frame.size.height + 10.0, frame.size.width - 40.0, 50.0)];
        self.colorView4.backgroundColor = colorsArray[2];
        self.colorView4.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView4];
        
        self.colorView5 = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.colorView4.frame.origin.y + self.colorView4.frame.size.height + 10.0, frame.size.width - 40.0, 50.0)];
        self.colorView5.backgroundColor = colorsArray[1];
        self.colorView5.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView5];
        
        self.colorView6 = [[UIView alloc] initWithFrame:CGRectMake(20.0, self.colorView5.frame.origin.y + self.colorView5.frame.size.height + 10.0, frame.size.width - 40.0, 50.0)];
        self.colorView6.backgroundColor = colorsArray[0];
        self.colorView6.layer.cornerRadius = 5.0;
        [self addSubview:self.colorView6];
        
        //Close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        closeButton.frame = CGRectMake(frame.size.width/2.0 - 35.0, frame.size.height - 50.0, 70.0, 40.0);
        closeButton.layer.cornerRadius = 10.0;
        closeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        closeButton.layer.borderWidth = 1.0;
        closeButton.backgroundColor = [UIColor clearColor];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [closeButton addTarget:self action:@selector(closeColorView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
    }
    return self;
}

-(void)showinView:(UIView *)view {
    [view addSubview:self];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.alpha = 1.0;
                     } completion:^(BOOL finished){}];
}

-(void)closeColorView {
    [self.delegate colorPatternViewWillDissapear:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^(){
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.alpha = 0.0;
                     } completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [self.delegate colorPatternViewDidDissapear:self];
                     }];
}

@end
