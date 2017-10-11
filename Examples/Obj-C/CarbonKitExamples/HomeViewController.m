#import <CarbonKit/CarbonKit.h>
#import "HomeViewController.h"
#import "ViewControllerOne.h"
#import "ViewControllerThree.h"
#import "ViewControllerTwo.h"


@interface HomeViewController () <CarbonTabSwipeNavigationDelegate> {
	NSArray *items;
	CarbonTabSwipeNavigation *carbonTabSwipeNavigation;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"CarbonKit";

	items = @[
		  [UIImage imageNamed:@"home"],
		  [UIImage imageNamed:@"hourglass"],
		  [UIImage imageNamed:@"premium_badge"],
		  @"Categories",
		  @"Top Free",
		  @"Top New Free",
		  @"Top Paid",
		  @"Top New Paid"
		  ];

	carbonTabSwipeNavigation = [[CarbonTabSwipeNavigation alloc] initWithItems:items delegate:self];
	[carbonTabSwipeNavigation insertIntoRootViewController:self];

	[self style];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)style {

	UIColor *color = [UIColor colorWithRed:24.0 / 255 green:75.0 / 255 blue:152.0 / 255 alpha:1];
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.barTintColor = color;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;

	carbonTabSwipeNavigation.toolbar.translucent = NO;
	[carbonTabSwipeNavigation setIndicatorColor:color];
	[carbonTabSwipeNavigation setTabExtraWidth:30];
	[carbonTabSwipeNavigation.carbonSegmentedControl setWidth:80 forSegmentAtIndex:0];
	[carbonTabSwipeNavigation.carbonSegmentedControl setWidth:80 forSegmentAtIndex:1];
	[carbonTabSwipeNavigation.carbonSegmentedControl setWidth:80 forSegmentAtIndex:2];

	// Custimize segmented control
	[carbonTabSwipeNavigation setNormalColor:[color colorWithAlphaComponent:0.6]
					    font:[UIFont boldSystemFontOfSize:14]];
	[carbonTabSwipeNavigation setSelectedColor:color font:[UIFont boldSystemFontOfSize:14]];
}

#pragma mark - CarbonTabSwipeNavigation Delegate
// required
- (nonnull UIViewController *)carbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbontTabSwipeNavigation
				 viewControllerAtIndex:(NSUInteger)index {
	switch (index) {
		case 0:
			return [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerOne"];

		case 1:
			return [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerTwo"];

		default:
			return [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerThree"];
	}
}

// optional
- (void)carbonTabSwipeNavigation:(CarbonTabSwipeNavigation *)carbonTabSwipeNavigation willMoveAtIndex:(NSUInteger)index {
	switch (index) {
		case 0:
			self.title = @"Home";
			break;
		case 1:
			self.title = @"Hourglass";
			break;
		case 2:
			self.title = @"Premium Badge";
			break;
		default:
			self.title = items[index];
			break;
	}
}

- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
		  didMoveAtIndex:(NSUInteger)index {
	NSLog(@"Did move at index: %ld", index);
}

- (UIBarPosition)barPositionForCarbonTabSwipeNavigation:
(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation {
	return UIBarPositionTop; // default UIBarPositionTop
}

@end
