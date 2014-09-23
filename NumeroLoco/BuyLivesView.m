//
//  BuyLivesView.m
//  NumeroLoco
//
//  Created by Diego Vidal on 26/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "BuyLivesView.h"
#import "AppInfo.h"
#import "MBProgressHUD.h"
#import "CPIAPHelper.h"
#import "IAPProduct.h"
#import "Flurry.h"

@interface BuyLivesView()
@property (strong, nonatomic) UIView *opacityView;
@end

@implementation BuyLivesView

#define FONT_NAME @"HelveticaNeue-Light"
#define ITEMS_DISTANCE 20

-(instancetype)initWithFrame:(CGRect)frame pricesDic:(NSDictionary *)pricesDic {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transactionFailedNotificationReceived:)
                                                     name:@"TransactionFailedNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDidSuscribeNotificationReceived:)
                                                     name:@"UserDidSuscribe"
                                                   object:nil];
        
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        self.backgroundColor = [UIColor whiteColor];
        
        //Close button
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 5.0, 30.0, 30.0)];
        [closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1.0] forState:UIControlStateNormal];
        closeButton.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1.0].CGColor;
        closeButton.layer.borderWidth = 1.0;
        closeButton.layer.cornerRadius = 10.0;
        [closeButton addTarget:self action:@selector(closeAlert) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //Title
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, frame.size.width, 50.0)];
        title.text = NSLocalizedString(@"Buy Lives", @"Title for the buy lives screen");
        title.textColor = [[AppInfo sharedInstance] appColorsArray][0];
        title.font = [UIFont fontWithName:FONT_NAME size:25.0];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //300 touches image view
        UIImageView *threeTouchesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, frame.size.height/4.4 - 10.0, 60.0, 60.0)];
        threeTouchesImageView.image = [UIImage imageNamed:@"heart.png"];
        [self addSubview:threeTouchesImageView];
        
        //300 touches label
        UILabel *threeHundredLabel = [[UILabel alloc] initWithFrame:CGRectMake(threeTouchesImageView.frame.origin.x + threeTouchesImageView.frame.size.width, threeTouchesImageView.frame.origin.y, 100.0, threeTouchesImageView.frame.size.height)];
        threeHundredLabel.text = @"x 15";
        threeHundredLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        threeHundredLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:threeHundredLabel];
        
        //300 touches button
        NSString *itemPrice = pricesDic[@"priceForFive"];
        NSString *buttonTitle = [NSString stringWithFormat:@"%@", itemPrice];
        UIButton *threeTouchesButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 130.0, threeTouchesImageView.frame.origin.y + 10.0, 110.0, threeTouchesImageView.frame.size.height - 20.0)];
        [threeTouchesButton setTitle:buttonTitle forState:UIControlStateNormal];
        [threeTouchesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        threeTouchesButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        threeTouchesButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:17.0];
        threeTouchesButton.layer.cornerRadius = 10.0;
        threeTouchesButton.tag = 1;
        [threeTouchesButton addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:threeTouchesButton];
        itemPrice = nil;
        buttonTitle = nil;
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //700 touches image view
        UIImageView *sevenTouchesImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(threeTouchesImageView.frame, 0.0, threeTouchesImageView.frame.size.height + ITEMS_DISTANCE)];
        sevenTouchesImageView.image = [UIImage imageNamed:@"heart.png"];
        [self addSubview:sevenTouchesImageView];
        
        //700 touches label
        UILabel *sevenHundredLabel = [[UILabel alloc] initWithFrame:CGRectOffset(threeHundredLabel.frame, 0.0, threeHundredLabel.frame.size.height + ITEMS_DISTANCE)];
        sevenHundredLabel.text = @"x 30";
        sevenHundredLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        sevenHundredLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:sevenHundredLabel];
        
        //700 touches button
        itemPrice = pricesDic[@"priceForTwenty"];
        buttonTitle = [NSString stringWithFormat:@"%@", itemPrice];
        UIButton *sevenTouchesButton = [[UIButton alloc] initWithFrame:CGRectOffset(threeTouchesButton.frame, 0.0, threeTouchesButton.frame.size.height + ITEMS_DISTANCE*2)];
        [sevenTouchesButton setTitle:buttonTitle forState:UIControlStateNormal];
        [sevenTouchesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sevenTouchesButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        sevenTouchesButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:17.0];
        sevenTouchesButton.layer.cornerRadius = 10.0;
        sevenTouchesButton.tag = 2;
        [sevenTouchesButton addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sevenTouchesButton];
        buttonTitle = nil;
        itemPrice = nil;
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //2000 touches image view
        UIImageView *twoThousandImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(sevenTouchesImageView.frame, 0.0, sevenTouchesImageView.frame.size.height + ITEMS_DISTANCE)];
        twoThousandImageView.image = [UIImage imageNamed:@"heart.png"];
        [self addSubview:twoThousandImageView];
        
        //2000 touches label
        UILabel *twoThousandLabel = [[UILabel alloc] initWithFrame:CGRectOffset(sevenHundredLabel.frame, 0.0, sevenHundredLabel.frame.size.height + ITEMS_DISTANCE)];
        twoThousandLabel.text = @"x 80";
        twoThousandLabel.textColor = [UIColor darkGrayColor];
        twoThousandLabel.font = [UIFont fontWithName:FONT_NAME size:20.0];
        [self addSubview:twoThousandLabel];
        
        //2000 touches button
        itemPrice = pricesDic[@"priceForSixty"];
        buttonTitle = [NSString stringWithFormat:@"%@", itemPrice];
        UIButton *twoThousandButton = [[UIButton alloc] initWithFrame:CGRectOffset(sevenTouchesButton.frame, 0.0, sevenTouchesButton.frame.size.height + ITEMS_DISTANCE*2)];
        [twoThousandButton setTitle:buttonTitle forState:UIControlStateNormal];
        [twoThousandButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        twoThousandButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        twoThousandButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:17.0];
        twoThousandButton.layer.cornerRadius = 10.0;
        twoThousandButton.tag = 3;
        [twoThousandButton addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:twoThousandButton];
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Infinite touches
        UIImageView *infiniteTouchesView = [[UIImageView alloc] initWithFrame:CGRectOffset(twoThousandImageView.frame, 0.0, twoThousandImageView.frame.size.height + ITEMS_DISTANCE)];
        infiniteTouchesView.image = [UIImage imageNamed:@"heart.png"];
        [self addSubview:infiniteTouchesView];
        
        //Infinite label
        UILabel *infiniteLabel = [[UILabel alloc] initWithFrame:CGRectMake(infiniteTouchesView.frame.origin.x + infiniteTouchesView.frame.size.width + 10.0, infiniteTouchesView.frame.origin.y, 150.0, 60.0)];
        infiniteLabel.numberOfLines = 0;
        infiniteLabel.text = NSLocalizedString(@"Infinite Touches\nInfinite Lives\nNo Ads", @"A message indicating that if the user buy this item, the user will get inifinite lives, touches and no Ads");
        infiniteLabel.textColor = [UIColor darkGrayColor];
        infiniteLabel.font = [UIFont fontWithName:FONT_NAME size:15.0];
        [self addSubview:infiniteLabel];
        
        //Infinite button
        itemPrice = pricesDic[@"infinitemode"];
        buttonTitle = [NSString stringWithFormat:@"%@", itemPrice];
        UIButton *infiniteButton = [[UIButton alloc] initWithFrame:CGRectMake(infiniteLabel.frame.origin.x, infiniteLabel.frame.origin.y + infiniteLabel.frame.size.height, 110.0, 40.0)];
        [infiniteButton setTitle:buttonTitle forState:UIControlStateNormal];
        [infiniteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        infiniteButton.backgroundColor = [[AppInfo sharedInstance] appColorsArray][0];
        infiniteButton.titleLabel.font = [UIFont fontWithName:FONT_NAME size:17.0];
        infiniteButton.layer.cornerRadius = 10.0;
        infiniteButton.tag = 4;
        [infiniteButton addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infiniteButton];
        buttonTitle = nil;
        itemPrice = nil;
    }
    return self;
}

-(void)showInView:(UIView *)view {
    self.opacityView = [[UIView alloc] initWithFrame:view.frame];
    self.opacityView.backgroundColor = [UIColor blackColor];
    self.opacityView.alpha = 0.0;
    [view addSubview:self.opacityView];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.opacityView.alpha = 0.7;
                         self.alpha = 1.0;
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished){}];
}

#pragma mark - Actions

-(void)closeAlert {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         self.alpha = 0.0;
                         self.opacityView.alpha = 0.0;
                         self.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [self.opacityView removeFromSuperview];
                         self.opacityView = nil;
                         [self.delegate buyLivesViewDidDisappear:self];
                     }];
}

-(void)buyProduct:(UIButton *)button {
    NSUInteger buttonTag = button.tag;
    NSString *productIdentifier = nil;
    switch (buttonTag) {
        case 1:
            productIdentifier = @"com.iamstudio.cross.fivelives";
            break;
            
        case 2:
            productIdentifier = @"com.iamstudio.cross.twentylives";
            break;
            
        case 3:
            productIdentifier = @"com.iamstudio.cross.sixtylives";
            break;
            
        case 4:
            productIdentifier = @"com.iamstudio.cross.infinitemode";
            break;
            
        default:
            break;
    }
    
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[CPIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
        if (success) {
            for (int i = 0; i < [products count]; i++) {
                IAPProduct *product = products[i];
                if ([product.productIdentifier isEqualToString:productIdentifier]) {
                    [[CPIAPHelper sharedInstance] buyProduct:product];
                    break;
                }
            }
        }
    }];
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
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 15];
        [self.delegate moreLivesBought:[self getLivesAvailable] inView:self];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.twentylives"]) {
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 30];
        [self.delegate moreLivesBought:[self getLivesAvailable] inView:self];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.sixtylives"]) {
        [self saveLivesLeftInUserDefaults:[self getLivesAvailable] + 80];
        [self.delegate moreLivesBought:[self getLivesAvailable] inView:self];
        
    } else if ([productBought.productIdentifier isEqualToString:@"com.iamstudio.cross.infinitemode"]) {
        [self saveInfiniteModeInUserDefaults];
        [self.delegate infiniteModeBoughtInView:self];
    }
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

@end
