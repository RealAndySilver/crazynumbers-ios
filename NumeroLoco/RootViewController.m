//
//  RootViewController.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "RootViewController.h"
#import "ChaptersViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController {
    CGRect screenBounds;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    for (NSString *family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        for (NSString *font in [UIFont fontNamesForFamilyName:family])
        {
            NSLog(@"\t%@", font);
        }
    }
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)setupUI {
    //Big NUmber Label
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 65.0, screenBounds.size.width - 130.0, screenBounds.size.width - 130.0)];
    numberLabel.text = @"5";
    numberLabel.layer.cornerRadius = 10.0;
    numberLabel.layer.borderWidth = 1.0;
    numberLabel.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0].CGColor;
    numberLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:1.0];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:200.0];
    [self.view addSubview:numberLabel];
    
    //Main title
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 260.0, screenBounds.size.width - 40.0, 40.0)];
    mainTitle.text = @"Numero Loco";
    mainTitle.textAlignment = NSTextAlignmentCenter;
    mainTitle.textColor = [UIColor lightGrayColor];
    mainTitle.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:28.0];
    [self.view addSubview:mainTitle];
    
    //Start Option
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    startButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    startButton.layer.borderWidth = 1.0;
    startButton.layer.cornerRadius = 4.0;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
    startButton.frame = CGRectMake(screenBounds.size.width/2.0 - 50.0, screenBounds.size.height - 130.0, 100.0, 40.0);
    [startButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    //Options
    UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    optionsButton.layer.borderWidth = 1.0;
    optionsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    optionsButton.layer.cornerRadius = 4.0;
    [optionsButton setTitle:@"Options" forState:UIControlStateNormal];
    [optionsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    optionsButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
    optionsButton.frame = CGRectMake(screenBounds.size.width/2.0 - 50.0, screenBounds.size.height - 80.0, 100.0, 40.0);
    [self.view addSubview:optionsButton];
}

#pragma mark - Actions

-(void)goToChaptersVC {
    ChaptersViewController *chaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapters"];
    chaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:chaptersVC animated:YES completion:nil];
}

@end
