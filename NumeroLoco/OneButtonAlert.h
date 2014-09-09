//
//  OneButtonAlert.h
//  MiRed
//
//  Created by Diego Vidal on 22/08/14.
//  Copyright (c) 2014 Diego Fernando Vidal Illera. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OneButtonAlert;

@protocol OneButtonAlertDelegate <NSObject>
-(void)buttonClickedInAlert:(OneButtonAlert *)oneButtonAlert;
-(void)oneButtonAlertDidDisappear:(OneButtonAlert *)oneButtonAlert;
@end

@interface OneButtonAlert : UIView
@property (strong, nonatomic) id <OneButtonAlertDelegate> delegate;
@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) NSString *alertText;
-(void)showInView:(UIView *)view;
@end