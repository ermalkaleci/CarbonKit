//
//  CarbonTabSwipeNavigation.m
//  CarbonTabSwipeNavigation
//
//  Created by Ermal Kaleci on 08/02/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import "CarbonTabSwipeNavigation.h"

@interface CarbonTabSwipeNavigation() <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate> {
	
	BOOL isNotDragging;
	
	NSUInteger numberOfTabs;
	NSInteger selectedIndex;
	
	CGPoint previewsOffset;
	
	NSMutableArray *tabs;
	NSMutableDictionary *viewControllers;
	
	UIViewController *rootViewController;
	UIPageViewController *pageController;
	UIScrollView *tabScrollView;
	UISegmentedControl *segmentController;
	UIImageView *indicator;
	
	NSLayoutConstraint *tabTopConstraint;
	NSLayoutConstraint *leftConstraint;
	NSLayoutConstraint *widthConstraint;
}

@end

@implementation CarbonTabSwipeNavigation

- (instancetype)createWithRootViewController:(UIViewController *)viewController tabNames:(NSArray *)names tintColor:(UIColor *)tintColor delegate:(id)delegate {
	
	// init
	self.delegate = delegate;
	numberOfTabs = names.count;
	rootViewController = viewController;
	
	// remove navigation bar bottom border
	[rootViewController.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
	[rootViewController.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
	
	// create page controller
	pageController = [UIPageViewController alloc];
	pageController = [pageController initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
					     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal 
							   options:nil];
	pageController.delegate = self;
	pageController.dataSource = self;
	
	// delegate scrollview
	for (UIView *v in pageController.view.subviews) {
		if ([v isKindOfClass:[UIScrollView class]]) {
			((UIScrollView *)v).delegate = self;
		}
	}
	
	// add page controller as child
	[self addChildViewController:pageController];
	
	// set page controller frame
	pageController.view.frame = viewController.view.frame;
	[self.view addSubview:pageController.view];
	
	// add self as child to parent
	[rootViewController addChildViewController:self];
	
	// set self.view frame
	self.view.frame = rootViewController.view.frame;
	[rootViewController.view addSubview:self.view];

	// create segment control
	segmentController = [[UISegmentedControl alloc] initWithItems:names];
	CGRect segRect = segmentController.frame;
	segRect.size.height = 44;
	segmentController.frame = segRect;

	// style segment controller
	[segmentController setTintColor:[UIColor clearColor]];

	UIColor *normalTextColor = [UIColor colorWithWhite:0.85 alpha:1];
	
	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:normalTextColor,
						    NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
					 forState:UIControlStateNormal];
	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:[self.view tintColor],
						    NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
					 forState:UIControlStateSelected];
	
	// segment controller action
	[segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	// get tabs width
	NSUInteger i = 0;
	CGFloat segmentedWidth = 0;
	for (UIView *tabView in [segmentController subviews]) {
		for (UIView *label in tabView.subviews) {
			if ([label isKindOfClass:[UILabel class]]) {
				CGFloat tabWidth = [label sizeThatFits:CGSizeMake(FLT_MAX, 16)].width + 30;
				[segmentController setWidth:tabWidth forSegmentAtIndex:i];
				segmentedWidth += tabWidth+1;
			}
		}
		
		[tabs addObject:tabView];
		
		i++;
	}
	
	// remove 2 point from segment width
	segmentedWidth -=2;
	
	// create scrollview
	tabScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
	[self.view addSubview:tabScrollView];
	
	// create indicator
	indicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, 100, 5)];
	indicator.backgroundColor = [self.view tintColor];
	[segmentController addSubview:indicator];

	[tabScrollView addSubview:segmentController];
	[tabScrollView setContentSize:CGSizeMake(segmentedWidth, 44)];
	[tabScrollView setShowsHorizontalScrollIndicator:NO];
	[tabScrollView setShowsVerticalScrollIndicator:NO];
	[tabScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	if (viewController.navigationController) {
		[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabScrollView
								      attribute:NSLayoutAttributeTop
								      relatedBy:NSLayoutRelationEqual
									 toItem:self.view
								      attribute:NSLayoutAttributeTop
								     multiplier:1.0 
								       constant:0]];
	} else {
		CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
		tabTopConstraint = [NSLayoutConstraint constraintWithItem:tabScrollView
								attribute:NSLayoutAttributeTop
								relatedBy:NSLayoutRelationEqual
								   toItem:self.view
								attribute:NSLayoutAttributeTop
							       multiplier:1.0 
								 constant:statusBarHeight];
		[self.view addConstraint:tabTopConstraint];
	}
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabScrollView
							      attribute:NSLayoutAttributeLeading
							      relatedBy:NSLayoutRelationEqual
								 toItem:self.view
							      attribute:NSLayoutAttributeLeading
							     multiplier:1.0 
							       constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabScrollView
							      attribute:NSLayoutAttributeTrailing
							      relatedBy:NSLayoutRelationEqual
								 toItem:self.view
							      attribute:NSLayoutAttributeTrailing
							     multiplier:1.0 
							       constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabScrollView
							      attribute:NSLayoutAttributeHeight
							      relatedBy:NSLayoutRelationEqual
								 toItem:self.view
							      attribute:NSLayoutAttributeHeight
							     multiplier:0
							       constant:44]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabScrollView
							      attribute:NSLayoutAttributeWidth
							      relatedBy:NSLayoutRelationEqual
								 toItem:self.view
							      attribute:NSLayoutAttributeWidth
							     multiplier:1.0
							       constant:0]];

	[pageController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageController.view
							      attribute:NSLayoutAttributeTop 
							      relatedBy:NSLayoutRelationEqual 
								 toItem:tabScrollView 
							      attribute:NSLayoutAttributeBottom 
							     multiplier:1.0 
							       constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageController.view
							      attribute:NSLayoutAttributeBottom 
							      relatedBy:NSLayoutRelationEqual 
								 toItem:self.view 
							      attribute:NSLayoutAttributeBottom 
							     multiplier:1.0 
							       constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageController.view
							      attribute:NSLayoutAttributeLeading 
							      relatedBy:NSLayoutRelationEqual 
								 toItem:self.view
							      attribute:NSLayoutAttributeLeading 
							     multiplier:1.0 
							       constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageController.view
							      attribute:NSLayoutAttributeTrailing 
							      relatedBy:NSLayoutRelationEqual 
								 toItem:self.view
							      attribute:NSLayoutAttributeTrailing 
							     multiplier:1.0 
							       constant:0]];
	
	[indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
	[segmentController addConstraint:[NSLayoutConstraint constraintWithItem:indicator 
								  attribute:NSLayoutAttributeBottom
								  relatedBy:NSLayoutRelationEqual
								     toItem:indicator.superview
								  attribute:NSLayoutAttributeBottom
								 multiplier:1.0
								   constant:1]];
	[segmentController addConstraint:[NSLayoutConstraint constraintWithItem:indicator 
								      attribute:NSLayoutAttributeHeight
								      relatedBy:NSLayoutRelationEqual
									 toItem:indicator.superview
								      attribute:NSLayoutAttributeHeight
								     multiplier:0 
								       constant:5.0]];
	leftConstraint = [NSLayoutConstraint constraintWithItem:indicator 
									  attribute:NSLayoutAttributeLeading
									  relatedBy:NSLayoutRelationEqual
									     toItem:indicator.superview
									  attribute:NSLayoutAttributeLeading
									 multiplier:1.0 
									   constant:0];
	widthConstraint = [NSLayoutConstraint constraintWithItem:indicator 
									   attribute:NSLayoutAttributeWidth
									   relatedBy:NSLayoutRelationEqual
									      toItem:indicator.superview
									   attribute:NSLayoutAttributeWidth
									  multiplier:0 
									    constant:0];
	[segmentController addConstraint:leftConstraint];
	[segmentController addConstraint:widthConstraint];
	
	segmentController.selectedSegmentIndex = 0;
	
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	widthConstraint.constant = tab.frame.size.width;
	leftConstraint.constant = tab.frame.origin.x;
	
	CGFloat indicatorMaxOriginX = tabScrollView.frame.size.width/2 - indicator.frame.size.width/2;
	tabScrollView.contentInset = UIEdgeInsetsMake(0, indicatorMaxOriginX, 0, indicatorMaxOriginX);
	
	CGFloat offsetX = indicator.frame.origin.x - indicatorMaxOriginX;
	tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	
	[rootViewController.navigationController.navigationBar setTranslucent:NO];
	
	// set tint color
	[self setTintColor:tintColor];
	
	return self;
}

- (void)setTintColor:(UIColor *)tintColor {
	tabScrollView.backgroundColor = tintColor;
	[rootViewController.navigationController.navigationBar setBarTintColor:tintColor];
}

- (void)segmentAction:(UISegmentedControl *)segment {
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	widthConstraint.constant = tab.frame.size.width;
	leftConstraint.constant = tab.frame.origin.x;
	
	NSInteger index = segmentController.selectedSegmentIndex;
	
	if (index == selectedIndex) return;
	
	if (index >= numberOfTabs)
		return;
	
	UIViewController *viewController;
 
	if (segment.selectedSegmentIndex <= [viewControllers count] - 1) {
		viewController = [viewControllers objectForKey:[NSNumber numberWithInteger:segment.selectedSegmentIndex]];
	}
	
	if (!viewController) {
		viewController = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
		[viewControllers setObject:viewController forKey:[NSNumber numberWithInteger:index]];
	}

	UIPageViewControllerNavigationDirection animateDirection
						= index > selectedIndex
						? UIPageViewControllerNavigationDirectionForward
						: UIPageViewControllerNavigationDirectionReverse;
	
	isNotDragging = YES;
	pageController.view.userInteractionEnabled = NO;
	[pageController setViewControllers:@[viewController]
				  direction:animateDirection
				   animated:YES
				completion:^(BOOL finished) {
					isNotDragging = NO;
					pageController.view.userInteractionEnabled = YES;
					selectedIndex = index;
					[segmentController setSelectedSegmentIndex:selectedIndex];	
				}];
	
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// init
	tabs = [[NSMutableArray alloc] init];
	viewControllers = [[NSMutableDictionary alloc] init];
	
	// first view controller
	id viewController = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:selectedIndex];
	[viewControllers setObject:viewController forKey:[NSNumber numberWithInteger:selectedIndex]];
	
	[pageController setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self fixEdgeInset];
	
	CGRect rect = indicator.frame;
	rect.size.width = ((UIView*)tabs[selectedIndex]).frame.size.width;
	indicator.frame = rect;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	[tabTopConstraint setConstant:statusBarHeight];
	
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	widthConstraint.constant = tab.frame.size.width;
	leftConstraint.constant = tab.frame.origin.x;
	
	[self fixEdgeInset];
}

- (void)fixEdgeInset {
	CGFloat indicatorMaxOriginX = tabScrollView.frame.size.width/2 - indicator.frame.size.width/2;
	tabScrollView.contentInset = UIEdgeInsetsMake(0, indicatorMaxOriginX, 0, indicatorMaxOriginX);
}

# pragma mark - PageViewController DataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSNumber *key = (NSNumber*)[viewControllers allKeysForObject:viewController][0];
	NSInteger index = [key integerValue];
	
	if (index++ < numberOfTabs - 1 && index <= numberOfTabs - 1) {

		UIViewController *nextView;
		if (index <= [viewControllers count] - 1) {
			nextView = [viewControllers objectForKey:[NSNumber numberWithInteger:index]];
		}
		
		if (!nextView) {
			nextView = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
			[viewControllers setObject:nextView forKey:[NSNumber numberWithInteger:index]];
		}
		
		return nextView;
	}
	
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSNumber *key = (NSNumber*)[viewControllers allKeysForObject:viewController][0];
	NSInteger index = [key integerValue];
	
	if (index-- > 0) {
		UIViewController *nextView;
		
		if (index <= [viewControllers count] - 1) {
			nextView = [viewControllers objectForKey:[NSNumber numberWithInteger:index]];
		}
		
		if (!nextView) {
			nextView = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
			[viewControllers setObject:nextView forKey:[NSNumber numberWithInteger:index]];
		}
		
		return nextView;
	}
	
	return nil;
}

# pragma mark - PageViewController Delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
	
	if (!completed)
		return;
	
	id currentView = [pageViewController.viewControllers objectAtIndex:0];
	
	NSNumber *key = (NSNumber*)[viewControllers allKeysForObject:currentView][0];
	selectedIndex= [key integerValue];
	
	[segmentController setSelectedSegmentIndex:selectedIndex];
}

# pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGPoint offset = scrollView.contentOffset;
	
	CGFloat scrollViewWidth = scrollView.frame.size.width;
	if (selectedIndex < 0 || selectedIndex > numberOfTabs-1)
		return;
	
	if (!isNotDragging) {
		
		if (offset.x < scrollViewWidth) {
			// we are moving back
			
			if (selectedIndex - 1 < 0)
				return;
			
			float newX = offset.x - scrollViewWidth;
			
			UIView *selectedTab = (UIView*)tabs[selectedIndex];
			UIView *backTab = (UIView*)tabs[selectedIndex - 1];
			
			float selectedOriginX = selectedTab.frame.origin.x;
			float backTabWidth = backTab.frame.size.width;
			
			float widthDiff = selectedTab.frame.size.width - backTabWidth;
			
			float newOriginX = selectedOriginX + newX / scrollViewWidth * backTabWidth;
			leftConstraint.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			widthConstraint.constant = newWidth;
			
			[UIView animateWithDuration:0.01 animations:^{
				[indicator layoutIfNeeded];
			}];
			
		} else {
			// we are moving forward
			
			if (selectedIndex + 1 >= numberOfTabs)
				return;
			
			float newX = offset.x - scrollViewWidth;
			
			UIView *selectedTab = (UIView*)tabs[selectedIndex];
			UIView *nexTab = (UIView*)tabs[selectedIndex + 1];
			
			float selectedOriginX = selectedTab.frame.origin.x;
			float nextTabWidth = nexTab.frame.size.width;
			
			float widthDiff = nextTabWidth - selectedTab.frame.size.width;
			
			float newOriginX = selectedOriginX + newX / scrollViewWidth * selectedTab.frame.size.width;
			leftConstraint.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			widthConstraint.constant = newWidth;
			
			[UIView animateWithDuration:0.01 animations:^{
				[indicator layoutIfNeeded];
			}];
			
		}
	}
	
	CGFloat indicatorMaxOriginX = scrollView.frame.size.width / 2 - indicator.frame.size.width / 2;
	CGFloat offsetX = indicator.frame.origin.x-indicatorMaxOriginX;

	[UIView animateWithDuration:isNotDragging ? 0.3 : 0.01 animations:^{
		tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];

	previewsOffset = scrollView.contentOffset;
}

@end
