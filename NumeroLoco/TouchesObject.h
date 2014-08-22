//
//  TouchesObject.h
//  NumeroLoco
//
//  Created by Diego Vidal on 22/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchesObject : NSObject
@property (assign, nonatomic) NSUInteger totalTouches;
+(TouchesObject *)sharedInstance;
@end
