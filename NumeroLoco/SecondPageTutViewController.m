//
//  SecondPageTutViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SecondPageTutViewController.h"
#import "AppInfo.h"
#import "AudioPlayer.h"

@interface SecondPageTutViewController ()

@end

@implementation SecondPageTutViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    CGRect titleLabelRect;
    CGRect descriptionLabelRect;
    CGFloat fontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontSize = 30.0;
        titleLabelRect = CGRectMake(80.0, 60.0, self.view.bounds.size.width - 160.0, 100.0);
        descriptionLabelRect = CGRectMake(80.0, self.view.bounds.size.height - 250.0, self.view.bounds.size.width - 160.0, 150.0);
    } else {
        fontSize = 15.0;
        titleLabelRect = CGRectMake(self.view.bounds.size.width/2.0 - 120.0, 50.0, 240.0, 100.0);
        descriptionLabelRect = CGRectMake(self.view.bounds.size.width/2.0 - 130.0, self.view.bounds.size.height - 190.0, 260.0, 100.0);
    }
    
    //Tutorial image
    UIImageView *tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialPhoneR4_2.png"]];
    tutorialImageView.frame = self.view.bounds;
    tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tutorialImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
    titleLabel.text = NSLocalizedString(@"Numbers Game\nObjective: Set all the buttons to zero", @"Explanation of numbers game");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:titleLabel];
    
    //other label
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:descriptionLabelRect];
    descriptionLabel.text = NSLocalizedString(@"By touching a button, its value will decrease by one, as well as the value of the upper, left, lower and right buttons", @"a description of numbers game");
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
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 120.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [continueButton setTitle:NSLocalizedString(@"Continue", @"Continue") forState:UIControlStateNormal];
    [continueButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    continueButton.layer.cornerRadius = 10.0;
    continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    continueButton.layer.borderWidth = 1.0;
    [continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(50.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [backButton setTitle:NSLocalizedString(@"Back", @"Back button") forState:UIControlStateNormal];
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
    [[AudioPlayer sharedInstance] playPressSound];
    [self.delegate secondPageContinueButtonPressed];
}

-(void)backButtonPressed {
    [[AudioPlayer sharedInstance] playPressSound];
    [self.delegate secondPageBackButtonPressed];
}

-(void)closeButtonPressed {
    [[AudioPlayer sharedInstance] playBackSound];
    [self.delegate secondPageCloseButtonPressed];
}

@end
