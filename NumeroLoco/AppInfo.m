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

@end
