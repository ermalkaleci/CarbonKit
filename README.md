# CarbonTabSwipeNavigation
iOS navigation library like android SlidingTabStrip lib

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Examples/sample.gif)

```objective-c
- (void)viewDidLoad {
	[super viewDidLoad];

	NSArray *names = @[@"CATEGORIES", @"HOME", @"TOP PAID", @"TOP FREE", @"TOP GROSSING", @"TOP NEW PAID", @"TOP NEW FREE", @"TRENDING"];
	UIColor *color = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
	self.tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
}

// delegate
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
	return nil; // return viewController
}

```

