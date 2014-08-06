//
//  IAPProduct.h
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPProduct : NSObject
@property (assign, nonatomic) BOOL purchaseInProgress;
@property (assign, nonatomic) BOOL availableForPurchase;
@property (assign, nonatomic) NSString *productIdentifier;
@property (strong, nonatomic) SKProduct *skProduct;
-(instancetype)initWithProductIdentifier:(NSString *)productIdentifier;
-(BOOL)allowedToPurchase;
@end
