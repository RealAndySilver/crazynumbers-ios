//
//  StoreProductsCell.h
//  NumeroLoco
//
//  Created by Developer on 11/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StoreProductsCell;

@protocol StoreProductsCellDelegate <NSObject>
-(void)buyButtonPressedInCell:(StoreProductsCell *)storeProductsCell;
@end

@interface StoreProductsCell : UITableViewCell
@property (strong, nonatomic) id <StoreProductsCellDelegate> delegate;
@property (strong, nonatomic) UIImageView *productImageView;
@property (strong, nonatomic) UILabel *productName;
@property (strong, nonatomic) UIButton *buyButton;
@end
