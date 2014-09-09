//
//  FacebookRankingList.h
//  NumeroLoco
//
//  Created by Diego Vidal on 8/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookRankingList : UIView
@property (strong, nonatomic) NSArray *resultsArray;
-(void)showInView:(UIView *)view;
@end
