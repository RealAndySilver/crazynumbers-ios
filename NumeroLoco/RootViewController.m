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
#import "TutorialViewController.h"
#import "FileSaver.h"

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
    CGFloat cornerRadius;
    BOOL isPad;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        cornerRadius = 10.0;
    } else {
        isPad = NO;
        cornerRadius = 5.0;
    }
    self.view.backgroundColor = [[[AppInfo sharedInstance] appColorsArray] firstObject];
    self.navigationController.navigationBarHidden = YES;
    screenBounds = [UIScreen mainScreen].bounds;
    [self setupUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Check if this is the first time the user launch the app
    FileSaver *fileSaver = [[FileSaver alloc] init];
    if (![fileSaver getDictionary:@"FirstAppLaunchDic"][@"FirstAppLaunchKey"]) {
        //This is the first time the user launches the app
        //so present the tutorial view controller
        [fileSaver setDictionary:@{@"FirstAppLaunchKey" : @YES} withName:@"FirstAppLaunchDic"];
        [self goToTutorialVC];
    }
}

-(void)setupUI {
    NSUInteger buttonsHeight = 0;
    NSUInteger fontSize = 0;
    NSString *fontName = nil;
    if (isPad) {
        fontSize = 40.0;
        buttonsHeight = 70.0;
        fontName = @"HelveticaNeue-Light";
    } else {
        fontSize = 20.0;
        buttonsHeight = 40.0;
        fontName = @"HelveticaNeue-Light";
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////
    //Numbers labels
    //5 label
    self.firstLabel.text = @"4";
    self.firstLabel.backgroundColor = [UIColor whiteColor];
    self.firstLabel.layer.cornerRadius = cornerRadius;
    self.firstLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.firstLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.firstLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    
    //4 label
    self.secondLabel.text = @"3";
    self.secondLabel.backgroundColor = [UIColor whiteColor];
    self.secondLabel.layer.cornerRadius = cornerRadius;
    self.secondLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.secondLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.secondLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //2 label
    self.thirdLabel.text = @"2";
    self.thirdLabel.backgroundColor = [UIColor whiteColor];
    self.thirdLabel.layer.cornerRadius = cornerRadius;
    self.thirdLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.thirdLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.thirdLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //1 label
    self.fourthLabel.text = @"1";
    self.fourthLabel.backgroundColor = [UIColor whiteColor];
    self.fourthLabel.layer.cornerRadius = cornerRadius;
    self.fourthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fourthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.fourthLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //0 label
    self.fifthLabel.text = @"0";
    self.fifthLabel.backgroundColor = [UIColor whiteColor];
    self.fifthLabel.layer.cornerRadius = cornerRadius;
    self.fifthLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.fifthLabel.textAlignment = NSTextAlignmentCenter;
    if (isPad)  self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:90.0];
    else        self.fifthLabel.font = [UIFont fontWithName:FONT_NAME size:40.0];
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //Options
    UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    optionsButton.layer.borderWidth = 1.0;
    optionsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    optionsButton.layer.cornerRadius = cornerRadius;
    [optionsButton setTitle:@"Tutorial" forState:UIControlStateNormal];
    [optionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    optionsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    optionsButton.frame = CGRectMake(screenBounds.size.width/2.0 - (screenBounds.size.width/6.4), screenBounds.size.height - (screenBounds.size.height/7.1), (screenBounds.size.width/6.4*2), buttonsHeight);
    [optionsButton addTarget:self action:@selector(goToTutorialVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optionsButton];
    
    //Start Option
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.startButton.layer.borderWidth = 1.0;
    self.startButton.layer.cornerRadius = cornerRadius;
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    //self.startButton.frame = CGRectMake(screenBounds.size.width/2.0 - (screenBounds.size.width/6.4), screenBounds.size.height - (buttonsHeight*3.25), (screenBounds.size.width/6.4*2), buttonsHeight);
    self.startButton.frame = CGRectOffset(optionsButton.frame, 0.0, -(10.0 + optionsButton.frame.size.height));
    [self.startButton addTarget:self action:@selector(animateGameButtons) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    //Colors button
    self.colorsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.colorsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.colorsButton.layer.borderWidth = 1.0;
    self.colorsButton.layer.cornerRadius = cornerRadius;
    [self.colorsButton setTitle:@"Colors" forState:UIControlStateNormal];
    [self.colorsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.colorsButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.colorsButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y, screenBounds.size.width/6.4*2, buttonsHeight);
    [self.colorsButton addTarget:self action:@selector(goToColorsChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.colorsButton];
    
    //Numbers Button
    self.numbersButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.numbersButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.numbersButton.layer.borderWidth = 1.0;
    self.numbersButton.layer.cornerRadius = cornerRadius;
    [self.numbersButton setTitle:@"Numbers" forState:UIControlStateNormal];
    [self.numbersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.numbersButton.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
    self.numbersButton.frame = CGRectMake(screenBounds.size.width, self.startButton.frame.origin.y - 10.0 - buttonsHeight, screenBounds.size.width/6.4*2, buttonsHeight);
    [self.numbersButton addTarget:self action:@selector(goToChaptersVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.numbersButton];
}

#pragma mark - Actions

-(void)animateGameButtons {
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.startButton.transform = CGAffineTransformMakeTranslation(-(self.startButton.frame.origin.x + self.startButton.frame.size.width + 10), 0.0);
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

-(void)goToTutorialVC {
    TutorialViewController *tutorialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
    [self presentViewController:tutorialVC animated:YES completion:nil];
}

@end
