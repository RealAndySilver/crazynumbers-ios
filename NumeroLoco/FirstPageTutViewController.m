//
//  FirstPageTutViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FirstPageTutViewController.h"
#import "AppInfo.h"

@interface FirstPageTutViewController ()

@end

@implementation FirstPageTutViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI {
    //Tutorial image
    UIImageView *tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TutorialPhoneR4_1.png"]];
    tutorialImageView.frame = self.view.bounds;
    tutorialImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:tutorialImageView];
    
    UIButton *continueButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 35.0, self.view.bounds.size.height - 90.0, 70.0, 40.0)];
    [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [continueButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][2] forState:UIControlStateNormal];
    continueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    continueButton.layer.cornerRadius = 10.0;
    continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][2]).CGColor;
    continueButton.layer.borderWidth = 1.0;
    [continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}

#pragma mark - Actions 

-(void)continueButtonPressed {
    [self.delegate firstPageButtonPressed];
}

@end
