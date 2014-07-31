//
//  BFPaperTabBarController.m
//  BFPaperTabBar
//
//  Created by Bence Feher on 7/30/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//

#import "BFPaperTabBarController.h"

#import "BFPaperTabBar.h"
#import "UIColor+BFPaperColors.h"





@interface BFPaperTabBarController () <UIGestureRecognizerDelegate>
@end

@implementation BFPaperTabBarController

#pragma mark - Default Initializers, UIViewController Delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = [UIColor paperColorDeepPurpleA400];
    
    /*
     * Uncomment the lines below to see how you can customize the tab bar:
     */
//    ((BFPaperTabBar *)self.tabBar).rippleFromTapLocation = NO;  // YES = spawn tap-circles from tap locaiton. NO = spawn tap-circles from the center of the tab.
    
//    ((BFPaperTabBar *)self.tabBar).usesSmartColor = NO; // YES = colors are chosen from the tabBar.tintColor. NO = colors will be shades of gray.
    
//    ((BFPaperTabBar *)self.tabBar).tapCircleColor = [[UIColor paperColorLightBlue] colorWithAlphaComponent:0.2];    // Set this to customize the tap-circle color.
    
//    ((BFPaperTabBar *)self.tabBar).backgroundFadeColor = [UIColor paperColorGreen800];  // Set this to customize the background fade color.
    
//    ((BFPaperTabBar *)self.tabBar).tapCircleDiameter = bfPaperTabBar_tapCircleDiameterLarge;    // Set this to customize the tap-circle diameter.
    
//    ((BFPaperTabBar *)self.tabBar).underlineColor = [UIColor paperColorDeepPurpleA400]; // Set this to customize the color of the underline which highlights the currently selected tab.
    
//    ((BFPaperTabBar *)self.tabBar).showUnderline = NO;  // YES = show the underline bar, NO = hide the underline bar.
    
//    ((BFPaperTabBar *)self.tabBar).underlineThickness = 2.f;    // Set this to adjust the thickness (height) of the underline bar. Not that any value greater than 1 could cover up parts of the TabBarItem's title.
    
//    ((BFPaperTabBar *)self.tabBar).showTapCircleAndBackgroundFade = NO; // YES = show the tap-circles and add a color fade the background. NO = do not show the tap-circles and background fade.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
