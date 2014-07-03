//
//  ColorPatternView.h
//  NumeroLoco
//
//  Created by Developer on 27/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  ColorPatternView;

@protocol ColorPatternViewDelegate <NSObject>
-(void)colorPatternViewWillDissapear:(ColorPatternView *)colorPatternView;
-(void)colorPatternViewDidDissapear:(ColorPatternView *)colorPatternView;
@end

@interface ColorPatternView : UIView
@property (strong, nonatomic) id <ColorPatternViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame colorsArray:(NSArray *)colorsArray; //Of UIColor
-(void)showinView:(UIView *)view;
@end
