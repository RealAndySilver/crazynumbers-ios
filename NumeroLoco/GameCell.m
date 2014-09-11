//
//  GameCell.m
//  NumeroLoco
//
//  Created by Diego Vidal on 2/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameCell.h"

@implementation GameCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.gameNumberLabel = [[UILabel alloc] init];
        self.gameNumberLabel.textColor = [UIColor darkGrayColor];
        self.gameNumberLabel.layer.cornerRadius = 10.0;
        self.gameNumberLabel.textAlignment = NSTextAlignmentCenter;
        self.gameNumberLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.gameNumberLabel.layer.borderWidth = 1.0;
        self.gameNumberLabel.clipsToBounds = YES;
        [self.contentView addSubview:self.gameNumberLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.gameNumberLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
}

@end
