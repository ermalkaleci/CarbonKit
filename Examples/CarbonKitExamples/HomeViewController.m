#import "HomeViewController.h"

#import "ViewControllerOne.h"
#import "ViewControllerTwo.h"
#import "ViewControllerThree.h"

#import "CarbonKit.h"

@interface HomeViewController () <CarbonTabSwipeDelegate>
{
	CarbonTabSwipeNavigation *tabSwipe;
}

@end

@implementation HomeViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	self.title = @"CarbonKit";
	self.navigationController.navigationBar.titleTextAttributes = @{
									NSForegroundColorAttributeName: [UIColor whiteColor],
									NSFontAttributeName: [UIFont boldSystemFontOfSize:20]
									};
	
	NSArray *names = @[@"ONE", @"TWO", @"THREE"];
	UIColor *color = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
	tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
	[tabSwipe setNormalColor:[UIColor colorWithWhite:1 alpha:0.8]]; // default
	[tabSwipe setSelectedColor:[UIColor whiteColor]]; // default
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

# pragma mark - Carbon Tab Swipe Delegate
// required
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
	
	if (index == 0) {
		ViewControllerOne *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerOne"];
		return viewController;
	} else if (index == 1) {
		ViewControllerTwo *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerTwo"];
		return viewController;
	} else {
		ViewControllerThree *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerThree"];
		return viewController;
	}
}

// optional
- (void)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe didMoveAtIndex:(NSInteger)index {
	NSLog(@"Current tab: %d", (int)index);
}

@end
