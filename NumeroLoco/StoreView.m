//
//  StoreView.m
//  NumeroLoco
//
//  Created by Developer on 11/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "StoreView.h"
#import "AppInfo.h"
#import "IAPProduct.h"
#import "StoreProductsCell.h"
#import "AppInfo.h"
#import "MBProgressHUD.h"
#import "CPIAPHelper.h"
#import "TouchesObject.h"
#import "FileSaver.h"
#import "Flurry.h"

@interface StoreView() <UITableViewDataSource, UITableViewDelegate, StoreProductsCellDelegate>
@property (strong, nonatomic) UIView *opacityView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *purchasesIDsArray;
@property (strong, nonatomic) NSArray *purchasesImagesArray;
@property (strong, nonatomic) NSNumberFormatter *purchasesPriceFormatter;
@end

@implementation StoreView

#define FONT_NAME @"HelveticaNeue-Light"
#define CELL_IDENTIFIER @"cellid"

-(NSNumberFormatter *)purchasesPriceFormatter {
    if (!_purchasesPriceFormatter) {
        _purchasesPriceFormatter = [[NSNumberFormatter alloc] init];
        _purchasesPriceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
        _purchasesPriceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    return _purchasesPriceFormatter;
}

-(NSArray *)purchasesImagesArray {
    if (!_purchasesImagesArray) {
        _purchasesImagesArray = @[@"heart.png", @"heart.png", @"heart.png", @"Touch2.png", @"Touch2.png", @"Touch2.png", @"NoAds.png", @"infinite.png"];
    }
    return _purchasesImagesArray;
}

-(void)setPurchasesDic:(NSDictionary *)purchasesDic {
    _purchasesDic = purchasesDic;
    [self.tableView reloadData];
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transactionFailedNotificationReceived:)
                                                     name:@"TransactionFailedNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidSuscribeNotificationReceived:)
                                                     name:@"UserDidSuscribe"
                                                   object:nil];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        //[closeButton setImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.borderWidth = 1.0;
        closeButton.layer.cornerRadius = 10.0;
        closeButton.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 50.0)];
        title.text = @"Store";
        title.textColor = [[AppInfo sharedInstance] appColorsArray][0];
        title.font = [UIFont fontWithName:FONT_NAME size:25.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        //Purchases table view
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 100.0, frame.size.width, frame.size.height - 100.0) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[StoreProductsCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.rowHeight = 80.0;
        self.tableView.layer.cornerRadius = 10.0;
        self.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.tableView];
        self.purchasesIDsArray = @[@"fiveLives", @"twentyLives", @"sixtyLives", @"threeHundredTouches", @"sevenHundredTouches", @"twoThousandTouches", @"noAds", @"infiniteMode"];
    }
    return self;
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.purchasesIDsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreProductsCell *cell = (StoreProductsCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[StoreProductsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.delegate = self;
    
    IAPProduct *product = self.purchasesDic[self.purchasesIDsArray[indexPath.row]];
    NSString *productName = product.skProduct.localizedTitle;
    if ([product.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
        productName = @"Infinite Touches\nInfinite Lives\nNo Ads";
    }
    self.purchasesPriceFormatter.locale = product.skProduct.priceLocale;
    [cell.buyButton setTitle:[self.purchasesPriceFormatter stringFromNumber:product.skProduct.price] forState:UIControlStateNormal];
    cell.productName.text = productName;
    cell.productImageView.image = [UIImage imageNamed:self.purchasesImagesArray[indexPath.row]];
    if (indexPath.row < 3) {
        cell.buyButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
    } else {
        cell.buyButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][2];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    [view addSubview:self];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.opacityView.alpha = 0.7;
                     } completion:nil];
}

-(void)closeView {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         self.opacityView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.opacityView removeFromSuperview];
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Purchases

-(void)buyProduct:(IAPProduct *)product {
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[CPIAPHelper sharedInstance] buyProduct:product];
}

#pragma mark - NSUserDefaults

-(void)saveInfiniteModeInUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"infiniteMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSUInteger)getLivesAvailable {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"lives"] intValue];
}

-(void)saveLivesLeftInUserDefaults:(NSUInteger)lives {
    [[NSUserDefaults standardUserDefaults] setObject:@(lives) forKey:@"lives"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSUInteger)getTouchesAvailable {
    NSLog(@"Toques disponibles en este momento: %i", [[[NSUserDefaults standardUserDefaults] objectForKey:@"Touches"] intValue]);
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"Touches"] intValue];
}

-(void)saveTouchesLeftInUserDefaults:(NSUInteger)touchesLeft {
    NSLog(@"***************** guardaré %d toques ******************", touchesLeft);
    [[NSUserDefaults standardUserDefaults] setObject:@(touchesLeft) forKey:@"Touches"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TouchesObject sharedInstance].totalTouches = touchesLeft;
}

-(void)removeTouchesSavedDateInUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NoTouchesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeLivesSavedDateInUserDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NoLivesDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - StoreProductsCellDelegate

-(void)buyButtonPressedInCell:(StoreProductsCell *)storeProductsCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:storeProductsCell];
    NSLog(@"Compre el producto en la posicion %d", indexPath.row);
    IAPProduct *product = self.purchasesDic[self.purchasesIDsArray[indexPath.row]];
    [self buyProduct:product];
}

#pragma mark - Notification Handlers

-(void)transactionFailedNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    NSLog(@"Falló la transacción");
    NSDictionary *notificationInfo = [notification userInfo];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:notificationInfo[@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)userDidSuscribeNotificationReceived:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    NSLog(@"me llegó la notficación de que el usuario compró la suscripción");
    
    IAPProduct *productBought = [notification userInfo][@"Product"];
    [Flurry logEvent:@"ItemBought" withParameters:@{@"ItemID" : productBought.productIdentifier}];
    NSLog(@"Producto comprado: %@", productBought.productIdentifier);
    
    if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.fivelives"]) {
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 5];
        [self removeLivesSavedDateInUserDefaults];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.twentylives"]) {
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 20];
        [self removeLivesSavedDateInUserDefaults];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.sixtylives"]) {
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 60];
        [self removeLivesSavedDateInUserDefaults];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
        [self saveInfiniteModeInUserDefaults];
        [self removeLivesSavedDateInUserDefaults];
        [self removeTouchesSavedDateInUserDefaults];
    
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.threehundredtouches"]) {
        [self saveTouchesLeftInUserDefaults:[self getTouchesAvailable] + 300];
        [self removeTouchesSavedDateInUserDefaults];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.sevenhundredtouches"]) {
        [self saveTouchesLeftInUserDefaults:[self getTouchesAvailable] + 700];
        [self removeTouchesSavedDateInUserDefaults];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.twothousandtouches"]) {
        [self saveTouchesLeftInUserDefaults:[self getTouchesAvailable] + 2000];
        [self removeTouchesSavedDateInUserDefaults];
    
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.noads"]) {
        //Save a key in FileSaver indicating that the user has removed the ads
        FileSaver *fileSaver = [[FileSaver alloc] init];
        [fileSaver setDictionary:@{@"UserRemovedAdsKey" : @YES} withName:@"UserRemovedAdsDic"];
    }
}

@end
