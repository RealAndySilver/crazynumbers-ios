//
//  BuyLivesView.h
//  NumeroLoco
//
//  Created by Diego Vidal on 26/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BuyLivesView;

@protocol BuyLivesViewDelegate <NSObject>
-(void)moreLivesBought:(NSUInteger)livesAvailable inView:(BuyLivesView *)buyLivesView;
-(void)infiniteModeBoughtInView:(BuyLivesView *)buyLivesView;
-(void)buyLivesViewDidDisappear:(BuyLivesView *)buyLivesView;
@end

@interface BuyLivesView : UIView
@property (strong, nonatomic) id <BuyLivesViewDelegate> delegate;
-(void)showInView:(UIView *)view;
-(instancetype)initWithFrame:(CGRect)frame pricesDic:(NSDictionary *)pricesDic;
@end
