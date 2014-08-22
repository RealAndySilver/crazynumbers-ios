//
//  CPIAPHelper.m
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import "CPIAPHelper.h"
#import "IAPProduct.h"

@interface CPIAPHelper()
@property (strong, nonatomic) NSString *productoComprado;
@end

@implementation CPIAPHelper

-(instancetype)init {
    IAPProduct *noAdsProduct = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.cross.noads"];
    IAPProduct *threeHundredTouches = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.cross.threehundredtouches"];
    IAPProduct *sevenHundredTouches = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.cross.sevenhundredtouches"];
    IAPProduct *twoThousandTouches = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.cross.twothousandtouches"];
    IAPProduct *infiniteMode = [[IAPProduct alloc] initWithProductIdentifier:@"com.iamstudio.cross.infinitemode"];
    NSMutableDictionary *products = [@{noAdsProduct.productIdentifier : noAdsProduct,
                                       threeHundredTouches.productIdentifier : threeHundredTouches,
                                       sevenHundredTouches.productIdentifier : sevenHundredTouches,
                                       twoThousandTouches.productIdentifier : twoThousandTouches,
                                       infiniteMode.productIdentifier : infiniteMode} mutableCopy];
    if (self = [super initWithProducts:products]) {
        
    }
    return self;
}

+(CPIAPHelper *)sharedInstance {
    static CPIAPHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)notifyStatusForProduct:(IAPProduct *)product
                 transactionID:(NSString *)transactionID
                        string:(NSString *)string {
    NSLog(@"************* TRANSACTION ID :%@", transactionID);
    NSLog(@"************* PRODUCT %@", product);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSuscribe" object:nil userInfo:@{@"TransactionID": transactionID,
                                                                                                        @"Product" : product}];
}

@end
