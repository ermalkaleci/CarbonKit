//  The MIT License (MIT)
//
//  Copyright (c) 2015 Ermal Kaleci
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#define INDICATOR_WIDTH		3.f

#import "CarbonTabSwipeNavigation.h"
#import "CarbonTabSwipeView.h"

@interface CarbonTabSwipeNavigation() <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate> {
	
	BOOL isNotDragging;
	
	NSUInteger numberOfTabs;
	NSInteger selectedIndex;
	
	CGPoint previewsOffset;
	
	NSMutableArray *tabs;
	NSMutableDictionary *viewControllers;
	
	__weak UIViewController *rootViewController;
	UIPageViewController *pageController;
	CarbonTabSwipeView *tabSwipeView;
}

@end

@implementation CarbonTabSwipeNavigation

- (instancetype)createWithRootViewController:(UIViewController *)viewController
				    tabNames:(NSArray *)names
				   tintColor:(UIColor *)tintColor
				    delegate:(id)delegate {
	// init
	self.delegate = delegate;
	numberOfTabs = names.count;
	rootViewController = viewController;
	
	// remove navigation bar bottom border
//	[rootViewController.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//	[rootViewController.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
//	
//	[rootViewController.navigationController.navigationBar setTranslucent:NO];
	
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
	[self.view addSubview:pageController.view];
	[pageController didMoveToParentViewController:self];
	
	// add self as child to parent
	[rootViewController addChildViewController:self];
	[rootViewController.view addSubview:self.view];
	[self didMoveToParentViewController:rootViewController];
	
	// create container view
	tabSwipeView = [[CarbonTabSwipeView alloc] initWithSegmentTitles:names];
	[tabSwipeView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.view addSubview:tabSwipeView];
	
	// segment controller action
	[tabSwipeView.segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	// max tabWidth
	CGFloat maxTabWidth = 0;
	
	// get tabs width
	NSUInteger i = 0;
	CGFloat segmentedWidth = 0;
	for (UIView *tabView in [tabSwipeView.segmentController subviews]) {
		for (UIView *label in tabView.subviews) {
			if ([label isKindOfClass:[UILabel class]]) {
				CGFloat tabWidth = roundf([label sizeThatFits:CGSizeMake(FLT_MAX, 16)].width + 30); // 30 extra space
				[tabSwipeView.segmentController setWidth:tabWidth forSegmentAtIndex:i];
				
				segmentedWidth += tabWidth;
				
				// get max tab width
				maxTabWidth = tabWidth > maxTabWidth ? tabWidth : maxTabWidth;
			}
		}
		[tabs addObject:tabView];
		i++;
	}
	
	if (segmentedWidth < self.view.frame.size.width) {
		if (self.view.frame.size.width / (float)numberOfTabs < maxTabWidth) {
			
			for (int i = 0; i < numberOfTabs; i++) {
				[tabSwipeView.segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		} else {
			maxTabWidth = roundf(self.view.frame.size.width/(float)numberOfTabs);
			
			for (int i = 0; i < numberOfTabs; i++) {
				[tabSwipeView.segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		}
	}
	
	CGRect segmentRect = tabSwipeView.segmentController.frame;
	segmentRect.size.width = segmentedWidth;
	tabSwipeView.segmentController.frame = segmentRect;
	
	[tabSwipeView.tabScrollView setContentSize:CGSizeMake(segmentedWidth, 44)];

	
	[pageController.view setTranslatesAutoresizingMaskIntoConstraints: NO];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	[pageController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

	// create constraints
	UIView *viewControllertabSwipeView = self.view;
	UIView *pageControllerView = pageController.view;
	id<UILayoutSupport> topLayoutGuide = self.topLayoutGuide;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(topLayoutGuide, tabSwipeView, pageControllerView, viewControllertabSwipeView);
	NSDictionary *metricsDictionary = @{
										@"tabSwipeViewHeight" : @45
										};
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][tabSwipeView(==tabSwipeViewHeight)][pageControllerView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabSwipeView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageControllerView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];

	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewControllertabSwipeView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewControllertabSwipeView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];

	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[parentView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[parentView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	
	tabSwipeView.segmentController.selectedSegmentIndex = 0;
	
	UIView *tab = tabs[tabSwipeView.segmentController.selectedSegmentIndex];
	tabSwipeView.indicatorWidthConst.constant = tab.frame.size.width;
	tabSwipeView.indicatorLeftConst.constant = tab.frame.origin.x;
	
	tabSwipeView.tabScrollView.contentInset = UIEdgeInsetsZero;
	
	CGFloat offsetX = tabSwipeView.indicator.frame.origin.x;
	tabSwipeView.tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	
	// set tint color
	//[self setTintColor:tintColor];
	
	return self;
}

- (void)setTintColor:(UIColor *)tintColor {
	//tabScrollView.backgroundColor = tintColor;
//	[rootViewController.navigationController.navigationBar setBarTintColor:tintColor];
}

- (void)setNormalColor:(UIColor *)color {
//	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:color} forState:UIControlStateNormal];
}

- (void)setSelectedColor:(UIColor *)color {
//	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:color} forState:UIControlStateSelected];
//	indicator.backgroundColor = color;
}

- (void)segmentAction:(UISegmentedControl *)segment {
	UIView *tab = tabs[tabSwipeView.segmentController.selectedSegmentIndex];
	tabSwipeView.indicatorWidthConst.constant = tab.frame.size.width;
	tabSwipeView.indicatorLeftConst.constant = tab.frame.origin.x;
	
	NSInteger index = tabSwipeView.segmentController.selectedSegmentIndex;
	
	if (index == selectedIndex) return;
	
	if (index >= numberOfTabs)
		return;
	
	UIViewController *viewController = [viewControllers objectForKey:[NSNumber numberWithInteger:index]];
	
	if (!viewController) {
		viewController = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
		[viewControllers setObject:viewController forKey:[NSNumber numberWithInteger:index]];
	}
	
	UIPageViewControllerNavigationDirection animateDirection
	= index > selectedIndex
	? UIPageViewControllerNavigationDirectionForward
	: UIPageViewControllerNavigationDirectionReverse;
	
	__weak __typeof__(self) weakSelf = self;
	isNotDragging = YES;
	pageController.view.userInteractionEnabled = NO;
	[pageController setViewControllers:@[viewController]
				 direction:animateDirection
				  animated:NO
				completion:^(BOOL finished) {
					__strong __typeof__(self) strongSelf = weakSelf;
					strongSelf->isNotDragging = NO;
					strongSelf->pageController.view.userInteractionEnabled = YES;
					strongSelf->selectedIndex = index;
					[strongSelf->tabSwipeView.segmentController setSelectedSegmentIndex:strongSelf->selectedIndex];
					[strongSelf fixOffset];
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
	[self fixOffset];
	
	CGRect rect = tabSwipeView.indicator.frame;
	rect.size.width = ((UIView*)tabs[selectedIndex]).frame.size.width;
	tabSwipeView.indicator.frame = rect;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// fix indicator position and width
	tabSwipeView.indicatorLeftConst.constant = ((UIView*)tabs[selectedIndex]).frame.origin.x;
	tabSwipeView.indicatorWidthConst.constant = ((UIView*)tabs[selectedIndex]).frame.size.width;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	UIView *tab = tabs[tabSwipeView.segmentController.selectedSegmentIndex];
	tabSwipeView.indicatorWidthConst.constant = tab.frame.size.width;
	tabSwipeView.indicatorLeftConst.constant = tab.frame.origin.x;
	
	// keep the page controller's width in sync
	pageController.view.frame = CGRectMake(pageController.view.frame.origin.x, pageController.view.frame.origin.y, self.view.bounds.size.width, pageController.view.frame.size.height);

	[self resizeTabs];
	[self fixOffset];
	[self.view layoutIfNeeded];
	
}

- (void)fixOffset {
	CGRect selectedTabRect = ((UIView*)tabs[selectedIndex]).frame;
	CGFloat indicatorMaxOriginX = tabSwipeView.tabScrollView.frame.size.width / 2 - selectedTabRect.size.width / 2;
	
	CGFloat offsetX = selectedTabRect.origin.x-indicatorMaxOriginX;
	
	if (offsetX < 0) offsetX = 0;
	if (offsetX > tabSwipeView.segmentController.frame.size.width-tabSwipeView.tabScrollView.frame.size.width)
		offsetX = tabSwipeView.segmentController.frame.size.width-tabSwipeView.tabScrollView.frame.size.width;
	
	[UIView animateWithDuration:0.3 animations:^{
		tabSwipeView.tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = tabSwipeView.tabScrollView.contentOffset;
}

- (void)resizeTabs {
	// view size
	CGSize size = self.view.frame.size;
	
	// max tabWidth
	CGFloat maxTabWidth = 0;
	
	// get tabs width
	NSUInteger i = 0;
	CGFloat segmentedWidth = 0;
	for (UIView *tabView in tabs) {
		
		for (UIView *label in tabView.subviews) {
			if ([label isKindOfClass:[UILabel class]]) {
				CGFloat tabWidth = roundf([label sizeThatFits:CGSizeMake(FLT_MAX, 0)].width + 30); // 30 extra space
				[tabSwipeView.segmentController setWidth:tabWidth forSegmentAtIndex:i];
				
				segmentedWidth += tabWidth;
				
				// get max tab width
				maxTabWidth = tabWidth > maxTabWidth ? tabWidth : maxTabWidth;
			}
		}
		i++;
	}
	
	// segment width not fill the view width
	if (segmentedWidth < size.width) {
		
		// tabs width as max tab width or calcucate it
		if (size.width / (float)numberOfTabs < maxTabWidth) {
			
			for (int i = 0; i < numberOfTabs; i++) {
				[tabSwipeView.segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		} else {
			maxTabWidth = roundf(size.width/(float)numberOfTabs);
			
			for (int i = 0; i < numberOfTabs; i++) {
				[tabSwipeView.segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = size.width;
		}
	}
	
	CGRect segmentRect = tabSwipeView.segmentController.frame;
	segmentRect.size.width = segmentedWidth;
	tabSwipeView.segmentController.frame = segmentRect;
	
	[tabSwipeView.tabScrollView setContentSize:CGSizeMake(segmentedWidth, 44)];
}

# pragma mark - PageViewController DataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex;
	
	if (index++ < numberOfTabs - 1 && index <= numberOfTabs - 1) {
		
		UIViewController *nextViewController = [viewControllers objectForKey:[NSNumber numberWithInteger:index]];
		
		if (!nextViewController) {
			nextViewController = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
			[viewControllers setObject:nextViewController forKey:[NSNumber numberWithInteger:index]];
		}
		
		return nextViewController;
	}
	
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex;
	
	if (index-- > 0) {
		UIViewController *nextViewController = [viewControllers objectForKey:[NSNumber numberWithInteger:index]];
		
		if (!nextViewController) {
			nextViewController = [self.delegate tabSwipeNavigation:self viewControllerAtIndex:index];
			[viewControllers setObject:nextViewController forKey:[NSNumber numberWithInteger:index]];
		}
		
		return nextViewController;
	}
	
	return nil;
}

# pragma mark - PageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
	didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
	
	if (!completed)
		return;
	
	id currentView = [pageViewController.viewControllers objectAtIndex:0];
	
	NSNumber *key = (NSNumber*)[viewControllers allKeysForObject:currentView][0];
	selectedIndex= [key integerValue];
	
	[tabSwipeView.segmentController setSelectedSegmentIndex:selectedIndex];
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
			tabSwipeView.indicatorLeftConst.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			tabSwipeView.indicatorWidthConst.constant = newWidth;
			
			[UIView animateWithDuration:0.01 animations:^{
				[tabSwipeView.indicator layoutIfNeeded];
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
			tabSwipeView.indicatorLeftConst.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			tabSwipeView.indicatorWidthConst.constant = newWidth;
			
			[UIView animateWithDuration:0.01 animations:^{
				[tabSwipeView.indicator layoutIfNeeded];
			}];
			
		}
	}
	
	CGFloat indicatorMaxOriginX = scrollView.frame.size.width / 2 - tabSwipeView.indicator.frame.size.width / 2;
	
	CGFloat offsetX = tabSwipeView.indicator.frame.origin.x-indicatorMaxOriginX;
	
	if (offsetX < 0) offsetX = 0;
	if (offsetX > tabSwipeView.segmentController.frame.size.width-scrollViewWidth) offsetX = tabSwipeView.segmentController.frame.size.width-scrollViewWidth;
	
	[UIView animateWithDuration:isNotDragging ? 0.3 : 0.01 animations:^{
		tabSwipeView.tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = scrollView.contentOffset;
}

@end
