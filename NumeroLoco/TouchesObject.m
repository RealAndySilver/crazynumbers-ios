//
//  TouchesObject.m
//  NumeroLoco
//
//  Created by Diego Vidal on 22/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "TouchesObject.h"

@implementation TouchesObject

+(TouchesObject *)sharedInstance {
    static TouchesObject *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[TouchesObject alloc] init];
        });
    }
    return shared;
}

@end
