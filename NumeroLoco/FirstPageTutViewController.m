//
//  FirstPageTutViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FirstPageTutViewController.h"
#import "AppInfo.h"
#import "AudioPlayer.h"

@interface FirstPageTutViewController ()

@end

@implementation FirstPageTutViewController {
    BOOL isPad;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    CGRect titleLabelRect;
    CGRect descriptionLabelRect;
    CGFloat fontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        fontSize = 30;
        titleLabelRect = CGRectMake(80.0, 60.0, self.view.bounds.size.width - 160.0, 100.0);
        descriptionLabelRect = CGRectMake(80.0, self.view.bounds.size.height - 230.0, self.view.bounds.size.width - 160.0, 100.0);
    } else {
        isPad = NO;
        fontSize = 15.0;
        titleLabelRect = CGRectMake(self.view.bounds.size.width/2.0 - 120.0, 50.0, 240.0, 100.0);
        descriptionLabelRect = CGRectMake(self.view.bounds.size.width/2.0 - 120.0, self.view.bounds.size.height - 180.0, 240.0, 100.0);
    }
    //Tutorial image
    UIImageView *tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialPhoneR4_1.png"]];
    tutorialImageView.frame = self.view.bounds;
    tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tutorialImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    titleLabel.text = NSLocalizedString(@"Welcome to Cross, a simple, yet addictive game!", @"A welcome message");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:titleLabel];
    
    //other label
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:descriptionLabelRect];
    descriptionLabel.text = NSLocalizedString(@"There are two types of games: Numbers and Colors", @"Explanation of the game");
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    descriptionLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:descriptionLabel];
    
    //Close button
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
    closeButton.layer.borderWidth = 1.0;
    closeButton.layer.cornerRadius = 10.0;
    closeButton.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 35.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [continueButton setTitle:NSLocalizedString(@"Continue", @"Continue button") forState:UIControlStateNormal];
    [continueButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    continueButton.layer.cornerRadius = 10.0;
    continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    continueButton.layer.borderWidth = 1.0;
    [continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}

#pragma mark - Actions 

-(void)continueButtonPressed {
    [[AudioPlayer sharedInstance] playPressSound];
    [self.delegate firstPageButtonPressed];
}

-(void)closeButtonPressed {
    [[AudioPlayer sharedInstance] playBackSound];
    [self.delegate firstPageCloseButtonPressed];
}

@end
