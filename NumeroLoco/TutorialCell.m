//
//  TutorialCell.m
//  NumeroLoco
//
//  Created by Developer on 1/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "TutorialCell.h"

@implementation TutorialCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        // Initialization code
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    self.imageView.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
}

@end
