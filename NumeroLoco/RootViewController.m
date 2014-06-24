//
//  RootViewController.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "RootViewController.h"
#import "ChaptersViewController.h"
#import "ColorsChaptersViewController.h"
#import "AppInfo.h"

@interface RootViewController ()
@property (strong, nonatomic) UIButton *numbersButton;
@property (strong, nonatomic) UIButton *colorsButton;
@property (strong, nonatomic) UIButton *startButton;
@end

@implementation RootViewController {
    CGRect screenBounds;
    BOOL isPad;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
    } else {
        isPad = NO;
    }
    self.navigationController.navigationBarHidden = YES;
    /*for (NSString *family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        for (NSString *font in [UIFont fontNamesForFamilyName:family])
        {
            NSLog(@"\t%@", font);
        }
    }*/
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)setupUI {
    //Big NUmber Label
    UILabel *numberLabel = [[UILabel alloc] init];
    if (isPad) numberLabel.frame = CGRectMake(150.0, 150.0, screenBounds.size.width - 300.0, screenBounds.size.width - 300.0);
    else numberLabel.frame = CGRectMake(65.0, 65.0, screenBounds.size.width - 130.0, screenBounds.size.width - 130.0);
    numberLabel.text = @"5";
    numberLabel.layer.cornerRadius = 10.0;
    numberLabel.layer.borderWidth = 1.0;
    numberLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    numberLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  numberLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:400.0];
    else        numberLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:200.0];
    [self.view addSubview:numberLabel];
    
    //Main title
    UILabel *mainTitle = [[UILabel alloc] init];
    if (isPad) mainTitle.frame = CGRectMake(20.0, 630.0, screenBounds.size.width - 40.0, 70.0);
    else mainTitle.frame = CGRectMake(20.0, 260.0, screenBounds.size.width - 40.0, 40.0);
    mainTitle.text = @"Numero Loco";
    mainTitle.textAlignment = NSTextAlignmentCenter;
    mainTitle.textColor = [UIColor lightGrayColor];
    if (isPad) mainTitle.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:56.0];
    else       mainTitle.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:28.0];
    [self.view addSubview:mainTitle];
    
    //Start Option
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.cornerRadius = 4.0;
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
    self.startButton.frame = CGRectMake(screenBounds.size.width/2.0 - 50.0, screenBounds.size.height - 130.0, 100.0, 40.0);
    [self.startButton addTarget:self action:@selector(animateGameButtons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    //Numbers Button
    self.numbersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.numbersButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.numbersButton.layer.borderWidth = 1.0;
    self.numbersButton.layer.cornerRadius = 4.0;
    [self.numbersButton setTitle:@"Numbers" forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
    self.numbersButton.frame = CGRectMake(screenBounds.size.width, screenBounds.size.height - 180.0, 100.0, 40.0);
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.numbersButton];
    
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.colorsButton.layer.borderWidth = 1.0;
    self.colorsButton.layer.cornerRadius = 4.0;
    [self.colorsButton setTitle:@"Colors" forState:UIControlStateNormal];
    [self.colorsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.colorsButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20.0];
    self.colorsButton.frame = CGRectMake(screenBounds.size.width, screenBounds.size.height - 130.0, 100.0, 40.0);
    [self.colorsButton addTarget:self action:@selector(goToColorsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.colorsButton];
    
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

-(void)animateGameButtons {
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.startButton.transform = CGAffineTransformMakeTranslation(-(self.startButton.frame.origin.x + self.startButton.frame.size.width), 0.0);
                         self.numbersButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.numbersButton.frame.size.width/2.0), 0.0);
                         self.colorsButton.transform = CGAffineTransformMakeTranslation(-(screenBounds.size.width/2.0 + self.colorsButton.frame.size.width/2.0), 0.0);
                     } completion:^(BOOL finished){}];
}

-(void)goToColorsChaptersVC {
    ColorsChaptersViewController *colorsChaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ColorsChapters"];
    colorsChaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorsChaptersVC animated:YES completion:nil];
}

-(void)goToChaptersVC {
    ChaptersViewController *chaptersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Chapters"];
    chaptersVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:chaptersVC animated:YES completion:nil];
}

@end
