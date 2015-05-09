![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/carbonkit_logo.png)

CarbonKit is an iOS OpenSource libraries collection.
Like the Carbon is the base of the life, I started CarbonKit to be base of great apps ;-)
Fork & Contribute CarbonKit to make it better.

CarbonKit includes:
- CarbonSwipeRefresh
- CarbonTabSwipeNavigation

#Installation
CarbonKit is available on CocoaPods. Add to your Podfile:
```bash
pod 'CarbonKit'
```
and run 
```bash
pod install
```

# CarbonSwipeRefresh

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Examples/CarbonSwipeRefresh.gif)

# SAMPLE CODE
```objective-c
#import "CarbonKit.h"

@interface ViewController ()
{
	CarbonSwipeRefresh *refresh;
}
@end

@implementation ViewController
- (void)viewDidLoad {
	[super viewDidLoad];

	refresh = [[CarbonSwipeRefresh alloc] initWithScrollView:self.tableView];
	[refresh setMarginTop:64]; // set 64 if navigation is translucent - default 0
	[refresh setColors:@[[UIColor blueColor], [UIColor redColor], [UIColor orangeColor], [UIColor greenColor]]]; // default tintColor
	[self.view addSubview:refresh];

	[refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender {
	[refresh endRefreshing];
}
@end
```

# CarbonTabSwipeNavigation

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Examples/CarbonTabSwipeNavigation.gif)

# SAMPLE CODE

```objective-c
#import "CarbonKit.h"

@interface ViewController () <CarbonTabSwipeDelegate>
{
	CarbonTabSwipeNavigation *tabSwipe;
}
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSArray *names = @[@"CATEGORIES", @"HOME", @"TOP PAID", @"TOP FREE", @"TOP GROSSING", @"TOP NEW PAID", @"TOP NEW FREE", @"TRENDING"];
	UIColor *color = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
	tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
	[tabSwipe setNormalColor:[UIColor colorWithWhite:1 alpha:0.8]]; // default tintColor with alpha 0.8
	[tabSwipe setSelectedColor:[UIColor whiteColor]]; // default tintColor
	[tabSwipe setIndicatorHeight:2.f]; // default 3.f
}

// delegate
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
	return nil; // return viewController at index
}

@end
```

# CONTRIBUTORS
[Contributors](https://github.com/ermalkaleci/CarbonKit/graphs/contributors)

# LICENSE
[The MIT License (MIT)](https://github.com/ermalkaleci/CarbonKit/blob/master/LICENSE)
