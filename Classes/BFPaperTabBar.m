//
//  BFPaperTabBar.m
//  BFPaperTabBar
//
//  Created by Bence Feher on 7/30/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Bence Feher
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "BFPaperTabBar.h"

@interface BFPaperTabBar () <UIGestureRecognizerDelegate>
@property CALayer *backgroundColorFadeLayer;
@property BOOL growthFinished;
@property NSMutableArray *rippleAnimationQueue;
@property CGPoint tapPoint;
@property NSInteger selectedTabIndex;
@property CALayer *underlineLayer;
@end


@implementation BFPaperTabBar
static dispatch_once_t oncePredicate;   // Used for initializing tab touch gesture recognizers only once.
// Constants used for tweaking the look/feel of:
// -animation durations:
static CGFloat const bfPaperTabBar_animationDurationConstant       = 0.2f;
static CGFloat const bfPaperTabBar_tapCircleGrowthDurationConstant = bfPaperTabBar_animationDurationConstant * 2;
// -the tap-circle's size:
static CGFloat const bfPaperTabBar_tapCircleDiameterStartValue     = 5.f;   // for the mask
// -the tap-circle's beauty:
static CGFloat const bfPaperTabBar_tapFillConstant                 = 0.16f;
static CGFloat const bfPaperTabBar_backgroundFadeConstant          = 0.12f;
// -the bg fade box and underline's padding:
#define BFPAPERTABBAR__PADDING                                     CGPointMake(2.f, 1.f)    // This should probably be left alone. Though the values in the range ([0, 2], [0 1]) all work and change the look a bit.
// - Default colors:
#define BFPAPERTABBAR__DUMB_TAP_FILL_COLOR  [UIColor colorWithWhite:0.1 alpha:bfPaperTabBar_tapFillConstant]
#define BFPAPERTABBAR__DUMB_BG_FADE_COLOR   [UIColor colorWithWhite:0.3 alpha:1]



#pragma mark - Default Initializers
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}


#pragma mark - Parent Overrides
- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    [super setSelectedItem:selectedItem];
    
    //NSLog(@"chose index %d", selectedItem.tag);
    if (self.showUnderline) {
        [self setUnderlineForTabIndex:selectedItem.tag animated:NO];
    }
}

- (BOOL)endCustomizingAnimated:(BOOL)animated
{
    // Re-tag each bar item:
    [self indexTabs];
    return [super endCustomizingAnimated:animated];
}

-(void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    
    if (self.showUnderline) {
        [self setUnderlineForTabIndex:self.selectedTabIndex animated:YES];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    dispatch_once(&oncePredicate, ^{
        // Add gesture recognizers to each tabBarItem's view and tag them:
        [self addGestureRecognizerToTabs];
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - Setters and Getters
- (void)setShowUnderline:(BOOL)showUnderline
{
    if (_showUnderline != showUnderline) {
        _showUnderline = showUnderline;
        
        if (!_showUnderline) {
            [self.underlineLayer removeFromSuperlayer];
        }
        else if (!self.underlineLayer) {
            CGFloat y = (self.underlineThickness <= 1) ? self.bounds.size.height : self.bounds.size.height - (self.underlineThickness / 2);
            self.underlineLayer = [CALayer layer];
            self.underlineLayer.frame = CGRectMake(self.bounds.origin.x, y, self.bounds.size.width, self.underlineThickness);
            [self.layer addSublayer:self.underlineLayer];
            [self setUnderlineForTabIndex:0 animated:NO];
        }
    }
}


#pragma mark - Setup
- (void)setup
{
//    self.paperDelegate = [[BFPaperTabBarDelegate alloc] init];
//    self.delegate = self.paperDelegate;
    
    
    // Defaults:
    self.usesSmartColor = YES;
    self.tapCircleDiameter = -1.f;
    self.rippleFromTapLocation = YES;
    self.showUnderline = YES;
    self.underlineThickness = 1.f;
    self.showTapCircleAndBackgroundFade = YES;
    
    self.rippleAnimationQueue = [NSMutableArray array];
    
    [self setBackgroundFadeLayerForTabAtIndex:0];

    [self setUnderlineForTabIndex:0 animated:NO];
    
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    
    self.tapCircleColor = nil;
    self.backgroundFadeColor = nil;
    self.underlineColor = nil;
}

- (void)setBackgroundFadeLayerForTabAtIndex:(NSInteger)index
{
    [self.backgroundColorFadeLayer removeFromSuperlayer];
    
    UIView *tab = [self viewForTabBarItemAtIndex:index];
    
    CGFloat x = tab.bounds.origin.x;
    CGFloat y = tab.bounds.origin.y - BFPAPERTABBAR__PADDING.y;
    CGFloat w = tab.frame.size.width;
    CGFloat h = tab.frame.size.height + BFPAPERTABBAR__PADDING.y;
    if (index == self.items.count - 1) {
        // Last tab, so we extend the underline's width a bit to reach the right end of the screen.
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else if (index == 0) {
        // First tab, so we extend the width a bit and shift the x origin to reach the left end of the screen.
        x = x - BFPAPERTABBAR__PADDING.x;
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else {
        // Middle ones should stretch out to their neighbors:
        x = x - (BFPAPERTABBAR__PADDING.x * 2);
        w = w + (BFPAPERTABBAR__PADDING.x * 4);
    }
    

    CGRect endRect = CGRectMake(x, y , w, h);
    
    self.backgroundColorFadeLayer = [[CALayer alloc] init];
    self.backgroundColorFadeLayer.frame = endRect;
    self.backgroundColorFadeLayer.backgroundColor = [UIColor clearColor].CGColor;
    [tab.layer insertSublayer:self.backgroundColorFadeLayer atIndex:0];
}

- (void)setUnderlineForTabIndex:(NSInteger)index animated:(BOOL)animated
{
    CGFloat duration = animated ? bfPaperTabBar_animationDurationConstant : 0.f;
    
    UIView *tab = [self viewForTabBarItemAtIndex:index];
    
    UIColor *bgColor = self.underlineColor;
    if (!bgColor) {
        bgColor = self.usesSmartColor ? self.tintColor : [BFPAPERTABBAR__DUMB_TAP_FILL_COLOR colorWithAlphaComponent:1.f];
    }
    self.underlineLayer.backgroundColor = bgColor.CGColor;
    CGFloat x = tab.frame.origin.x;
    CGFloat y = (self.underlineThickness <= 1) ? tab.bounds.size.height : tab.bounds.size.height - (self.underlineThickness / 2);
    CGFloat w = tab.frame.size.width;
    
    if (index == self.items.count - 1) {
        // Last tab, so we extend the underline's width a bit to reach the right end of the screen.
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else if (index == 0) {
        // First tab, so we extend the width a bit and shift the x origin to reach the left end of the screen.
        x = x - BFPAPERTABBAR__PADDING.x;
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else {
        // Middle ones should stretch out to their neighbors:
        x = x - (BFPAPERTABBAR__PADDING.x * 2);
        w = w + (BFPAPERTABBAR__PADDING.x * 4);
    }


    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.underlineLayer.frame = CGRectMake(x, y, w, self.underlineThickness);
    } completion:^(BOOL finished) {
    }];
}


- (void)addGestureRecognizerToTabs
{
    for (int i = 0; i < self.items.count; i++) {
        ((UITabBarItem *)[self.items objectAtIndex:i]).tag = i;
        UIView *tabView = [self viewForTabBarItemAtIndex:i];
        tabView.tag = i;
        
        //NSLog(@"adding GR to tab %@ (%d)", ((UITabBarItem *)[self.items objectAtIndex:i]).title, i);
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        press.delegate = self;
        press.delaysTouchesEnded = NO;
        press.delaysTouchesBegan = NO;
        press.cancelsTouchesInView = NO;
        press.minimumPressDuration = 0;
        [tabView addGestureRecognizer:press];
        press = nil;
    }
}

- (void)indexTabs
{
    for (int i = 0; i < self.items.count; i++) {
        UITabBarItem *tab = [self.items objectAtIndex:i];
        //NSLog(@"applying index %d to %@", i, tab.title);
        tab.tag = i;
        UIView *tabView = [self viewForTabBarItemAtIndex:i];
        tabView.tag = i;
    }
}


#pragma mark - Gesture Recognizer Handlers
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        // Draw tap-circle:
        
        self.selectedTabIndex = longPress.view.tag;
        
        self.tapPoint = [longPress locationInView:[self viewForTabBarItemAtIndex:self.selectedTabIndex]];
        
        if (self.showTapCircleAndBackgroundFade) {
            [self growTapCircle];
        }
    }
    else if (longPress.state == UIGestureRecognizerStateEnded
             ||
             longPress.state == UIGestureRecognizerStateCancelled
             ||
             longPress.state == UIGestureRecognizerStateFailed) {
        // Remove tap-circle:
        
        if (self.showTapCircleAndBackgroundFade) {
            if (self.growthFinished) {
                [self growTapCircleABit];
            }
            [self fadeTapCircleOut];
            [self fadeBackgroundOut];
        }
    }
}


#pragma mark - Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
#pragma mark -


- (UIView *)viewForTabBarItemAtIndex:(NSInteger)index
{
    
    CGRect tabBarRect = self.frame;
    NSInteger buttonCount = self.items.count;
    CGFloat containingWidth = tabBarRect.size.width / buttonCount;
    CGFloat originX = containingWidth * index ;
    CGRect containingRect = CGRectMake( originX, 0, containingWidth, self.frame.size.height );
    CGPoint center = CGPointMake( CGRectGetMidX(containingRect), CGRectGetMidY(containingRect));
    
    return [self hitTest:center withEvent:nil];
}


#pragma mark - Animation
- (void)growTapCircle
{
    //NSLog(@"expanding a tap circle");

    // Spawn a growing circle that "ripples" through the button:
    
    UIView *tab = [self viewForTabBarItemAtIndex:self.selectedTabIndex];
    
    CGFloat x = tab.bounds.origin.x;
    CGFloat y = tab.bounds.origin.y - BFPAPERTABBAR__PADDING.y;
    CGFloat w = tab.frame.size.width;
    CGFloat h = tab.frame.size.height + BFPAPERTABBAR__PADDING.y;
    if (self.selectedTabIndex == self.items.count - 1) {
        // Last tab, so we extend the underline's width a bit to reach the right end of the screen.
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else if (self.selectedTabIndex == 0) {
        // First tab, so we extend the width a bit and shift the x origin to reach the left end of the screen.
        x = x - BFPAPERTABBAR__PADDING.x;
        w = w + BFPAPERTABBAR__PADDING.x;
    }
    else {
        // Middle ones should stretch out to their neighbors:
        x = x - (BFPAPERTABBAR__PADDING.x * 2);
        w = w + (BFPAPERTABBAR__PADDING.x * 4);
    }


    CGRect endRect = CGRectMake(x, y , w, h);
    
    
    CALayer *tempAnimationLayer = [CALayer new];
    tempAnimationLayer.frame = endRect;
    tempAnimationLayer.cornerRadius = tab.layer.cornerRadius;
    
    
    // Set the fill color for the tap circle (self.animationLayer's fill color):
    if (!self.tapCircleColor) {
        self.tapCircleColor = self.usesSmartColor ? [self.tintColor colorWithAlphaComponent:bfPaperTabBar_tapFillConstant] : BFPAPERTABBAR__DUMB_TAP_FILL_COLOR;
    }
        
    if (!self.backgroundFadeColor) {
        self.backgroundFadeColor = self.usesSmartColor ? self.tintColor : BFPAPERTABBAR__DUMB_BG_FADE_COLOR;
    }
        
    // Setup background fade layer:
    [self setBackgroundFadeLayerForTabAtIndex:self.selectedTabIndex];
    self.backgroundColorFadeLayer.backgroundColor = self.backgroundFadeColor.CGColor;
        
    // Fade the background color a bit darker:
    CABasicAnimation *fadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeBackgroundDarker.duration = bfPaperTabBar_animationDurationConstant;
    fadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:0.f];
    fadeBackgroundDarker.toValue = [NSNumber numberWithFloat:bfPaperTabBar_backgroundFadeConstant];
    fadeBackgroundDarker.fillMode = kCAFillModeForwards;
    fadeBackgroundDarker.removedOnCompletion = NO;
    
    [self.backgroundColorFadeLayer addAnimation:fadeBackgroundDarker forKey:@"animateOpacity"];
    
    // Set animation layer's background color:
    tempAnimationLayer.backgroundColor = self.tapCircleColor.CGColor;
    tempAnimationLayer.borderColor = [UIColor clearColor].CGColor;
    tempAnimationLayer.borderWidth = 0;
    
    
    // Animation Mask Rects
    CGPoint origin = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(tab.bounds), CGRectGetMidY(tab.bounds));
    //NSLog(@"self.center: (x%0.2f, y%0.2f)", self.center.x, self.center.y);
    UIBezierPath *startingTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (bfPaperTabBar_tapCircleDiameterStartValue / 2.f), origin.y - (bfPaperTabBar_tapCircleDiameterStartValue / 2.f), bfPaperTabBar_tapCircleDiameterStartValue, bfPaperTabBar_tapCircleDiameterStartValue) cornerRadius:bfPaperTabBar_tapCircleDiameterStartValue / 2.f];
    
    CGFloat tapCircleDiameterEndValue = (self.tapCircleDiameter < 0) ? MAX(tab.frame.size.width, tab.frame.size.height) : self.tapCircleDiameter;
    UIBezierPath *endTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (tapCircleDiameterEndValue/ 2.f), origin.y - (tapCircleDiameterEndValue/ 2.f), tapCircleDiameterEndValue, tapCircleDiameterEndValue) cornerRadius:tapCircleDiameterEndValue/ 2.f];
    
    // Animation Mask Layer:
    CAShapeLayer *animationMaskLayer = [CAShapeLayer layer];
    animationMaskLayer.path = endTapCirclePath.CGPath;
    animationMaskLayer.fillColor = [UIColor blackColor].CGColor;
    animationMaskLayer.strokeColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderWidth = 0;
    
    tempAnimationLayer.mask = animationMaskLayer;
    
    // Grow tap-circle animation:
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.delegate = self;
    [tapCircleGrowthAnimation setValue:@"tapGrowth" forKey:@"id"];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    tapCircleGrowthAnimation.duration = bfPaperTabBar_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingTapCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endTapCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    // Fade in self.animationLayer:
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = bfPaperTabBar_animationDurationConstant;
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = NO;
    
    
    // Add the animation layer to our animation queue and insert it into our view:
    [self.rippleAnimationQueue addObject:tempAnimationLayer];
    [tab.layer insertSublayer:tempAnimationLayer above:self.backgroundColorFadeLayer];
    
    [animationMaskLayer addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
    [tempAnimationLayer addAnimation:fadeIn forKey:@"opacityAnimation"];
}


- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag
{
    //NSLog(@"animation ENDED");
    self.growthFinished = YES;
}


- (void)fadeBackgroundOut
{
    // NSLog(@"fading bg");
    
    // Remove darkened background fade:
    CABasicAnimation *removeFadeBackgroundDarker = [CABasicAnimation animationWithKeyPath:@"opacity"];
    removeFadeBackgroundDarker.duration = bfPaperTabBar_animationDurationConstant;
    removeFadeBackgroundDarker.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    removeFadeBackgroundDarker.fromValue = [NSNumber numberWithFloat:bfPaperTabBar_backgroundFadeConstant];
    removeFadeBackgroundDarker.toValue = [NSNumber numberWithFloat:0.f];
    removeFadeBackgroundDarker.fillMode = kCAFillModeForwards;
    removeFadeBackgroundDarker.removedOnCompletion = NO;
        
    [self.backgroundColorFadeLayer addAnimation:removeFadeBackgroundDarker forKey:@"removeBGShade"];
}


- (void)growTapCircleABit
{
    //NSLog(@"expanding a bit more");
    
    UIView *tab = [self viewForTabBarItemAtIndex:self.selectedTabIndex];
    
    CALayer *tempAnimationLayer = [self.rippleAnimationQueue firstObject];
    
    // Animation Mask Rects
    CGFloat newTapCircleStartValue = (self.tapCircleDiameter < 0) ? MAX(tab.frame.size.width, tab.frame.size.height) : self.tapCircleDiameter;
    
    CGPoint origin = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(tab.bounds), CGRectGetMidY(tab.bounds));
    UIBezierPath *startingTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (newTapCircleStartValue / 2.f), origin.y - (newTapCircleStartValue / 2.f), newTapCircleStartValue, newTapCircleStartValue) cornerRadius:newTapCircleStartValue / 2.f];
    
    CGFloat tapCircleDiameterEndValue = (self.tapCircleDiameter < 0) ? MAX(tab.frame.size.width, tab.frame.size.height) : self.tapCircleDiameter;
    tapCircleDiameterEndValue += 40.f;
    UIBezierPath *endTapCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (tapCircleDiameterEndValue/ 2.f), origin.y - (tapCircleDiameterEndValue/ 2.f), tapCircleDiameterEndValue, tapCircleDiameterEndValue) cornerRadius:tapCircleDiameterEndValue/ 2.f];
    
    // Animation Mask Layer:
    CAShapeLayer *animationMaskLayer = [CAShapeLayer layer];
    animationMaskLayer.path = endTapCirclePath.CGPath;
    animationMaskLayer.fillColor = [UIColor blackColor].CGColor;
    animationMaskLayer.strokeColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderColor = [UIColor clearColor].CGColor;
    animationMaskLayer.borderWidth = 0;
    
    tempAnimationLayer.mask = animationMaskLayer;
    
    // Grow tap-circle animation:
    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    tapCircleGrowthAnimation.duration = bfPaperTabBar_tapCircleGrowthDurationConstant;
    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    tapCircleGrowthAnimation.fromValue = (__bridge id)startingTapCirclePath.CGPath;
    tapCircleGrowthAnimation.toValue = (__bridge id)endTapCirclePath.CGPath;
    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
    tapCircleGrowthAnimation.removedOnCompletion = NO;
    
    [animationMaskLayer addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
}


- (void)fadeTapCircleOut
{
    //NSLog(@"Fading away");
    
    CALayer *tempAnimationLayer = [self.rippleAnimationQueue firstObject];
    [self.rippleAnimationQueue removeObjectAtIndex:0];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = [NSNumber numberWithFloat:tempAnimationLayer.opacity];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.duration = bfPaperTabBar_tapCircleGrowthDurationConstant;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = NO;
    
    [tempAnimationLayer addAnimation:fadeOut forKey:@"opacityAnimation"];
}
#pragma mark -

@end
