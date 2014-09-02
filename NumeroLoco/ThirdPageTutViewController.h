//
//  ThirdPageTutViewController.h
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThirdPageDelegate <NSObject>
-(void)thirdPageBackButtonPressed;
-(void)thirdPageContinueButtonPressed;
@end

@interface ThirdPageTutViewController : UIViewController
@property (strong, nonatomic) id <ThirdPageDelegate> delegate;
@end
