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
    NSMutableDictionary *products = [@{noAdsProduct.productIdentifier : noAdsProduct} mutableCopy];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidSuscribe" object:nil userInfo:@{@"TransactionID": transactionID}];
}

@end
