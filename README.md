# CarbonKit
![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/carbonkit_logo.png)

CarbonKit is an iOS OpenSource libraries collection.
Like the Carbon is the base of the life, I started CarbonKit to be base of great apps ;-)
Fork & Contribute CarbonKit to make it better.

CarbonKit includes:
- CarbonSwipeRefresh
- CarbonTabSwipeNavigation

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

@property (nonatomic, retain) CarbonTabSwipeNavigation *tabSwipe;

@end

@implementation ViewController

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

@end
```

# CONTRIBUTORS
 - Ermal Kaleci

# LICENSE
The MIT License (MIT)

Copyright (c) 2015 Ermal Kaleci

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
