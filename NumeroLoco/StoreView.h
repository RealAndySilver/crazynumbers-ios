//
//  StoreView.h
//  NumeroLoco
//
//  Created by Developer on 11/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreView : UIView
-(void)showInView:(UIView *)view;
@property (strong, nonatomic) NSDictionary *purchasesDic;
@end
