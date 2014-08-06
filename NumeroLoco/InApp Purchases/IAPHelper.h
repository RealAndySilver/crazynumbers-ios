//
//  IAPHelper.h
//  CaracolPlay
//
//  Created by Developer on 4/03/14.
//  Copyright (c) 2014 iAmStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IAPProduct;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject
@property (strong, nonatomic) NSMutableDictionary *products;
-(instancetype)initWithProducts:(NSMutableDictionary *)products;
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
-(void)buyProduct:(IAPProduct *)product;
@end
