//
//  AppInfo.m
//  NumeroLoco
//
//  Created by Developer on 19/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

+(AppInfo *)sharedInstance {
    static AppInfo *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[AppInfo alloc] init];
    });
    return shared;
}

-(NSArray *)appColorsArray {
    NSMutableArray *colorsArray = [[NSMutableArray alloc] init];
    UIColor *thirdColor = [UIColor colorWithRed:0.380 green:0.870 blue:1.000 alpha:1.0];
    UIColor *secondColor = [UIColor colorWithRed:0.636 green:0.380 blue:1.000 alpha:1.0];
    UIColor *firstColor = [UIColor colorWithRed:1.000 green:0.386 blue:0.380 alpha:1.0];
    UIColor *fourthColor = [UIColor colorWithRed:1.000 green:0.801 blue:0.380 alpha:1.0];
    UIColor *fifthColor = [UIColor colorWithRed:0.654 green:1.000 blue:0.380 alpha:1.0];
    [colorsArray addObject:firstColor];
    [colorsArray addObject:secondColor];
    [colorsArray addObject:thirdColor];
    [colorsArray addObject:fourthColor];
    [colorsArray addObject:fifthColor];
    return colorsArray;
}

-(NSArray *)arrayOfChaptersColorsArray {
    NSMutableArray *chapterColorsArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *blueScaleArray = [[NSMutableArray alloc] init];
    UIColor *color1 = [UIColor whiteColor];
    UIColor *color3 = [UIColor colorWithRed:0.614 green:0.941 blue:1.000 alpha:1.0];
    UIColor *color5 = [UIColor colorWithRed:0.286 green:0.855 blue:1.000 alpha:1.0];
    UIColor *color7 = [UIColor colorWithRed:0.000 green:0.639 blue:0.800 alpha:1.0];
    UIColor *color9 = [UIColor colorWithRed:0.000 green:0.322 blue:0.400 alpha:1.0];
    UIColor *color10 = [UIColor colorWithRed:0.000 green:0.161 blue:0.200 alpha:1.0];
    [blueScaleArray addObjectsFromArray:@[color1, color3 ,color5, color7, color9, color10]];

    NSMutableArray *secondChapterColors = [[NSMutableArray alloc] init];
    color1 = [UIColor whiteColor];
    color3 = [UIColor colorWithRed:0.878 green:0.784 blue:1.000 alpha:1.0];
    color5 = [UIColor colorWithRed:0.765 green:0.580 blue:1.000 alpha:1.0];
    color7 = [UIColor colorWithRed:0.537 green:0.329 blue:0.800 alpha:1.0];
    color9 = [UIColor colorWithRed:0.267 green:0.165 blue:0.400 alpha:1.0];
    color10 = [UIColor colorWithRed:0.133 green:0.082 blue:0.200 alpha:1.0];
    [secondChapterColors addObjectsFromArray:@[color1, color3 ,color5, color7, color9, color10]];
    
    NSMutableArray *thirdChapterColors = [[NSMutableArray alloc] init];
    color1 = [UIColor whiteColor];
    color3 = [UIColor colorWithRed:1.000 green:0.729 blue:0.741 alpha:1.0];
    color5 = [UIColor colorWithRed:1.000 green:0.553 blue:0.565 alpha:1.0];
    color7 = [UIColor colorWithRed:0.800 green:0.298 blue:0.314 alpha:1.0];
    color9 = [UIColor colorWithRed:0.400 green:0.149 blue:0.157 alpha:1.0];
    color10 = [UIColor colorWithRed:0.200 green:0.075 blue:0.078 alpha:1.0];
    [thirdChapterColors addObjectsFromArray:@[color1, color3 ,color5, color7, color9, color10]];
    
    NSMutableArray *fourthChapterColors = [[NSMutableArray alloc] init];
    color1 = [UIColor whiteColor];
    color3 = [UIColor colorWithRed:1.000 green:0.914 blue:0.773 alpha:1.0];
    color5 = [UIColor colorWithRed:1.000 green:0.851 blue:0.604 alpha:1.0];
    color7 = [UIColor colorWithRed:0.800 green:0.631 blue:0.357 alpha:1.0];
    color9 = [UIColor colorWithRed:0.400 green:0.318 blue:0.176 alpha:1.0];
    color10 = [UIColor colorWithRed:0.200 green:0.157 blue:0.090 alpha:1.0];
    [fourthChapterColors addObjectsFromArray:@[color1, color3 ,color5, color7, color9, color10]];

    [chapterColorsArray addObjectsFromArray:@[thirdChapterColors, secondChapterColors, blueScaleArray, fourthChapterColors]];
    return chapterColorsArray;
}

-(NSArray *)wordsArray {
    return @[@"Zero", @"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
}

@end
