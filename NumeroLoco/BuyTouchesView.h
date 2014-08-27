//
//  BuyTouchesView.h
//  NumeroLoco
//
//  Created by Diego Vidal on 21/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BuyTouchesView;

@protocol BuyTouchesViewDelegate <NSObject>
-(void)closeButtonPressedInView:(BuyTouchesView *)buyTouchesView;
-(void)buyTouchesViewDidDisappear:(BuyTouchesView *)buyTouchesView;
-(void)moreTouchesBought:(NSUInteger)touchesAvailable inView:(BuyTouchesView *)buyTouchesView;
-(void)infiniteTouchesBoughtInView:(BuyTouchesView *)buyTouchesView;
@end

@interface BuyTouchesView : UIView
@property (strong, nonatomic)id <BuyTouchesViewDelegate> delegate;
-(void)showInView:(UIView *)view;
-(instancetype)initWithFrame:(CGRect)frame pricesDic:(NSDictionary *)pricesDic;
@end
