//
//  SecondPageTutViewController.h
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SecondPageTutDelegate <NSObject>
-(void)secondPageContinueButtonPressed;
-(void)secondPageBackButtonPressed;
@end

@interface SecondPageTutViewController : UIViewController
@property (strong, nonatomic) id <SecondPageTutDelegate> delegate;
@end
