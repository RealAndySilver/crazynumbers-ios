//
//  FirstPageTutViewController.h
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FirstPageTutDelegate <NSObject>
-(void)firstPageButtonPressed;
@end

@interface FirstPageTutViewController : UIViewController
@property (strong, nonatomic) id <FirstPageTutDelegate> delegate;
@end
