//
//  SecondPageTutViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SecondPageTutViewController.h"
#import "AppInfo.h"

@interface SecondPageTutViewController ()

@end

@implementation SecondPageTutViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    //Tutorial image
    UIImageView *tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialPhoneR4_2.png"]];
    tutorialImageView.frame = self.view.bounds;
    tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tutorialImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 120.0, 50.0, 240.0, 100.0)];
    titleLabel.text = @"Numbers Game\nObjective: Set all the buttons to zero";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:titleLabel];
    
    //other label
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 130.0, self.view.bounds.size.height - 190.0, 260.0, 100.0)];
    descriptionLabel.text = @"By touching a button, its value will decrease by one, as well as the value of the upper, left, bottom and right buttons";
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
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
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    continueButton.layer.cornerRadius = 10.0;
    continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    continueButton.layer.borderWidth = 1.0;
    [continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    backButton.layer.cornerRadius = 10.0;
    backButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    backButton.layer.borderWidth = 1.0;
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - Actions 

-(void)continueButtonPressed {
    [self.delegate secondPageContinueButtonPressed];
}

-(void)backButtonPressed {
    [self.delegate secondPageBackButtonPressed];
}

-(void)closeButtonPressed {
    [self.delegate secondPageCloseButtonPressed];
}

@end
