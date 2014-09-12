//
//  TutorialContainerViewController.m
//  NumeroLoco
//
//  Created by Diego Vidal on 29/08/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "TutorialContainerViewController.h"
#import "FirstPageTutViewController.h"
#import "SecondPageTutViewController.h"
#import "ThirdPageTutViewController.h"
#import "FourthPageViewController.h"
#import "AppInfo.h"

@interface TutorialContainerViewController () <FirstPageTutDelegate,SecondPageTutDelegate, ThirdPageDelegate, FourthPageDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *viewControllersArray;
@end

@implementation TutorialContainerViewController

-(NSArray *)viewControllersArray {
    if (!_viewControllersArray) {
        FirstPageTutViewController *firstPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstPageTut"];
        firstPageVC.delegate = self;
        
        SecondPageTutViewController *secondPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondPageTut"];
        secondPageVC.delegate = self;
        
        ThirdPageTutViewController *thirdPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ThirdPageTut"];
        thirdPageVC.delegate = self;
        
        FourthPageViewController *fourthPageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FourthPage"];
        fourthPageVC.delegate = self;
        
        _viewControllersArray = @[firstPageVC, secondPageVC, thirdPageVC, fourthPageVC];
    }
    return _viewControllersArray;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.pageViewController setViewControllers:@[self.viewControllersArray[0]] direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //Dismiss button
    /*UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, self.view.bounds.size.height - 50.0, 70.0, 40.0)];
    [dismissButton setTitle:@"Close" forState:UIControlStateNormal];
    [dismissButton setTitleColor:[[AppInfo sharedInstance] appColorsArray][0] forState:UIControlStateNormal];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    dismissButton.layer.cornerRadius = 10.0;
    dismissButton.layer.borderWidth = 1.0;
    dismissButton.layer.borderColor = ((UIColor *)[[AppInfo sharedInstance] appColorsArray][0]).CGColor;
    [self.view addSubview:dismissButton];*/
}

#pragma mark - Navigation

-(void)returnToPageNumber:(NSUInteger)pageNumber {
    [self.pageViewController setViewControllers:@[self.viewControllersArray[pageNumber - 1]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
}

-(void)goToPageNumber:(NSUInteger)pageNumber {
    [self.pageViewController setViewControllers:@[self.viewControllersArray[pageNumber - 1]] direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

#pragma mark - Pages ViewControllers Delegates

-(void)firstPageButtonPressed {
    [self goToPageNumber:2];
}

-(void)secondPageContinueButtonPressed {
    [self goToPageNumber:3];
}

-(void)secondPageBackButtonPressed {
    [self returnToPageNumber:1];
}

-(void)thirdPageBackButtonPressed {
    [self returnToPageNumber:2];
}

-(void)thirdPageContinueButtonPressed {
    [self goToPageNumber:4];
}

-(void)fourthPageBackButtonPressed {
    [self returnToPageNumber:3];
}

-(void)fourthPageContinueButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)firstPageCloseButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)secondPageCloseButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)thirdPageCloseButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)fourthPageCloseButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
