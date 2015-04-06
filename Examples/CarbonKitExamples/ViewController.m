//
//  ViewController.m
//  Test 2
//
//  Created by Ermal Kaleci on 08/02/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "CategoriesTableViewController.h"
#import "../../CarbonKit.h"

@interface ViewController () <CarbonTabSwipeDelegate>
{
}

@property (nonatomic, retain) CarbonTabSwipeNavigation *tabSwipe;

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	self.title = @"Overview";
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	
	NSArray *names = @[@"CATEGORIES", @"HOME", @"TOP PAID", @"TOP FREE", @"TOP GROSSING", @"TOP NEW PAID", @"TOP NEW FREE", @"TRENDING"];
	UIColor *color = [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
	self.tabSwipe = [[CarbonTabSwipeNavigation alloc] createWithRootViewController:self tabNames:names tintColor:color delegate:self];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

# pragma mark - Carbon Tab Swipe Delegate

- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index {
	if (index % 2 == 0) {
		CategoriesTableViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:@"Categories"];
		return v;
	}
	
	
	UIViewController *v = [[UIViewController alloc] init];
	
	UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
	t.text = [NSString stringWithFormat:@"Hello World! %d", (int)index];
	[v.view addSubview:t];
	
	return v;
}

@end
