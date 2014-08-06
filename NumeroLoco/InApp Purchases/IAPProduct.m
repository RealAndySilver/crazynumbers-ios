//
//  IAPProduct.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "IAPProduct.h"

@implementation IAPProduct

-(instancetype)initWithProductIdentifier:(NSString *)productIdentifier {
    if (self = [super init]) {
        _availableForPurchase = NO;
        _productIdentifier = productIdentifier;
        _skProduct = nil;
    }
    return self;
}

-(BOOL)allowedToPurchase {
    if (!self.availableForPurchase) {
        return NO;
    }
    if (self.purchaseInProgress) {
        return NO;
    }
    return YES;
}

@end
