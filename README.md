BFPaperTabBar
=============
[Please consider using BFPaperTabBarController instead!!!](https://github.com/bfeher/BFPaperTabBarController)<br />

[![CocoaPods](https://img.shields.io/cocoapods/v/BFPaperTabBar.svg?style=flat)](https://github.com/bfeher/BFPaperTabBar)

> iOS UITabBar inspired by Google's Paper Material Design.

![Animated Screenshot](https://raw.githubusercontent.com/bfeher/BFPaperTabBar/master/BFPaperTabBarDemoGif.gif "Animated Screenshot")<br />
*(The tiny dot on the bottom left is just the rounded corner of the iOS simulator showing. Also note that sometimes the iOS Simulator might show some strange color lines on the BFPaperTabBar. This does not show up on a real device.*


To Do
---------
[Convince you to use BFPaperTabBarController instead!!!](https://github.com/bfeher/BFPaperTabBarController)<br />
Reordering tabs.<br />
Adding/Removing tabs.<br />
Stop crying while trying to implement the above.


About
---------
_BFPaperTabBar_ is a subclass of UITabBar that behaves much like the new paper tab bar from Google's Material Design Labs.
All animation are asynchronous and are performed on sublayers.
BFPaperTabBars work right away with pleasing default behaviors, however they can be easily customized! The tap-circle color, background fade color, tap-circle diameter, underline color, and underline thickness are all readily customizable via public properties.

By default, BFPaperTabBars use "Smart Color" which will match the tap-circle, background fade, and underline bar colors to the color of the `tabBar.tintColor`.
You can turn off Smart Color by setting the property, `.usesSmartColor` to `NO`. If you disable Smart Color, a gray color will be used by default for both the tap-circle and the background color fade.
You can set your own colors via: `.tapCircleColor` and `.backgroundFadeColor`. Note that setting these disables Smart Color.

## Properties
`BOOL usesSmartColor` <br />
A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is the default (usesSmartColor = YES), customization is cool too.

`UIColor *tapCircleColor` <br />
The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended.

`UIColor *backgroundFadeColor` <br />
The UIColor to fade clear backgrounds to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. An alpha value of 1 is recommended, as the fade is a constant (clearBGFadeConstant) defined in the BFPaperTabBar.m. This bothers me too.

`CGFloat tapCircleDiameter` <br />
The CGFloat value representing the Diameter of the tap-circle. By default it will be calculated to almost be big enough to cover up the whole background. Any value less than zero will result in default being used. Three pleasing sizes, `bfPaperTabBar_tapCircleDiameterSmall`, `bfPaperTabBar_tapCircleDiameterMedium`, and `bfPaperTabBar_tapCircleDiameterLarge` are also available for use.

`BOOL rippleFromTapLocation`<br />
A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the tab. Default is YES.

`UIColor *underlineColor`<br />
The UIColor to use for the underline below the currently selected tab. NOTE: Setting this defeats the "Smart Color" ability of this underline.

`CGFloat underlineThickness` <br />
The CGFLoat to set the thickness (height) of the underline. NOTE: Any value greater than 1 will cover up the bottoms of low-hanging letters of a default TabBarItem's title.

`BOOL showUnderline`<br />
A flag to set to YES to show an underline bar that tracks the currently selected tab.

`BOOL showTapCircleAndBackgroundFade`<br />
A flag to set to YES to show the tap-circle and background fade. If NO, they will not appear.


Usage
---------
Add the _BFPaperTabBar_ header and implementation file to your project. (.h & .m)

### Using Storyboards
The easiest way to use a BFPaperTabBar is to set up a UITabBarController in your Storyboard and then set its UITabBar's class to BFPaperTabBar.
![Set Class](https://raw.githubusercontent.com/bfeher/BFPaperTabBar/master/set-class.png "Set Class")

### Programmatically Creating a BFPaperTabBar
```objective-c
BFPaperTabBar *tabBar = [[BFPaperTabBar alloc] init];
```

### Customized Example
*After setting your UITabBarController's UITabBar class to BFPaperTabBar: (Taken directly from example project.)*<br />
```objective-c
((BFPaperTabBar *)self.tabBar).rippleFromTapLocation = NO;  // YES = spawn tap-circles from tap locaiton. NO = spawn tap-circles from the center of the tab.
    
((BFPaperTabBar *)self.tabBar).usesSmartColor = NO; // YES = colors are chosen from the tabBar.tintColor. NO = colors will be shades of gray.
    
((BFPaperTabBar *)self.tabBar).tapCircleColor = [[UIColor paperColorLightBlue] colorWithAlphaComponent:0.2];    // Set this to customize the tap-circle color.
    
((BFPaperTabBar *)self.tabBar).backgroundFadeColor = [UIColor paperColorGreen800];  // Set this to customize the background fade color.
    
((BFPaperTabBar *)self.tabBar).tapCircleDiameter = bfPaperTabBar_tapCircleDiameterLarge;    // Set this to customize the tap-circle diameter.
    
((BFPaperTabBar *)self.tabBar).underlineColor = [UIColor paperColorDeepPurpleA400]; // Set this to customize the color of the underline which highlights the currently selected tab.
   
((BFPaperTabBar *)self.tabBar).showUnderline = NO;  // YES = show the underline bar, NO = hide the underline bar.
    
((BFPaperTabBar *)self.tabBar).underlineThickness = 2.f;    // Set this to adjust the thickness (height) of the underline bar. Not that any value greater than 1 could cover up parts of the TabBarItem's title.
    
((BFPaperTabBar *)self.tabBar).showTapCircleAndBackgroundFade = NO; // YES = show the tap-circles and add a color fade the background. NO = do not show the tap-circles and background fade.
```

Cocoapods
-------

CocoaPods are the best way to manage library dependencies in Objective-C projects.
Learn more at http://cocoapods.org

Add this to your podfile to add BFPaperTabBar to your project.
```ruby
platform :ios, '7.0'
pod 'BFPaperTabBar', '~> 1.0.4'
```


License
--------
_BFPaperTabBar_ uses the MIT License:

> Please see included [LICENSE file](https://raw.githubusercontent.com/bfeher/BFPaperTabBar/master/LICENSE.md).
