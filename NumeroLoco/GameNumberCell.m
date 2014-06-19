//
//  GameNumberCell.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GameNumberCell.h"

@implementation GameNumberCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gameLabel = [[UILabel alloc] init];
        self.gameLabel.layer.cornerRadius = 4.0;
        self.gameLabel.layer.borderWidth = 1.0;
        self.gameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.gameLabel.textColor = [UIColor lightGrayColor];
        self.gameLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:40.0];
        self.gameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.gameLabel];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentBounds = self.contentView.bounds;
    self.gameLabel.frame = CGRectMake(0.0, 0.0, contentBounds.size.width, contentBounds.size.height);
}

@end
