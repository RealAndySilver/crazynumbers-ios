//
//  FourthPageViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 1/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FourthPageViewController.h"
#import "AppInfo.h"
#import "TutorialAlertView.h"

@interface FourthPageViewController () <TutorialAlertDelegate>
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIButton *button6;
@property (weak, nonatomic) IBOutlet UIButton *button7;
@property (weak, nonatomic) IBOutlet UIButton *button8;
@property (weak, nonatomic) IBOutlet UIButton *button9;
@property (strong, nonatomic) UILabel *touchLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIView *butonsContainer;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSArray *bluePaletteArray;

@end

@implementation FourthPageViewController {
    BOOL isPad;
    NSUInteger fontSize;
    CGRect screenBounds;
}

-(NSArray *)bluePaletteArray {
    if (!_bluePaletteArray) {
        _bluePaletteArray = [[AppInfo sharedInstance] arrayOfChaptersColorsArray][0];
    }
    return _bluePaletteArray;
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
    
    //Close button
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
    closeButton.layer.borderWidth = 1.0;
    closeButton.layer.cornerRadius = 10.0;
    closeButton.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
    [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //Back button
    //Back button
    if (screenBounds.size.height < 500.0) {
        //Small iphone
        self.backButton.center = CGPointMake(self.backButton.center.x, screenBounds.size.height - 40.0);
        self.continueButton.center = CGPointMake(self.continueButton.center.x, screenBounds.size.height - 40.0);
    } else {
        self.backButton.center = CGPointMake(self.backButton.center.x, screenBounds.size.height - 70.0);
        self.continueButton.center = CGPointMake(self.continueButton.center.x, screenBounds.size.height - 70.0);
    }
    [self.backButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.backButton.layer.cornerRadius = 10.0;
    self.backButton.layer.borderWidth = 1.0;
    self.backButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //Buttons
    for (int i = 0; i < [self.buttons count]; i++) {
        UIButton *button = self.buttons[i];
        button.tag = i+1;
        button.layer.cornerRadius = 10.0;
        button.backgroundColor = self.bluePaletteArray[0];
    }
    
    //Buttons background color
    self.button2.backgroundColor = self.bluePaletteArray[1];
    self.button4.backgroundColor = self.bluePaletteArray[1];
    self.button5.backgroundColor = self.bluePaletteArray[1];
    self.button6.backgroundColor = self.bluePaletteArray[1];
    self.button8.backgroundColor = self.bluePaletteArray[1];
    
    [self.button5 addTarget:self action:@selector(centerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.continueButton.hidden = YES;
    self.continueButton.layer.cornerRadius = 10.0;
    self.continueButton.layer.borderWidth = 1.0;
    [self.continueButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    self.continueButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    //Textview setup
    if (isPad) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, 50.0, self.view.bounds.size.width - 60.0, 160.0)];
    } else {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(30.0, 50.0, self.view.bounds.size.width - 60.0, 110.0)];
    }
    self.textView.text = NSLocalizedString(@"Colors Game\nObjective: Set all buttons to white.\n Every time you touch a button, its color will become lighter.", nil);
    self.textView.textColor = [UIColor darkGrayColor];
    self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    self.textView.userInteractionEnabled = NO;
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
    
    self.butonsContainer.layer.cornerRadius = 10.0;
    
    //Touch label
    self.touchLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, self.textView.frame.origin.y + self.textView.frame.size.height, self.view.bounds.size.width - 80.0, 30.0)];
    self.touchLabel.text = NSLocalizedString(@"Touch the center button!", nil);
    self.touchLabel.textAlignment = NSTextAlignmentCenter;
    self.touchLabel.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.touchLabel.numberOfLines = 0;
    self.touchLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    [self.view addSubview:self.touchLabel];
}

#pragma mark - Actions 

-(void)centerButtonPressed {
    [self.button5 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    self.button2.backgroundColor = self.bluePaletteArray[0];
    self.button4.backgroundColor = self.bluePaletteArray[0];
    self.button5.backgroundColor = self.bluePaletteArray[0];
    self.button6.backgroundColor = self.bluePaletteArray[0];
    self.button8.backgroundColor = self.bluePaletteArray[0];
    
    [self performSelector:@selector(showFirstAlert) withObject:nil afterDelay:0.8];
}

-(void)showFirstAlert {
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 140.0, 20.0, 280.0, 200.0)];
    tutorialAlert.textView.text = NSLocalizedString(@"You won! Just like in the numbers game, when you touch a button, you also affect the upper, left, bottom and right buttons. Let's practice again!", nil);
    tutorialAlert.tag = 1;
    tutorialAlert.delegate = self;
    [tutorialAlert showInView:self.view];
}

#pragma mark - TutorialAlertDelegate

-(void)acceptButtonPressedInAlert:(TutorialAlertView *)tutorialAlertView {
    self.touchLabel.hidden = YES;
    
    for (UIButton *button in self.buttons) {
        button.backgroundColor = self.bluePaletteArray[0];
    }
    
    if (tutorialAlertView.tag == 1) {
        self.textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        self.textView.textColor = [[AppInfo sharedInstance] appColorsArray][0];
        self.textView.text = NSLocalizedString(@"Now, touch the bottom center button to win!", nil);
        
        self.button5.backgroundColor = self.bluePaletteArray[1];
        self.button7.backgroundColor = self.bluePaletteArray[1];
        self.button8.backgroundColor = self.bluePaletteArray[1];
        self.button9.backgroundColor = self.bluePaletteArray[1];
        
        [self.button8 addTarget:self action:@selector(secondButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (tutorialAlertView.tag == 2) {
        self.textView.textColor = [UIColor darkGrayColor];
        self.textView.text = NSLocalizedString(@"Now, you will have to make two touches to win", nil);
        self.touchLabel.hidden = NO;
        self.touchLabel.text = @"Touch the center button";
        self.touchLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0];
        self.button2.backgroundColor = self.bluePaletteArray[1];
        self.button4.backgroundColor = self.bluePaletteArray[1];
        self.button6.backgroundColor = self.bluePaletteArray[1];
        self.button5.backgroundColor = self.bluePaletteArray[2];
        self.button8.backgroundColor = self.bluePaletteArray[2];
        self.button7.backgroundColor = self.bluePaletteArray[1];
        self.button9.backgroundColor = self.bluePaletteArray[1];
        
        [self.button5 addTarget:self action:@selector(finalCenterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    } else if (tutorialAlertView.tag == 3) {
        self.textView.text = NSLocalizedString(@"Start Playing!", nil);
        self.continueButton.hidden = NO;
    }
}

-(void)secondButtonPressed {
    [self.button8 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.button5.backgroundColor = self.bluePaletteArray[0];
    self.button7.backgroundColor = self.bluePaletteArray[0];
    self.button8.backgroundColor = self.bluePaletteArray[0];
    self.button9.backgroundColor = self.bluePaletteArray[0];
    
    [self performSelector:@selector(showSecondAlert) withObject:nil afterDelay:0.8];
}

-(void)showSecondAlert {
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 140.0, 20.0, 280.0, 200.0)];
    tutorialAlert.textView.text = NSLocalizedString(@"Excellent! You're becoming a Cross master! \n\nLet's practice one last time!", nil);
    tutorialAlert.tag = 2;
    tutorialAlert.delegate = self;
    [tutorialAlert showInView:self.view];
}

-(void)finalCenterButtonPressed {
    [self.button5 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.button2.backgroundColor = self.bluePaletteArray[0];
    self.button4.backgroundColor = self.bluePaletteArray[0];
    self.button6.backgroundColor = self.bluePaletteArray[0];
    self.button5.backgroundColor = self.bluePaletteArray[1];
    self.button8.backgroundColor = self.bluePaletteArray[1];
    
    self.touchLabel.hidden = YES;
    self.textView.textColor = [[AppInfo sharedInstance] appColorsArray][0];
    self.textView.text = NSLocalizedString(@"Now, touch the bottom center button to win!", nil);
    [self.button8 addTarget:self action:@selector(finalBottomCenterButtonPressed) forControlEvents:UIControlEventTouchUpInside];
}

-(void)finalBottomCenterButtonPressed {
    [self.button8 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    self.button5.backgroundColor = self.bluePaletteArray[0];
    self.button7.backgroundColor = self.bluePaletteArray[0];
    self.button8.backgroundColor = self.bluePaletteArray[0];
    self.button9.backgroundColor = self.bluePaletteArray[0];
    [self performSelector:@selector(showFinalAlert) withObject:nil afterDelay:0.8];
}

-(void)showFinalAlert {
    TutorialAlertView *tutorialAlert = [[TutorialAlertView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0 - 140.0, 20.0, 280.0, 260.0)];
    tutorialAlert.textView.text = NSLocalizedString(@"Congratulations! You have completed the tutorial! Start playing!\n\n *General Tip: If you affect a button that is already white (or has a value of zero, in the case of the numbers game), it will turn back to its original color", nil);
    tutorialAlert.tag = 3;
    tutorialAlert.delegate = self;
    [tutorialAlert showInView:self.view];
}

-(void)backButtonPressed {
    [self.delegate fourthPageBackButtonPressed];
}

-(void)continueButtonPressed {
    [self.delegate fourthPageContinueButtonPressed];
}

-(void)closeButtonPressed {
    [self.delegate fourthPageCloseButtonPressed];
}

@end
