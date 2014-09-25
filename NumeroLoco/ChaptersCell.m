//
//  ChaptersCell.m
//  NumeroLoco
//
//  Created by Developer on 17/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ChaptersCell.h"

@interface ChaptersCell()

@end

#define FONT_NAME @"HelveticaNeue-UltraLight"

@implementation ChaptersCell {
    BOOL isPad;
}

/*-(void)setGamesFinishedArray:(NSArray *)gamesFinishedArray {
    _gamesFinishedArray = gamesFinishedArray;
    for (int i = 0; i < [gamesFinishedArray count]; i++) {
        UIButton *numberButton = self.buttonsArray[i];
        [numberButton setTitleColor:self.chapterNameLabel.textColor forState:UIControlStateNormal];
        numberButton.layer.borderColor = self.chapterNameLabel.textColor.CGColor;
    }
}*/

-(void)setButtonsTitleColor:(UIColor *)buttonsTitleColor {
    _buttonsTitleColor = buttonsTitleColor;
    [self.button1 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button2 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button3 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button4 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button5 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button6 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button7 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button8 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
    [self.button9 setTitleColor:buttonsTitleColor forState:UIControlStateNormal];
}

-(void)setButtonsBackgroundColor:(UIColor *)buttonsBackgroundColor {
    _buttonsBackgroundColor = buttonsBackgroundColor;
    self.button1.backgroundColor = buttonsBackgroundColor;
    self.button2.backgroundColor = buttonsBackgroundColor;
    self.button3.backgroundColor = buttonsBackgroundColor;
    self.button4.backgroundColor = buttonsBackgroundColor;
    self.button5.backgroundColor = buttonsBackgroundColor;
    self.button6.backgroundColor = buttonsBackgroundColor;
    self.button7.backgroundColor = buttonsBackgroundColor;
    self.button8.backgroundColor = buttonsBackgroundColor;
    self.button9.backgroundColor = buttonsBackgroundColor;
}

-(void)setButtonsBorderColor:(UIColor *)buttonsBorderColor {
    _buttonsBorderColor = buttonsBorderColor;
    self.button1.layer.borderColor = buttonsBorderColor.CGColor;
    self.button2.layer.borderColor = buttonsBorderColor.CGColor;
    self.button3.layer.borderColor = buttonsBorderColor.CGColor;
    self.button4.layer.borderColor = buttonsBorderColor.CGColor;
    self.button5.layer.borderColor = buttonsBorderColor.CGColor;
    self.button6.layer.borderColor = buttonsBorderColor.CGColor;
    self.button7.layer.borderColor = buttonsBorderColor.CGColor;
    self.button8.layer.borderColor = buttonsBorderColor.CGColor;
    self.button9.layer.borderColor = buttonsBorderColor.CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSUInteger cornerRadius = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            isPad = YES;
            cornerRadius = 10.0;
        } else {
            isPad = NO;
            cornerRadius = 10.0;
        }
        
        NSUInteger fontSize;
        if (isPad) fontSize = 80.0;
        else fontSize = 40.0;
        
        self.chapterNameLabel = [[UILabel alloc] init];
        self.chapterNameLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.chapterNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.chapterNameLabel];
        
        //Button 1
        self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button1 setTitle:@"1" forState:UIControlStateNormal];
        [self.button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button1.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.button1.layer.cornerRadius = cornerRadius;
        self.button1.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button1.layer.borderWidth = 1.0;
        self.button1.tag = 1;
        [self.button1 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button1];
        
        //Button 2
        self.button2 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button2 setTitle:@"2" forState:UIControlStateNormal];
        [self.button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button2.layer.cornerRadius = cornerRadius;
        self.button2.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button2.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.button2.layer.borderWidth = 1.0;
        self.button2.tag = 2;
        [self.button2 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button2];
        
        //Button 3
        self.button3 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button3.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        [self.button3 setTitle:@"3" forState:UIControlStateNormal];
        [self.button3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button3.layer.cornerRadius = cornerRadius;
        self.button3.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button3.layer.borderWidth = 1.0;
        self.button3.tag = 3;
        [self.button3 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button3];
        
        //Button 4
        self.button4 = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button4.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        [self.button4 setTitle:@"4" forState:UIControlStateNormal];
        [self.button4 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button4.layer.cornerRadius = cornerRadius;
        self.button4.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button4.layer.borderWidth = 1.0;
        self.button4.tag = 4;
        [self.button4 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button4];
        
        //Button 5
        self.button5 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button5 setTitle:@"5" forState:UIControlStateNormal];
        self.button5.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        [self.button5 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button5.layer.cornerRadius = cornerRadius;
        self.button5.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button5.layer.borderWidth = 1.0;
        self.button5.tag = 5;
        [self.button5 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button5];
        
        //Button 6
        self.button6 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button6 setTitle:@"6" forState:UIControlStateNormal];
        [self.button6 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button6.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.button6.layer.cornerRadius = cornerRadius;
        self.button6.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button6.layer.borderWidth = 1.0;
        self.button6.tag = 6;
        [self.button6 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button6];
        
        //Button 7
        self.button7 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button7 setTitle:@"7" forState:UIControlStateNormal];
        [self.button7 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button7.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.button7.layer.cornerRadius = cornerRadius;
        self.button7.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button7.layer.borderWidth = 1.0;
        self.button7.tag = 7;
        [self.button7 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button7];
        
        //Button 1
        self.button8 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button8 setTitle:@"8" forState:UIControlStateNormal];
        self.button8.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        [self.button8 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button8.layer.cornerRadius = cornerRadius;
        self.button8.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button8.layer.borderWidth = 1.0;
        self.button8.tag = 8;
        [self.button8 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button8];
        
        //Button 9
        self.button9 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button9 setTitle:@"9" forState:UIControlStateNormal];
        self.button9.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        [self.button9 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button9.layer.cornerRadius = cornerRadius;
        self.button9.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button9.layer.borderWidth = 1.0;
        self.button9.tag = 9;
        [self.button9 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button9];
        
        self.buttonsArray = [NSMutableArray arrayWithArray:@[self.button1, self.button2, self.button3, self.button4, self.button5, self.button6, self.button7, self.button8, self.button9]];
        
        /*if (isPad) {
            //Label1
            self.label1 = [[UILabel alloc] init];
            self.label1.textColor = [UIColor lightGrayColor];
            self.label1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label1.textAlignment = NSTextAlignmentCenter;
            [self.button1 addSubview:self.label1];
            
            //Label2
            self.label2 = [[UILabel alloc] init];
            self.label2.textColor = [UIColor lightGrayColor];
            self.label2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label2.textAlignment = NSTextAlignmentCenter;
            [self.button2 addSubview:self.label2];
            
            //Label3
            self.label3 = [[UILabel alloc] init];
            self.label3.textColor = [UIColor lightGrayColor];
            self.label3.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label3.textAlignment = NSTextAlignmentCenter;
            [self.button3 addSubview:self.label3];
            
            //Label4
            self.label4 = [[UILabel alloc] init];
            self.label4.textColor = [UIColor lightGrayColor];
            self.label4.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label4.textAlignment = NSTextAlignmentCenter;
            [self.button4 addSubview:self.label4];
            
            //Label5
            self.label5 = [[UILabel alloc] init];
            self.label5.textColor = [UIColor lightGrayColor];
            self.label5.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label5.textAlignment = NSTextAlignmentCenter;
            [self.button5 addSubview:self.label5];
            
            //Label6
            self.label6 = [[UILabel alloc] init];
            self.label6.textColor = [UIColor lightGrayColor];
            self.label6.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label6.textAlignment = NSTextAlignmentCenter;
            [self.button6 addSubview:self.label6];
            
            //Label7
            self.label7 = [[UILabel alloc] init];
            self.label7.textColor = [UIColor lightGrayColor];
            self.label7.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label7.textAlignment = NSTextAlignmentCenter;
            [self.button7 addSubview:self.label7];
            
            //Label8
            self.label8 = [[UILabel alloc] init];
            self.label8.textColor = [UIColor lightGrayColor];
            self.label8.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label8.textAlignment = NSTextAlignmentCenter;
            [self.button8 addSubview:self.label8];
            
            //Label1
            self.label9 = [[UILabel alloc] init];
            self.label9.textColor = [UIColor lightGrayColor];
            self.label9.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
            self.label9.textAlignment = NSTextAlignmentCenter;
            [self.button9 addSubview:self.label9];
        }*/
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    NSUInteger buttonSize;
    NSUInteger buttonDistance;
    NSUInteger initialHeight;
    NSUInteger chapterNameY;
    NSUInteger chapterNameHeight;
    
    if (isPad) {
        buttonSize = 140.0;
        buttonDistance = 20.0;
        initialHeight = 280.0;
        chapterNameY = 120.0;
        chapterNameHeight = 90.0;
    } else {
        buttonSize = 70.0;
        buttonDistance = 10.0;
        initialHeight = bounds.size.height/3.38;
        chapterNameY = bounds.size.height/9.46;
        chapterNameHeight = 50.0;
    }
    
    CGRect contentBounds = self.contentView.bounds;
    self.chapterNameLabel.frame = CGRectMake(20.0, chapterNameY, contentBounds.size.width - 40.0, chapterNameHeight);
    self.button2.frame = CGRectMake(contentBounds.size.width/2.0 - buttonSize/2.0, initialHeight, buttonSize, buttonSize);
    self.button1.frame = CGRectMake(self.button2.frame.origin.x - buttonDistance - buttonSize, self.button2.frame.origin.y, buttonSize, buttonSize);
    self.button3.frame = CGRectMake(self.button2.frame.origin.x + buttonSize + buttonDistance, self.button2.frame.origin.y, buttonSize, buttonSize);
    
    self.button5.frame = CGRectMake(self.button2.frame.origin.x, self.button2.frame.origin.y + buttonSize + buttonDistance, buttonSize, buttonSize);
    self.button4.frame = CGRectMake(self.button1.frame.origin.x, self.button5.frame.origin.y, buttonSize, buttonSize);
    self.button6.frame = CGRectMake(self.button3.frame.origin.x, self.button5.frame.origin.y, buttonSize, buttonSize);
    
    self.button7.frame = CGRectMake(self.button4.frame.origin.x, self.button5.frame.origin.y + buttonSize + buttonDistance, buttonSize, buttonSize);
    self.button8.frame = CGRectMake(self.button5.frame.origin.x, self.button7.frame.origin.y, buttonSize, buttonSize);
    self.button9.frame = CGRectMake(self.button6.frame.origin.x, self.button7.frame.origin.y, buttonSize, buttonSize);
    
    //Labels
    /*if (isPad) {
        self.label1.frame = CGRectMake(0.0, self.button1.frame.size.height - 20.0, self.button1.frame.size.width, 20.0);
        self.label2.frame = CGRectMake(0.0, self.button2.frame.size.height - 20.0, self.button2.frame.size.width, 20.0);
        self.label3.frame = CGRectMake(0.0, self.button3.frame.size.height - 20.0, self.button3.frame.size.width, 20.0);
        self.label4.frame = CGRectMake(0.0, self.button4.frame.size.height - 20.0, self.button4.frame.size.width, 20.0);
        self.label5.frame = CGRectMake(0.0, self.button5.frame.size.height - 20.0, self.button5.frame.size.width, 20.0);
        self.label6.frame = CGRectMake(0.0, self.button6.frame.size.height - 20.0, self.button6.frame.size.width, 20.0);
        self.label7.frame = CGRectMake(0.0, self.button7.frame.size.height - 20.0, self.button7.frame.size.width, 20.0);
        self.label8.frame = CGRectMake(0.0, self.button8.frame.size.height - 20.0, self.button8.frame.size.width, 20.0);
        self.label9.frame = CGRectMake(0.0, self.button9.frame.size.height - 20.0, self.button9.frame.size.width, 20.0);
    }*/
}

#pragma mark - Actions

-(void)gameButtonPressed:(UIButton *)button {
    NSLog(@"Oprimí el botón con tag %ld", (long)button.tag);
    [self.delegate chaptersCellDidSelectGame:button.tag - 1];
}

@end
