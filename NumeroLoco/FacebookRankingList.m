//
//  FacebookRankingList.m
//  NumeroLoco
//
//  Created by Diego Vidal on 8/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FacebookRankingList.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendsCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface FacebookRankingList() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation FacebookRankingList

#define CELL_IDENTIFIER @"cellID"

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        closeButton.layer.borderWidth = 1.0;
        closeButton.layer.cornerRadius = 10.0;
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];

        //Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, frame.size.width, 40.0)];
        title.text = @"Rankings";
        title.textColor = [UIColor colorWithRed:56.0/255.0 green:78.0/255.0 blue:140.0/255.0 alpha:1.0];
        title.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        //Invite friends button
        UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 80.0, 34.0, 70.0, 35.0)];
        [inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        inviteButton.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:78.0/255.0 blue:140.0/255.0 alpha:1.0];
        inviteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        inviteButton.layer.cornerRadius = 10.0;
        [inviteButton addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:inviteButton];
        
        //Table view
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 80.0, frame.size.width, frame.size.height - 70.0) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 80.0;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView registerClass:[FriendsCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
        self.tableView.layer.cornerRadius = 10.0;
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.friendName.text = self.resultsArray[indexPath.row][@"name"];
    cell.friendScore.text = [self.resultsArray[indexPath.row][@"score"] description];
    
    //Get friend image
    NSString *photoPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", self.resultsArray[indexPath.row][@"userID"]];
    NSURL *photoURL = [NSURL URLWithString:photoPath];
    [cell.friendImageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:@"ProfilePic.png"]];
    return cell;
}

-(void)inviteFriends {
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Hey! I'm playing Cross for iOS, try to beat my score!"
                                                    title:nil parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Error sending request: %@ %@", error, [error localizedDescription]);
                                                        } else {
                                                            if (result == FBWebDialogResultDialogNotCompleted) {
                                                                NSLog(@"User cancelled the request");
                                                            } else {
                                                                NSLog(@"Result URL: %@", resultURL);
                                                            }
                                                        }
                                                    }];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.8;
                     } completion:nil];
}

-(void)closeView {
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

@end
