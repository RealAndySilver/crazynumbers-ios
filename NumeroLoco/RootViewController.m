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
@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourthLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (strong, nonatomic) UIButton *numbersButton;
@property (strong, nonatomic) UIButton *colorsButton;
@property (strong, nonatomic) UIButton *startButton;
@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

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
    self.view.backgroundColor = [UIColor colorWithWhite:0.07 alpha:1.0];
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
    ///////////////////////////////////////////////////////////////////////////////////////////
    //Numbers labels
    //5 label
    self.firstLabel.text = @"4";
    self.firstLabel.backgroundColor = [UIColor clearColor];
    self.firstLabel.layer.cornerRadius = 5.0;
    self.firstLabel.layer.borderWidth = 1.0;
    self.firstLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    self.firstLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.firstLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:400.0];
    else        self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
    
    
    //4 label
    self.secondLabel.text = @"3";
    self.secondLabel.backgroundColor = [UIColor clearColor];
    self.secondLabel.layer.cornerRadius = 5.0;
    self.secondLabel.layer.borderWidth = 1.0;
    self.secondLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    self.secondLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.secondLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:400.0];
    else        self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
    
    //2 label
    self.thirdLabel.text = @"2";
    self.thirdLabel.backgroundColor = [UIColor clearColor];
    self.thirdLabel.layer.cornerRadius = 5.0;
    self.thirdLabel.layer.borderWidth = 1.0;
    self.thirdLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    self.thirdLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.thirdLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:400.0];
    else        self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
    
    //1 label
    self.fourthLabel.text = @"1";
    self.fourthLabel.backgroundColor = [UIColor clearColor];
    self.fourthLabel.layer.cornerRadius = 5.0;
    self.fourthLabel.layer.borderWidth = 1.0;
    self.fourthLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    self.fourthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fourthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:400.0];
    else        self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
    
    //0 label
    self.fifthLabel.text = @"0";
    self.fifthLabel.backgroundColor = [UIColor clearColor];
    self.fifthLabel.layer.cornerRadius = 5.0;
    self.fifthLabel.layer.borderWidth = 1.0;
    self.fifthLabel.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    self.fifthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fifthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:400.0];
    else        self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:30.0];
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //Start Option
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.cornerRadius = 4.0;
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.startButton.frame = CGRectMake(screenBounds.size.width/2.0 - 50.0, screenBounds.size.height - 130.0, 100.0, 40.0);
    [self.startButton addTarget:self action:@selector(animateGameButtons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    //Numbers Button
    self.numbersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.numbersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.numbersButton.layer.borderWidth = 1.0;
    self.numbersButton.layer.cornerRadius = 4.0;
    [self.numbersButton setTitle:@"Numbers" forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.numbersButton.frame = CGRectMake(screenBounds.size.width, screenBounds.size.height - 180.0, 100.0, 40.0);
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.numbersButton];
    
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.colorsButton.layer.borderWidth = 1.0;
    self.colorsButton.layer.cornerRadius = 4.0;
    [self.colorsButton setTitle:@"Colors" forState:UIControlStateNormal];
    [self.colorsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.colorsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.colorsButton.frame = CGRectMake(screenBounds.size.width, screenBounds.size.height - 130.0, 100.0, 40.0);
    [self.colorsButton addTarget:self action:@selector(goToColorsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.colorsButton];
    
    //Options
    UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    optionsButton.layer.borderWidth = 1.0;
    optionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    optionsButton.layer.cornerRadius = 4.0;
    [optionsButton setTitle:@"Options" forState:UIControlStateNormal];
    [optionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    optionsButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
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
