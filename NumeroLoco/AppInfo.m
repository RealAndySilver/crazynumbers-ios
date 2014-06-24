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
    UIColor *firstColor = [UIColor colorWithRed:0.380 green:0.870 blue:1.000 alpha:1.0];
    UIColor *secondColor = [UIColor colorWithRed:0.636 green:0.380 blue:1.000 alpha:1.0];
    UIColor *thirdColor = [UIColor colorWithRed:1.000 green:0.386 blue:0.380 alpha:1.0];
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
    UIColor *color1 = [UIColor colorWithRed:1.0 green:1.000 blue:1.000 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:0.859 green:0.973 blue:1.000 alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:0.714 green:0.941 blue:1.000 alpha:1.0];
    UIColor *color4 = [UIColor colorWithRed:0.427 green:0.886 blue:1.000 alpha:1.0];
    UIColor *color5 = [UIColor colorWithRed:0.286 green:0.855 blue:1.000 alpha:1.0];
    UIColor *color6 = [UIColor colorWithRed:0.000 green:0.800 blue:1.000 alpha:1.0];
    UIColor *color7 = [UIColor colorWithRed:0.000 green:0.639 blue:0.800 alpha:1.0];
    UIColor *color8 = [UIColor colorWithRed:0.000 green:0.482 blue:0.600 alpha:1.0];
    UIColor *color9 = [UIColor colorWithRed:0.000 green:0.322 blue:0.400 alpha:1.0];
    UIColor *color10 = [UIColor colorWithRed:0.000 green:0.161 blue:0.200 alpha:1.0];
    [blueScaleArray addObjectsFromArray:@[color1, color2, color3, color4 ,color5, color6, color7, color8, color9, color10]];

    NSMutableArray *secondChapterColors = [[NSMutableArray alloc] init];
    color1 = [UIColor colorWithRed:1.0 green:0.992 blue:1.000 alpha:1.0];
    color2 = [UIColor colorWithRed:0.902 green:0.827 blue:1.000 alpha:1.0];
    color3 = [UIColor colorWithRed:0.878 green:0.784 blue:1.000 alpha:1.0];
    color4 = [UIColor colorWithRed:0.831 green:0.698 blue:1.000 alpha:1.0];
    color5 = [UIColor colorWithRed:0.765 green:0.580 blue:1.000 alpha:1.0];
    color6 = [UIColor colorWithRed:0.671 green:0.412 blue:1.000 alpha:1.0];
    color7 = [UIColor colorWithRed:0.537 green:0.329 blue:0.800 alpha:1.0];
    color8 = [UIColor colorWithRed:0.404 green:0.247 blue:0.600 alpha:1.0];
    color9 = [UIColor colorWithRed:0.267 green:0.165 blue:0.400 alpha:1.0];
    color10 = [UIColor colorWithRed:0.133 green:0.082 blue:0.200 alpha:1.0];
    
    [secondChapterColors addObject:color1];
    [secondChapterColors addObject:color2];
    [secondChapterColors addObject:color3];
    [secondChapterColors addObject:color4];
    [secondChapterColors addObject:color5];
    [secondChapterColors addObject:color6];
    [secondChapterColors addObject:color7];
    [secondChapterColors addObject:color8];
    [secondChapterColors addObject:color9];
    [secondChapterColors addObject:color10];
    
    
    [chapterColorsArray addObjectsFromArray:@[blueScaleArray, secondChapterColors]];
    return chapterColorsArray;
}

@end
