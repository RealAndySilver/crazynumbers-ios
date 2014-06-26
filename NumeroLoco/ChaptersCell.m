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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            isPad = YES;
        } else {
            isPad = NO;
        }
        
        NSUInteger fontSize;
        if (isPad) fontSize = 80.0;
        else fontSize = 40.0;
        
        self.chapterNameLabel = [[UILabel alloc] init];
        self.chapterNameLabel.font = [UIFont fontWithName:FONT_NAME size:45.0];
        self.chapterNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.chapterNameLabel];
        
        //Button 1
        self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button1 setTitle:@"1" forState:UIControlStateNormal];
        [self.button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button1.titleLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
        self.button1.layer.cornerRadius = 4.0;
        self.button1.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button1.layer.borderWidth = 1.0;
        self.button1.tag = 1;
        [self.button1 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button1];
        
        //Button 2
        self.button2 = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.button2 setTitle:@"2" forState:UIControlStateNormal];
        [self.button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.button2.layer.cornerRadius = 4.0;
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
        self.button3.layer.cornerRadius = 4.0;
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
        self.button4.layer.cornerRadius = 4.0;
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
        self.button5.layer.cornerRadius = 4.0;
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
        self.button6.layer.cornerRadius = 4.0;
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
        self.button7.layer.cornerRadius = 4.0;
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
        self.button8.layer.cornerRadius = 4.0;
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
        self.button9.layer.cornerRadius = 4.0;
        self.button9.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.button9.layer.borderWidth = 1.0;
        self.button9.tag = 9;
        [self.button9 addTarget:self action:@selector(gameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.button9];
        
        self.buttonsArray = [NSMutableArray arrayWithArray:@[self.button1, self.button2, self.button3, self.button4, self.button5, self.button6, self.button7, self.button8, self.button9]];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSUInteger buttonSize;
    NSUInteger buttonDistance;
    NSUInteger initialHeight;
    NSUInteger chapterNameY;
    NSUInteger chapterNameHeight;
    
    if (isPad) {
        buttonSize = 140.0;
        buttonDistance = 20.0;
        initialHeight = 200.0;
        chapterNameY = 70.0;
        chapterNameHeight = 70.0;
    } else {
        buttonSize = 70.0;
        buttonDistance = 10.0;
        initialHeight = 100.0;
        chapterNameY = 0.0;
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
}

#pragma mark - Actions

-(void)gameButtonPressed:(UIButton *)button {
    NSLog(@"Oprimí el botón con tag %d", button.tag);
    [self.delegate chaptersCellDidSelectGame:button.tag - 1];
}

@end
