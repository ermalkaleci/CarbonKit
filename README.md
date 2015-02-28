# CarbonTabSwipeNavigation
iOS navigation library like android SlidingTabStrip lib

![alt tag](https://github.com/ermalkaleci/CarbonTabSwipeNavigation/blob/master/Examples/sample.gif)

#import "../CarbonTabSwipeNavigation/CarbonTabSwipeNavigation/CarbonTabSwipeNavigation.h"

@interface ViewController () <CarbonTabSwipeDelegate> {
}

@property (nonatomic, retain) CarbonTabSwipeNavigation *tabSwipe;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSArray *names = @[@"CATEGORIES", @"HOME", @"TOP PAID", @"TOP FREE", @"TOP GROSSING", @"TOP NEW PAID", @"TOP NEW FREE", @"TRENDING"];
	UIColor *color = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
	self.tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
}

# pragma mark - Carbon Tab Swipe Delegate

- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
	return nil; // return viewController
}

@end

