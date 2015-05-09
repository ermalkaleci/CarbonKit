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

#import "CarbonTabSwipeNavigation.h"

@interface CarbonTabSwipeNavigation() <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate> {
	
	BOOL isNotDragging;
	
	NSUInteger numberOfTabs;
	NSInteger selectedIndex;
	
	CGPoint previewsOffset;
	
	NSMutableArray *tabs;
	NSMutableDictionary *viewControllers;
	
	__weak UIViewController *rootViewController;
	UIPageViewController *pageController;
	UIScrollView *tabScrollView;
	UISegmentedControl *segmentController;
	UIImageView *indicator;
	
	NSLayoutConstraint *indicatorLeftConst;
	NSLayoutConstraint *indicatorWidthConst;
	NSLayoutConstraint *indicatorHeightConst;
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
	
	// create segment control
	segmentController = [[UISegmentedControl alloc] initWithItems:names];
	CGRect segRect = segmentController.frame;
	segRect.size.height = 44;
	segmentController.frame = segRect;
	
	UIColor *normalTextColor = [self.view.tintColor colorWithAlphaComponent:0.8];
	
	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:normalTextColor,
						    NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
					 forState:UIControlStateNormal];
	[segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:self.view.tintColor,
						    NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}
					 forState:UIControlStateSelected];
	
	// segment controller action
	[segmentController addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	// max tabWidth
	CGFloat maxTabWidth = 0;
	
	// get tabs width
	NSUInteger i = 0;
	CGFloat segmentedWidth = 0;
	for (UIView *tabView in [segmentController subviews]) {
		for (UIView *label in tabView.subviews) {
			if ([label isKindOfClass:[UILabel class]]) {
				CGFloat tabWidth = roundf([label sizeThatFits:CGSizeMake(FLT_MAX, 16)].width + 30); // 30 extra space
				[segmentController setWidth:tabWidth forSegmentAtIndex:i];
				
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
				[segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		} else {
			maxTabWidth = roundf(self.view.frame.size.width/(float)numberOfTabs);
			
			for (int i = 0; i < numberOfTabs; i++) {
				[segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		}
	}
	
	CGRect segmentRect = segmentController.frame;
	segmentRect.size.width = segmentedWidth;
	segmentController.frame = segmentRect;
	
	// create scrollview
	tabScrollView = [[UIScrollView alloc] init];
	[self.view addSubview:tabScrollView];
	
	// create indicator
	indicator = [[UIImageView alloc] init];
	indicator.backgroundColor = self.view.tintColor;
	[segmentController addSubview:indicator];
	
	[segmentController setTintColor:[UIColor clearColor]];
	[segmentController setDividerImage:[UIImage new] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	
	[tabScrollView addSubview:segmentController];
	[tabScrollView setContentSize:CGSizeMake(segmentedWidth, 44)];
	[tabScrollView setShowsHorizontalScrollIndicator:NO];
	[tabScrollView setShowsVerticalScrollIndicator:NO];
	[tabScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	[pageController.view setTranslatesAutoresizingMaskIntoConstraints: NO];
	[self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	// create constraints
	UIView *parentView = self.view;
	UIView *pageControllerView = pageController.view;
	id<UILayoutSupport> rootTopLayoutGuide = rootViewController.topLayoutGuide;
    id<UILayoutSupport> rootBottomLayoutGuide = rootViewController.bottomLayoutGuide;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(rootTopLayoutGuide, rootBottomLayoutGuide, parentView, tabScrollView, pageControllerView);
	NSDictionary *metricsDictionary = @{
										@"tabScrollViewHeight" : @44
										};
	
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tabScrollView(==tabScrollViewHeight)][pageControllerView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabScrollView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageControllerView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];

	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rootTopLayoutGuide][parentView][rootBottomLayoutGuide]" options:0 metrics:metricsDictionary views:viewsDictionary]];
	[rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[parentView]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
	
	[indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
	[segmentController addConstraint:[NSLayoutConstraint constraintWithItem:indicator
								      attribute:NSLayoutAttributeBottom
								      relatedBy:NSLayoutRelationEqual
									 toItem:indicator.superview
								      attribute:NSLayoutAttributeBottom
								     multiplier:1.0
								       constant:1]];
	
	indicatorHeightConst = [NSLayoutConstraint constraintWithItem:indicator
														attribute:NSLayoutAttributeHeight
														relatedBy:NSLayoutRelationEqual
														   toItem:indicator.superview
														attribute:NSLayoutAttributeHeight
													   multiplier:0
														 constant:3.f];
	
	indicatorLeftConst = [NSLayoutConstraint constraintWithItem:indicator
													  attribute:NSLayoutAttributeLeading
													  relatedBy:NSLayoutRelationEqual
														 toItem:indicator.superview
													  attribute:NSLayoutAttributeLeading
													 multiplier:1
													   constant:0];
	
	indicatorWidthConst = [NSLayoutConstraint constraintWithItem:indicator
													   attribute:NSLayoutAttributeWidth
													   relatedBy:NSLayoutRelationEqual
														  toItem:indicator.superview
													   attribute:NSLayoutAttributeWidth
													  multiplier:0
														constant:0];
	
	[segmentController addConstraint:indicatorHeightConst];
	[segmentController addConstraint:indicatorLeftConst];
	[segmentController addConstraint:indicatorWidthConst];
	
	segmentController.selectedSegmentIndex = 0;
	
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	indicatorWidthConst.constant = tab.frame.size.width;
	indicatorLeftConst.constant = tab.frame.origin.x;
	
	tabScrollView.contentInset = UIEdgeInsetsZero;
	
	CGFloat offsetX = indicator.frame.origin.x;
	tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	
	// set tint color
	[self setTintColor:tintColor];
	
	return self;
}

- (void)setTranslucent:(BOOL)translucent {
	if (translucent) {
		[rootViewController.navigationController.navigationBar setShadowImage:[[UINavigationBar appearance] shadowImage]];
		[rootViewController.navigationController.navigationBar setBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
		[rootViewController.navigationController.navigationBar setBarTintColor:[[UINavigationBar appearance] barTintColor]];
		[rootViewController.navigationController.navigationBar setTranslucent:YES];
	}
	else {
		[rootViewController.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
		[rootViewController.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
		[rootViewController.navigationController.navigationBar setBarTintColor:tabScrollView.backgroundColor];
		[rootViewController.navigationController.navigationBar setTranslucent:NO];
	}
}

- (void)setIndicatorHeight:(CGFloat)height {
	indicatorHeightConst.constant = height;
}

- (void)setTintColor:(UIColor *)tintColor {
	tabScrollView.backgroundColor = tintColor;
}

- (void)setNormalColor:(UIColor *)color {
	[self setNormalColor:color font:[UIFont boldSystemFontOfSize:14]];
}

- (void)setNormalColor:(UIColor *)color font:(UIFont *)font {
	[segmentController setTitleTextAttributes:@{
												NSForegroundColorAttributeName:color,
												NSFontAttributeName:font
												}
									 forState:UIControlStateNormal];
}

- (void)setSelectedColor:(UIColor *)color {
	[self setSelectedColor:color font:[UIFont boldSystemFontOfSize:14]];
}

- (void)setSelectedColor:(UIColor *)color font:(UIFont *)font {
	indicator.backgroundColor = color;
	[segmentController setTitleTextAttributes:@{
												NSForegroundColorAttributeName:color,
												NSFontAttributeName:font
												}
									 forState:UIControlStateSelected];
}

// add shadow
- (void)addShadow {
	float shadowHeight = 1.f/[[UIScreen mainScreen] scale];
	UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, 44 - shadowHeight, self.view.frame.size.width, shadowHeight)];
	[shadow setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
	[shadow setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1]];
	[shadow.layer setShadowOpacity:.1f];
	[shadow.layer setShadowRadius:.3f];
	[shadow.layer setShadowOffset:CGSizeMake(0, .2)];
	[self.view addSubview:shadow];
}

- (void)segmentAction:(UISegmentedControl *)segment {
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	indicatorWidthConst.constant = tab.frame.size.width;
	indicatorLeftConst.constant = tab.frame.origin.x;
	
	NSInteger index = segmentController.selectedSegmentIndex;
	
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
					[strongSelf->segmentController setSelectedSegmentIndex:strongSelf->selectedIndex];
					[strongSelf fixOffset];
					
					// call delegate
					if ([strongSelf->_delegate respondsToSelector:@selector(tabSwipeNavigation:didMoveAtIndex:)]) {
						[strongSelf->_delegate tabSwipeNavigation:strongSelf didMoveAtIndex:index];
					}
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
	
	__weak __typeof__(self) weakSelf = self;
	[pageController setViewControllers:@[viewController]
							 direction:UIPageViewControllerNavigationDirectionForward
							  animated:NO
							completion:^(BOOL finished) {
								__strong __typeof__(self) strongSelf = weakSelf;
								// call delegate
								if ([strongSelf->_delegate respondsToSelector:@selector(tabSwipeNavigation:didMoveAtIndex:)]) {
									[strongSelf->_delegate tabSwipeNavigation:strongSelf didMoveAtIndex:strongSelf->selectedIndex];
								}
							}];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self fixOffset];
	
	CGRect rect = indicator.frame;
	rect.size.width = ((UIView*)tabs[selectedIndex]).frame.size.width;
	indicator.frame = rect;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// fix indicator position and width
	indicatorLeftConst.constant = ((UIView*)tabs[selectedIndex]).frame.origin.x;
	indicatorWidthConst.constant = ((UIView*)tabs[selectedIndex]).frame.size.width;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	UIView *tab = tabs[segmentController.selectedSegmentIndex];
	indicatorWidthConst.constant = tab.frame.size.width;
	indicatorLeftConst.constant = tab.frame.origin.x;
	
	// keep the page controller's width in sync
	pageController.view.frame = CGRectMake(pageController.view.frame.origin.x, pageController.view.frame.origin.y, self.view.bounds.size.width, pageController.view.frame.size.height);

	[self resizeTabs];
	[self fixOffset];
	[self.view layoutIfNeeded];
	
}

- (void)fixOffset {
	CGRect selectedTabRect = ((UIView*)tabs[selectedIndex]).frame;
	CGFloat indicatorMaxOriginX = tabScrollView.frame.size.width / 2 - selectedTabRect.size.width / 2;
	
	CGFloat offsetX = selectedTabRect.origin.x-indicatorMaxOriginX;
	
	if (offsetX < 0) offsetX = 0;
	if (offsetX > segmentController.frame.size.width-tabScrollView.frame.size.width)
		offsetX = segmentController.frame.size.width-tabScrollView.frame.size.width;
	
	[UIView animateWithDuration:0.3 animations:^{
		tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = tabScrollView.contentOffset;
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
				[segmentController setWidth:tabWidth forSegmentAtIndex:i];
				
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
				[segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = maxTabWidth * numberOfTabs;
		} else {
			maxTabWidth = roundf(size.width/(float)numberOfTabs);
			
			for (int i = 0; i < numberOfTabs; i++) {
				[segmentController setWidth:maxTabWidth forSegmentAtIndex:i];
			}
			
			segmentedWidth = size.width;
		}
	}
	
	CGRect segmentRect = segmentController.frame;
	segmentRect.size.width = segmentedWidth;
	segmentController.frame = segmentRect;
	
	[tabScrollView setContentSize:CGSizeMake(segmentedWidth, 44)];
}

#pragma mark - Public API
- (NSUInteger)currentTabIndex
{
	return selectedIndex;
}

- (void)setCurrentTabIndex:(NSUInteger)currentTabIndex
{
	if (selectedIndex != currentTabIndex && currentTabIndex < numberOfTabs) {
		segmentController.selectedSegmentIndex = currentTabIndex;
		
		[self segmentAction:segmentController];
		
		[self.view layoutIfNeeded];
	}
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
	
	[segmentController setSelectedSegmentIndex:selectedIndex];
	
	// call delegate
	if ([self.delegate respondsToSelector:@selector(tabSwipeNavigation:didMoveAtIndex:)]) {
		[self.delegate tabSwipeNavigation:self didMoveAtIndex:selectedIndex];
	}
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
			indicatorLeftConst.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			indicatorWidthConst.constant = newWidth;
			
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
			indicatorLeftConst.constant = newOriginX;
			
			float newWidth = selectedTab.frame.size.width + newX / scrollViewWidth * widthDiff;
			indicatorWidthConst.constant = newWidth;
			
			[UIView animateWithDuration:0.01 animations:^{
				[indicator layoutIfNeeded];
			}];
			
		}
	}
	
	CGFloat indicatorMaxOriginX = scrollView.frame.size.width / 2 - indicator.frame.size.width / 2;
	
	CGFloat offsetX = indicator.frame.origin.x-indicatorMaxOriginX;
	
	if (offsetX < 0) offsetX = 0;
	if (offsetX > segmentController.frame.size.width-scrollViewWidth) offsetX = segmentController.frame.size.width-scrollViewWidth;
	
	[UIView animateWithDuration:isNotDragging ? 0.3 : 0.01 animations:^{
		tabScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = scrollView.contentOffset;
}

@end
