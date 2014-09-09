//
//  ThirdPageTutViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ThirdPageTutViewController.h"
#import "TutorialAlertView.h"
#import "AppInfo.h"

@interface ThirdPageTutViewController () <TutorialAlertDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button6;
@property (weak, nonatomic) IBOutlet UIButton *button7;
@property (weak, nonatomic) IBOutlet UIButton *button8;
@property (weak, nonatomic) IBOutlet UIButton *button9;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@end

@implementation ThirdPageTutViewController {
    CGRect screenBounds;
    NSUInteger fontSize;
    BOOL isPad;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    screenBounds = [UIScreen mainScreen].bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        isPad = YES;
        fontSize = 30.0;
    } else {
        isPad = NO;
        fontSize = 15.0;
    }
    
    //Back button
    if (screenBounds.size.height < 500.0) {
        //Small iphone
        self.backButton.center = CGPointMake(self.backButton.center.x, screenBounds.size.height - 40.0);
        self.continueButton.center = CGPointMake(self.continueButton.center.x, screenBounds.size.height - 40.0);
    }
    [self.backButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][2] forState:UIControlStateNormal];
    self.backButton.layer.cornerRadius = 10.0;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][2]).CGColor;
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    //Buttons
    for (int i = 0; i < [self.buttons count]; i++) {
        UIButton *button = self.buttons[i];
        button.tag = i+1;
        button.layer.cornerRadius = 10.0;
        button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
        if (isPad) {
            button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40.0];
        }
    }
    self.continueButton.hidden = YES;
    self.continueButton.layer.cornerRadius = 10.0;
    self.continueButton.layer.borderWidth = 1.0;
    self.continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][2]).CGColor;
    [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.button5 addTarget:self action:@selector(centerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //Textview setup
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(40.0, 50.0, self.view.bounds.size.width - 80.0, 140.0)];
    self.textView.text = @"Let's practice! remember, when you touch a button, it's value will decrease by one, as well as the value of the upper, left, bottom and right button. \n\nTouch the center button!";
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    self.textView.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.textView];
}

#pragma mark - Actions 

-(void)centerButtonPressed {
    [self.button5 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self.button5 setTitle:@"0" forState:UIControlStateNormal];
    self.button5.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self.button2 setTitle:@"0" forState:UIControlStateNormal];
    self.button2.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self.button4 setTitle:@"0" forState:UIControlStateNormal];
    self.button4.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self.button6 setTitle:@"0" forState:UIControlStateNormal];
    self.button6.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self.button8 setTitle:@"0" forState:UIControlStateNormal];
    self.button8.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self performSelector:@selector(showFirstAlert) withObject:nil afterDelay:0.7];
}

-(void)showFirstAlert {
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, 20.0, 280.0, 200.0)];
    tutorialAlert.textView.text = @"Excellent!\nYou set all the buttons to zero! The yellow buttons were the ones affected by your touch. Let's practice again!";
    tutorialAlert.tag = 1;
    tutorialAlert.delegate = self;
    [tutorialAlert showInView:self.view];
    
    self.textView.text = @"Now, touch the upper left button!";
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.textAlignment = NSTextAlignmentCenter;
    /*[self.button5 setTitle:@"0" forState:UIControlStateNormal];
    self.button5.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [self.button2 setTitle:@"1" forState:UIControlStateNormal];
    self.button2.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [self.button4 setTitle:@"1" forState:UIControlStateNormal];
    self.button4.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [self.button6 setTitle:@"0" forState:UIControlStateNormal];
    self.button6.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [self.button8 setTitle:@"0" forState:UIControlStateNormal];
    self.button8.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    [self.button1 setTitle:@"1" forState:UIControlStateNormal];*/
}

-(void)backButtonPressed {
    [self.delegate thirdPageBackButtonPressed];
}

#pragma mark - TutorialAlertDelegate

-(void)acceptButtonPressedInAlert:(TutorialAlertView *)tutorialAlertView {
    for (UIButton *button in self.buttons) {
        button.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
        [button setTitle:@"0" forState:UIControlStateNormal];
    }
    
    if (tutorialAlertView.tag == 1) {
        [self.button1 setTitle:@"1" forState:UIControlStateNormal];
        [self.button2 setTitle:@"1" forState:UIControlStateNormal];
        [self.button4 setTitle:@"1" forState:UIControlStateNormal];
        
        [self.button1 addTarget:self action:@selector(button1Pressed) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (tutorialAlertView.tag == 2) {
        [self.button1 setTitle:@"1" forState:UIControlStateNormal];
        [self.button2 setTitle:@"2" forState:UIControlStateNormal];
        [self.button4 setTitle:@"2" forState:UIControlStateNormal];
        [self.button5 setTitle:@"1" forState:UIControlStateNormal];
        [self.button6 setTitle:@"1" forState:UIControlStateNormal];
        [self.button8 setTitle:@"1" forState:UIControlStateNormal];
        [self.button5 addTarget:self action:@selector(lastCenterButtonPress) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (tutorialAlertView.tag == 3) {
        self.continueButton.hidden = NO;
    }
}

-(void)button1Pressed {
    [self.button1 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.button1.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    [self.button1 setTitle:@"0" forState:UIControlStateNormal];
    [self.button2 setTitle:@"0" forState:UIControlStateNormal];
    [self.button4 setTitle:@"0" forState:UIControlStateNormal];
    self.button2.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    self.button4.backgroundColor = [[AppInfo sharedInstance] appColorsArray][3];
    
    [self performSelector:@selector(showSecondAlert) withObject:nil afterDelay:0.7];
}

-(void)showSecondAlert {
    self.textView.text = @"Now, you will have to make two touches to win. Touch the center button and then the upper left button";
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, 20.0, 280.0, 200.0)];
    tutorialAlert.tag = 2;
    tutorialAlert.delegate = self;
    tutorialAlert.textView.text = @"Excellent!\nBecause in this case there weren't upper and left buttons, the buttons that you affected were the right and bottom ones. Let's practice one last time!";
    [tutorialAlert showInView:self.view];
}

-(void)lastCenterButtonPress {
    [self.button5 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    self.textView.text = @"Nice! Now touch the upper left button to win!";
    
    [self.button2 setTitle:@"1" forState:UIControlStateNormal];
    [self.button4 setTitle:@"1" forState:UIControlStateNormal];
    [self.button5 setTitle:@"0" forState:UIControlStateNormal];
    [self.button6 setTitle:@"0" forState:UIControlStateNormal];
    [self.button8 setTitle:@"0" forState:UIControlStateNormal];
    [self.button1 addTarget:self action:@selector(lastButton1Press) forControlEvents:UIControlEventTouchUpInside];
}

-(void)lastButton1Press {
    [self.button1 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.button1 setTitle:@"0" forState:UIControlStateNormal];
    [self.button2 setTitle:@"0" forState:UIControlStateNormal];
    [self.button4 setTitle:@"0" forState:UIControlStateNormal];
    [self performSelector:@selector(showLastAlert) withObject:nil afterDelay:0.7];
}

-(void)showLastAlert {
    self.textView.text = @"Congratulations!\nNow you can play the numbers game. Let's continue and see how the colors game works!";
    
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2.0 - 140.0, 20.0, 280.0, 200.0)];
    tutorialAlert.textView.text = @"Congratulations!\nNow you can play the numbers game. Let's continue and see how the colors game works!";
    tutorialAlert.delegate = self;
    tutorialAlert.tag = 3;
    [tutorialAlert showInView:self.view];
}

-(void)continueButtonPressed {
    [self.delegate thirdPageContinueButtonPressed];
}

@end