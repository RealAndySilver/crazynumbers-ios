//
//  AppInfo.h
//  NumeroLoco
//
//  Created by Developer on 19/06/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
+(AppInfo *)sharedInstance;
-(NSArray *)appColorsArray;
-(NSArray *)arrayOfChaptersColorsArray;
@end
