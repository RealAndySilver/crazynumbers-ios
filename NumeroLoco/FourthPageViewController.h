//
//  FourthPageViewController.h
//  NumeroLoco
//
//  Created by Diego Vidal on 1/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FourthPageDelegate <NSObject>
-(void)fourthPageBackButtonPressed;
-(void)fourthPageContinueButtonPressed;
@end

@interface FourthPageViewController : UIViewController
@property (strong, nonatomic) id <FourthPageDelegate> delegate;
@end
