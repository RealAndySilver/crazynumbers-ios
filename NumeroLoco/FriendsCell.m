//
//  FriendsCell.m
//  NumeroLoco
//
//  Created by Developer on 28/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FriendsCell.h"

@implementation FriendsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //Friend Image View
        self.friendImageView = [[UIImageView alloc] init];
        self.friendImageView.clipsToBounds = YES;
        self.friendImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.friendImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.friendImageView.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.friendImageView];
        
        //Name Label
        self.friendName = [[UILabel alloc] init];
        self.friendName.textColor = [UIColor darkGrayColor];
        self.friendName.numberOfLines = 0;
        self.friendName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [self.contentView addSubview:self.friendName];
        
        //Points label
        self.friendScore = [[UILabel alloc] init];
        self.friendScore.textColor = [UIColor blackColor];
        self.friendScore.adjustsFontSizeToFitWidth = YES;
        self.friendScore.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [self.contentView addSubview:self.friendScore];
        
        //Rank label
        /*self.rankLabel = [[UILabel alloc] init];
        self.rankLabel.textColor = [UIColor blackColor];
        self.rankLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        [self.contentView addSubview:self.rankLabel];*/
        
        //Checkmark
        /*self.checkmark = [[UIImageView alloc] init];
        self.checkmark.contentMode = UIViewContentModeScaleAspectFit;
        self.checkmark.image = [UIImage imageNamed:@"checkmark.png"];
        self.checkmark.hidden = YES;
        [self.contentView addSubview:self.checkmark];*/
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    //self.checkmark.frame = CGRectMake(20.0, bounds.size.height/2.0 - 10.0, 20.0, 20.0);
    self.friendImageView.frame = CGRectMake(20.0, 15.0, bounds.size.height - 30.0, bounds.size.height - 30.0);
    self.friendImageView.layer.cornerRadius = self.friendImageView.frame.size.width/2.0;
    self.friendName.frame = CGRectMake(self.friendImageView.frame.origin.x + self.friendImageView.frame.size.width + 10.0, bounds.size.height/2.0 - 20.0, bounds.size.width - (self.friendImageView.frame.origin.x + self.friendImageView.frame.size.width + 20.0) - 60, 40.0);
    self.friendScore.frame = CGRectMake(self.friendName.frame.origin.x + self.friendName.frame.size.width + 5.0, bounds.size.height/2.0 - 20.0, 120.0, 40.0);
}

@end
