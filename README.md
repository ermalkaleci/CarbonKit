![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Resources/CarbonKit.jpg)

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/CarbonKit.svg?style=flat)](https://cocoapods.org/pods/CarbonKit) [![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/ermalkaleci/CarbonKit/blob/master/LICENSE)

**IMPORTANT NOTE**: Please don't submit issues for questions regarding your code. Only actual bugs or feature requests will be answered, all others will be closed without comment. In case of reporting a bug, please include a screenshot and the code to reproduce it.

CarbonKit is an open source iOS library that includes powerful and beauty UI components.

CarbonKit includes:
- CarbonSwipeRefresh
- CarbonTabSwipeNavigation

# Carthage
Add following line into your Cartfile
```
github "ermalkaleci/CarbonKit"
```

Run `carthage update`

# CocoaPods
CarbonKit is available on CocoaPods. Add to your Podfile:
```
use_frameworks!
pod 'CarbonKit'
```
Run `pod install`

# CarbonTabSwipeNavigation

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Resources/CarbonTabSwipeNavigation.gif)

# SAMPLE CODE

```objective-c
#import "CarbonKit.h"

@interface ViewController () <CarbonTabSwipeNavigationDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSArray *items = @[[UIImage imageNamed:@"home"], [UIImage imageNamed:@"hourglass"],
	[UIImage imageNamed:@"premium_badge"], @"Categories", @"Top Free",
	@"Top New Free", @"Top Paid", @"Top New Paid"];

	CarbonTabSwipeNavigation *carbonTabSwipeNavigation =
	[[CarbonTabSwipeNavigation alloc] initWithItems:items delegate:self];
	[carbonTabSwipeNavigation insertIntoRootViewController:self];
	// or [carbonTabSwipeNavigation insertIntoRootViewController:self andTargetView:yourView];
}

// delegate
- (UIViewController *)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
			 viewControllerAtIndex:(NSUInteger)index {
	// return viewController at index
}

@end
```

Swift Sample
```swift
import CarbonKit

class ViewController: UIViewController, CarbonTabSwipeNavigationDelegate {

    // MARK: Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = ["Features", "Products", "About"]
        let carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
        carbonTabSwipeNavigation.insertIntoRootViewController(self)
		// or carbonTabSwipeNavigation.insertIntoRootViewController(self, andTargetView: yourView)
    }

    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        // return viewController at index
    }
}
```

# CarbonSwipeRefresh

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Resources/CarbonSwipeRefresh.gif)

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
	[refresh setColors:@[
		[UIColor blueColor],
	 	[UIColor redColor],
		[UIColor orangeColor],
		[UIColor greenColor]]
	]; // default tintColor

	// If your ViewController extends to UIViewController
	// else see below
	[self.view addSubview:refresh];

	[refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender {
	[refresh endRefreshing];
}
@end
```

If you are using UITableViewController you must add the refreshControl into self.view.superview after viewDidAppear
```objective-c
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!refreshControl.superview) {
		[self.view.superview addSubview:refreshControl];
	}
}
```


# LICENSE
[The MIT License (MIT)](https://github.com/ermalkaleci/CarbonKit/blob/master/LICENSE)
