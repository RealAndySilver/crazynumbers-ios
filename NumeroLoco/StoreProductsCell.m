//
//  StoreProductsCell.m
//  NumeroLoco
//
//  Created by Developer on 11/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "StoreProductsCell.h"

@implementation StoreProductsCell

#define FONT_NAME @"HelveticaNeue-Light"

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //Product image view
        self.productImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.productImageView];
        
        //Product Name
        self.productName = [[UILabel alloc] init];
        self.productName.textColor = [UIColor darkGrayColor];
        self.productName.font = [UIFont fontWithName:FONT_NAME size:15.0];
        self.productName.numberOfLines = 0;
        [self.contentView addSubview:self.productName];
        
        //Buy button
        self.buyButton = [[UIButton alloc] init];
        [self.buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buyButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        self.buyButton.layer.cornerRadius = 10.0;
        [self.buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.buyButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.productImageView.frame = CGRectMake(20.0, 10.0, bounds.size.height - 20.0, bounds.size.height - 20.);
    self.productName.frame = CGRectMake(self.productImageView.frame.origin.x + self.productImageView.frame.size.width + 10., 10.0, 100.0, bounds.size.height - 20.0);
    self.buyButton.frame = CGRectMake(bounds.size.width - 80.0, bounds.size.height/2.0 - 20.0, 70.0, 40.0);
}

-(void)buyButtonPressed {
    NSLog(@"Presioné el botooon");
    [self.delegate buyButtonPressedInCell:self];
}

@end
