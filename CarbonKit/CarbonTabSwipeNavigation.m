//  The MIT License (MIT)
//
//  Copyright (c) 2015 - present Ermal Kaleci
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

@interface CarbonTabSwipeNavigation() <UIPageViewControllerDelegate,
UIPageViewControllerDataSource, UIScrollViewDelegate, UIToolbarDelegate>
{
	BOOL isLocked;
	NSInteger selectedIndex;
	CGPoint previewsOffset;
}

@end

@implementation CarbonTabSwipeNavigation

- (void)insertIntoRootViewController:(UIViewController *)rootViewController {
	
	[self willMoveToParentViewController:rootViewController];
	[rootViewController addChildViewController:self];
	[rootViewController.view addSubview:self.view];
	[self didMoveToParentViewController:rootViewController];
	
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	id views = @{@"carbonTabSwipe": self.view,
				 @"topLayoutGuide": rootViewController.topLayoutGuide,
				 @"bottomLayoutGuide": rootViewController.bottomLayoutGuide};
	
	[rootViewController.view addConstraints:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"V:[topLayoutGuide][carbonTabSwipe][bottomLayoutGuide]"
	  options:0
	  metrics:nil
	  views:views]];
	[rootViewController.view addConstraints:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"H:|[carbonTabSwipe]|"
	  options:0
	  metrics:nil
	  views:views]];
}

- (void)insertIntoRootViewController:(UIViewController *)rootViewController
					   andTargetView:(UIView *)targetView {
	
	[self willMoveToParentViewController:rootViewController];
	[rootViewController addChildViewController:self];
	[targetView addSubview:self.view];
	[self didMoveToParentViewController:rootViewController];
	
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	id views = @{@"carbonTabSwipe": self.view};
	
	[targetView addConstraints:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"V:|[carbonTabSwipe]|"
	  options:0
	  metrics:nil
	  views:views]];
	[targetView addConstraints:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"H:|[carbonTabSwipe]|"
	  options:0
	  metrics:nil
	  views:views]];
}

- (instancetype)initWithItems:(NSArray *)items delegate:(id)target {
	selectedIndex = 0;
	self.delegate = target;
	self.viewControllers = [NSMutableDictionary new];
	
	[self createSegmentedToolbar];
	[self createTabSwipeScrollViewWithItems:items];
	[self addToolbarIntoSuperview];
	[self createPageViewController];
	
	[self loadFirstViewController];
	
	return self;
}

- (instancetype)initWithItems:(NSArray *)items
					  toolBar:(UIToolbar *)toolBar
					 delegate:(id)target {
	selectedIndex = 0;
	self.delegate = target;
	self.viewControllers = [NSMutableDictionary new];
	
	[self setToolbar:toolBar];
	[self createTabSwipeScrollViewWithItems:items];
	[self createPageViewController];
	
	[self loadFirstViewController];
	
	return self;
}

#pragma mark - Override

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self syncIndicator];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration {
	isLocked = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.pageViewController.view layoutSubviews];
	isLocked = NO;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	[self.pageViewController.view layoutSubviews];
}

#pragma mark - Actions

- (void)segmentedTapped:(CarbonTabSwipeSegmentedControl *)segment {
	
	NSUInteger index = segment.selectedSegmentIndex;
	
	UIViewController *viewController = _viewControllers[@(index)];
	if (!viewController) {
		NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
		viewController = [_delegate carbonTabSwipeNavigation:self viewControllerAtIndex:index];
		_viewControllers[@(index)] = viewController;
	}
	
	UIPageViewControllerNavigationDirection animateDirection
	= index > selectedIndex
	? UIPageViewControllerNavigationDirectionForward
	: UIPageViewControllerNavigationDirectionReverse;
	
	isLocked = YES;
	segment.userInteractionEnabled = NO;
	self.pageViewController.view.userInteractionEnabled = NO;
	
	id replaceCompletionBlock = ^(BOOL finished) {
		isLocked = NO;
		selectedIndex = index;
		self.carbonSegmentedControl.userInteractionEnabled = YES;
		self.pageViewController.view.userInteractionEnabled = YES;
		
		[self callDelegateForCurrentIndex];
	};
	
	id animateCompletionBlock = ^(BOOL finished) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.pageViewController setViewControllers:@[viewController]
											  direction:animateDirection
											   animated:NO
											 completion:replaceCompletionBlock];
		});
	};
	
	[self callDelegateForTargetIndex];
	
	[self.pageViewController setViewControllers:@[viewController]
									  direction:animateDirection
									   animated:YES
									 completion:animateCompletionBlock];
}

- (void)syncIndicator {
	NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
	CGFloat selectedSegmentMinX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:index];
	CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:index];
	
	[self.carbonSegmentedControl setIndicatorMinX:selectedSegmentMinX];
	[self.carbonSegmentedControl setIndicatorWidth:selectedSegmentWidth];
	[self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
	
	CGFloat segmentedWidth = CGRectGetWidth(self.carbonSegmentedControl.frame);
	CGFloat scrollViewWidth = CGRectGetWidth(_carbonTabSwipeScrollView.frame);
	
	CGFloat indicatorMaxOriginX = scrollViewWidth / 2 - selectedSegmentWidth / 2;
	CGFloat offsetX = selectedSegmentMinX - indicatorMaxOriginX;
	
	if (segmentedWidth <= scrollViewWidth) {
		offsetX = 0;
	} else {
		if (offsetX < 0) {
			offsetX = 0;
		}
		
		if (offsetX > segmentedWidth - scrollViewWidth) {
			offsetX = segmentedWidth - scrollViewWidth;
		}
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		_carbonTabSwipeScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = _carbonTabSwipeScrollView.contentOffset;
}

#pragma mark - PageViewController data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex;
	
	if (index++ < self.carbonSegmentedControl.numberOfSegments - 1
		&& index <= self.carbonSegmentedControl.numberOfSegments - 1) {
		
		UIViewController *nextViewController = _viewControllers[@(index)];
		
		if (!nextViewController) {
			NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
			nextViewController = [_delegate carbonTabSwipeNavigation:self
											   viewControllerAtIndex:index];
			_viewControllers[@(index)] = nextViewController;
		}
		
		return nextViewController;
	}
	
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex;
	
	if (index-- > 0) {
		UIViewController *nextViewController = _viewControllers[@(index)];
		
		if (!nextViewController) {
			NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
			nextViewController = [_delegate carbonTabSwipeNavigation:self
											   viewControllerAtIndex:index];
			_viewControllers[@(index)] = nextViewController;
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
	
	if (!completed) {
		return;
	}
	
	id currentView = [pageViewController.viewControllers objectAtIndex:0];
	
	NSNumber *key = (NSNumber*)[_viewControllers allKeysForObject:currentView][0];
	selectedIndex = [key integerValue];
	
	[self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex];
	[self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
	
	[self callDelegateForCurrentIndex];
}

# pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGPoint offset = scrollView.contentOffset;
	CGFloat segmentedWidth = [self.carbonSegmentedControl getWidth];
	CGFloat scrollViewWidth = CGRectGetWidth(scrollView.frame);
	
	if (selectedIndex < 0 || selectedIndex > self.carbonSegmentedControl.numberOfSegments - 1) {
		return;
	}
	
	if (!isLocked) {
		
		if (offset.x < scrollViewWidth) {
			// we are moving back
			
			if (selectedIndex - 1 < 0) {
				return;
			}
			
			CGFloat newX = offset.x - scrollViewWidth;
			
			CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
			CGFloat selectedOriginX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
			CGFloat backTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex-1];
			
			CGFloat minX = selectedOriginX + newX / scrollViewWidth * backTabWidth;
			[self.carbonSegmentedControl setIndicatorMinX:minX];
			
			CGFloat widthDiff = selectedSegmentWidth - backTabWidth;
			
			CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
			[self.carbonSegmentedControl setIndicatorWidth:newWidth];
			[self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
			
			if (ABS(newX) > scrollViewWidth / 2) {
				if (self.carbonSegmentedControl.selectedSegmentIndex != selectedIndex - 1) {
					[self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex - 1];
					[self callDelegateForTargetIndex];
				}
			} else {
				if (self.carbonSegmentedControl.selectedSegmentIndex != selectedIndex) {
					[self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex];
					[self callDelegateForTargetIndex];
				}
			}
			
		} else {
			// we are moving forward
			
			if (selectedIndex + 1 >= self.carbonSegmentedControl.numberOfSegments) {
				return;
			}
			
			CGFloat newX = offset.x - scrollViewWidth;

			CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
			CGFloat selectedOriginX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
			CGFloat nextTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex+1];
			
			CGFloat minX = selectedOriginX + newX / scrollViewWidth * selectedSegmentWidth;
			[self.carbonSegmentedControl setIndicatorMinX:minX];
			
			CGFloat widthDiff = nextTabWidth - selectedSegmentWidth;
			
			CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
			[self.carbonSegmentedControl setIndicatorWidth:newWidth];
			[self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
			
			if (newX > scrollViewWidth / 2) {
				if (self.carbonSegmentedControl.selectedSegmentIndex != selectedIndex + 1) {
					[self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex + 1];
					[self callDelegateForTargetIndex];
				}
			} else {
				if (self.carbonSegmentedControl.selectedSegmentIndex != selectedIndex) {
					[self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex];
					[self callDelegateForTargetIndex];
				}
			}
		}
	}
	
	CGFloat indicatorMaxOriginX = scrollViewWidth / 2 - self.carbonSegmentedControl.indicatorWidth / 2;
	CGFloat offsetX = self.carbonSegmentedControl.indicatorMinX - indicatorMaxOriginX;
	
	if (segmentedWidth <= scrollViewWidth) {
		offsetX = 0;
	} else {
		if (offsetX < 0) {
			offsetX = 0;
		}
		
		if (offsetX > segmentedWidth - scrollViewWidth) {
			offsetX = segmentedWidth - scrollViewWidth;
		}
	}
	
	[UIView animateWithDuration:isLocked ? 0.3 : 0 animations:^{
		_carbonTabSwipeScrollView.contentOffset = CGPointMake(offsetX, 0);
	}];
	
	previewsOffset = scrollView.contentOffset;
}

#pragma mark - Toolbar position

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
	if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
		return [_delegate barPositionForCarbonTabSwipeNavigation:self];
	}
	return UIToolbarPositionTop;
}

#pragma mark - Common methods

- (void)createPageViewController {
	// Create page controller
	_pageViewController =
	[[UIPageViewController alloc]
	 initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
	 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
	 options:nil];
	_pageViewController.delegate = self;
	_pageViewController.dataSource = self;
	
	// delegate scrollview
	for (UIView *subView in _pageViewController.view.subviews) {
		if ([subView isKindOfClass:[UIScrollView class]]) {
			((UIScrollView *)subView).delegate = self;
		}
	}
	
	BOOL isToolbarChildView = [self.view.subviews containsObject:_toolbar];
	[_pageViewController willMoveToParentViewController:self];
	[self addChildViewController:_pageViewController];
	if (isToolbarChildView) {
		[self.view insertSubview:_pageViewController.view belowSubview:_toolbar];
	} else {
		[self.view addSubview:_pageViewController.view];
	}
	[_pageViewController didMoveToParentViewController:self];
	
	// Add layout constraints
	_pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	// Views dictionary
	NSDictionary *views = @{@"pageViewController": _pageViewController.view,
							@"segmentedToolbar": _toolbar};
	
	// Create constraints using visual format
	NSMutableArray *constraints = [NSMutableArray new];
	
	UIBarPosition position = UIBarPositionTop;
	if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
		position = [_delegate barPositionForCarbonTabSwipeNavigation:self];
	}
	
	NSString *verticalConstraints = @"V:|[pageViewController]|";
	if (isToolbarChildView) {
		if (position == UIBarPositionTop || position == UIBarPositionTopAttached) {
			verticalConstraints = @"V:[segmentedToolbar][pageViewController]|";
		} else if (position == UIBarPositionBottom) {
			verticalConstraints = @"V:|[pageViewController][segmentedToolbar]";
		}
	}
	
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:verticalConstraints
	  options:0
	  metrics:nil
	  views:views]];
	
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"H:|[pageViewController]|"
	  options:0
	  metrics:nil
	  views:views]];
	
	[self.view addConstraints:constraints];
}

- (void)setToolbar:(UIToolbar *)toolbar {
	_toolbar = toolbar;
	_toolbar.delegate = self;
}

- (void)createSegmentedToolbar {
	[self setToolbar:[[UIToolbar alloc] init]];
}

- (void)addToolbarIntoSuperview {
	// add views
	[self.view addSubview:_toolbar];
	
	// Add layout constraints
	_toolbar.translatesAutoresizingMaskIntoConstraints = NO;
	
	// Views dictionary
	NSDictionary *views = NSDictionaryOfVariableBindings(_toolbar);
	
	// Create constraints using visual format
	NSMutableArray *constraints = [NSMutableArray new];
	
	UIBarPosition position = UIBarPositionTop;
	if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
		position = [_delegate barPositionForCarbonTabSwipeNavigation:self];
	}
	
	if (position == UIBarPositionTop) {
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint
		  constraintsWithVisualFormat:@"V:|[_toolbar]"
		  options:0
		  metrics:nil
		  views:views]];
	} else {
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint
		  constraintsWithVisualFormat:@"V:[_toolbar]|"
		  options:0
		  metrics:nil
		  views:views]];
	}
	
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"H:|[_toolbar]|"
	  options:0
	  metrics:nil
	  views:views]];
	
	_toolbarHeight = [NSLayoutConstraint constraintWithItem:_toolbar
												  attribute:NSLayoutAttributeHeight
												  relatedBy:NSLayoutRelationEqual
													 toItem:nil
												  attribute:NSLayoutAttributeNotAnAttribute
												 multiplier:1.0
												   constant:40];
	[constraints addObject:_toolbarHeight];
	
	[self.view addConstraints:constraints];
}

- (void)createTabSwipeScrollViewWithItems:(NSArray *)items {
	NSAssert(_toolbar, @"Toolbar is not created!");
	
	_carbonTabSwipeScrollView = [[CarbonTabSwipeScrollView alloc] initWithItems:items];
	[_toolbar addSubview:_carbonTabSwipeScrollView];
	
	[_carbonTabSwipeScrollView.carbonSegmentedControl
	 addTarget:self
	 action:@selector(segmentedTapped:)
	 forControlEvents:UIControlEventValueChanged];
	
	UIBarPosition position = UIBarPositionTop;
	if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
		position = [_delegate barPositionForCarbonTabSwipeNavigation:self];
	}
	
	if (position == UIBarPositionTop) {
		self.carbonSegmentedControl.indicatorPosition = IndicatorPositionBottom;
	} else {
		self.carbonSegmentedControl.indicatorPosition = IndicatorPositionTop;
	}
	
	// Add layout constraints
	_carbonTabSwipeScrollView.translatesAutoresizingMaskIntoConstraints = NO;
	
	// Views dictionary
	NSDictionary *views = NSDictionaryOfVariableBindings(_carbonTabSwipeScrollView);
	
	// Create constraints using visual format
	NSMutableArray *constraints = [NSMutableArray new];
	
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"V:|[_carbonTabSwipeScrollView]|"
	  options:0
	  metrics:nil
	  views:views]];
	
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint
	  constraintsWithVisualFormat:@"H:|[_carbonTabSwipeScrollView]|"
	  options:0
	  metrics:nil
	  views:views]];
	
	[_toolbar addConstraints:constraints];
}

- (void)loadFirstViewController {
	// Load first view controller
	NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
	
	id viewController = _viewControllers[@(selectedIndex)];
	if (!viewController) {
		viewController = [_delegate carbonTabSwipeNavigation:self
									   viewControllerAtIndex:selectedIndex];
	}
	_viewControllers[@(selectedIndex)] = viewController;
	
	id completionBlock = ^(BOOL finished) {
		[self callDelegateForCurrentIndex];
	};
	
	[_pageViewController setViewControllers:@[viewController]
								  direction:UIPageViewControllerNavigationDirectionForward
								   animated:YES
								 completion:completionBlock];
}

- (void)callDelegateForTargetIndex {
	if ([_delegate respondsToSelector:@selector(carbonTabSwipeNavigation:willMoveAtIndex:)]) {
		[_delegate carbonTabSwipeNavigation:self willMoveAtIndex:self.carbonSegmentedControl.selectedSegmentIndex];
	}
}

- (void)callDelegateForCurrentIndex {
	if ([_delegate respondsToSelector:@selector(carbonTabSwipeNavigation:didMoveAtIndex:)]) {
		[_delegate carbonTabSwipeNavigation:self didMoveAtIndex:self.carbonSegmentedControl.selectedSegmentIndex];
	}
}

- (void)setTabBarHeight:(CGFloat)height {
	_toolbarHeight.constant = height;
	[self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
}

- (NSUInteger)currentTabIndex {
	return selectedIndex;
}

- (void)setCurrentTabIndex:(NSUInteger)currentTabIndex {
	if (currentTabIndex != selectedIndex &&
		currentTabIndex < self.carbonSegmentedControl.numberOfSegments) {
		// Trigger segmented tap action
		self.carbonSegmentedControl.selectedSegmentIndex = selectedIndex = currentTabIndex;
		[self.carbonSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (CarbonTabSwipeSegmentedControl *)carbonSegmentedControl {
	return _carbonTabSwipeScrollView.carbonSegmentedControl;
}

- (void)setIndicatorHeight:(CGFloat)height {
	[self.carbonSegmentedControl setIndicatorHeight:height];
	[self.carbonSegmentedControl layoutSubviews];
}

- (void)setIndicatorColor:(UIColor *)color {
	self.carbonSegmentedControl.indicator.backgroundColor = color;
}

- (void)setNormalColor:(UIColor *)color {
	[self setNormalColor:color font:[UIFont boldSystemFontOfSize:14]];
}

- (void)setNormalColor:(UIColor *)color font:(UIFont *)font {
	[self.carbonSegmentedControl
	 setTitleTextAttributes:@{
							  NSForegroundColorAttributeName : color,
							  NSFontAttributeName : font
							  }
	 forState:UIControlStateNormal];
}

- (void)setSelectedColor:(UIColor *)color {
	[self setSelectedColor:color font:[UIFont boldSystemFontOfSize:14]];
}

- (void)setSelectedColor:(UIColor *)color font:(UIFont *)font {
	
	[self.carbonSegmentedControl
	 setTitleTextAttributes:@{
							  NSForegroundColorAttributeName : color,
							  NSFontAttributeName : font
							  }
	 forState:UIControlStateSelected];
}

- (void)setTabExtraWidth:(CGFloat)extraWidth {
	self.carbonSegmentedControl.tabExtraWidth = extraWidth;
}

@end
