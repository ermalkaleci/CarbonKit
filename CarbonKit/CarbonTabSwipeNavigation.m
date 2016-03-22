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

@interface CarbonTabSwipeNavigation () <UIPageViewControllerDelegate, UIToolbarDelegate,
                                        UIPageViewControllerDataSource, UIScrollViewDelegate>
@end

@implementation CarbonTabSwipeNavigation {
    BOOL isSwipeLocked;
    NSInteger selectedIndex;
    CGPoint previewsOffset;
}

- (void)insertIntoRootViewController:(UIViewController *)rootViewController {
    [self willMoveToParentViewController:rootViewController];
    [rootViewController addChildViewController:self];
    [rootViewController.view addSubview:self.view];
    [self didMoveToParentViewController:rootViewController];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    id views = @{
        @"carbonTabSwipe" : self.view,
        @"topLayoutGuide" : rootViewController.topLayoutGuide,
        @"bottomLayoutGuide" : rootViewController.bottomLayoutGuide
    };

    NSString *verticalFormat = @"V:[topLayoutGuide][carbonTabSwipe][bottomLayoutGuide]";
    [rootViewController.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
    [rootViewController.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[carbonTabSwipe]|"
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
    id views = @{ @"carbonTabSwipe" : self.view };

    [targetView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[carbonTabSwipe]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
    [targetView
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[carbonTabSwipe]|"
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

- (instancetype)initWithItems:(NSArray *)items toolBar:(UIToolbar *)toolBar delegate:(id)target {
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
	
	// Fix UIPageViewController misplace issue on iOS 8
	[self.pageViewController.view setNeedsLayout];
	
	[self.pageViewController viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.pageViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.pageViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	[self.pageViewController viewDidDisappear:animated];
}
- (void)dealloc
{
	[self prepareForDisappearance];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    isSwipeLocked = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.pageViewController.view layoutSubviews];
    isSwipeLocked = NO;
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

    UIPageViewControllerNavigationDirection animateDirection =
        index >= selectedIndex ? UIPageViewControllerNavigationDirectionForward
                               : UIPageViewControllerNavigationDirectionReverse;

    // Support RTL
    if (self.isRTL) {
        if (animateDirection == UIPageViewControllerNavigationDirectionForward) {
            animateDirection = UIPageViewControllerNavigationDirectionReverse;
        } else {
            animateDirection = UIPageViewControllerNavigationDirectionForward;
        }
    }

    isSwipeLocked = YES;
    segment.userInteractionEnabled = NO;
    self.pageViewController.view.userInteractionEnabled = NO;

    id animateCompletionBlock = ^(BOOL finished) {
        isSwipeLocked = NO;
        selectedIndex = index;
        self.carbonSegmentedControl.userInteractionEnabled = YES;
        self.pageViewController.view.userInteractionEnabled = YES;

        [self callDelegateForCurrentIndex];
    };

    [self callDelegateForTargetIndex];

    [self.pageViewController setViewControllers:@[ viewController ]
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

    [UIView animateWithDuration:0.3
                     animations:^{
                         _carbonTabSwipeScrollView.contentOffset = CGPointMake(offsetX, 0);
                     }];

    previewsOffset = _carbonTabSwipeScrollView.contentOffset;
}

#pragma mark - PageViewController data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex + 1;
	
	if (index < self.carbonSegmentedControl.numberOfSegments) {
		
		UIViewController *nextViewController = _viewControllers[@(index)];
		
		if (nextViewController == nil) {
            NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
            nextViewController =
                [_delegate carbonTabSwipeNavigation:self viewControllerAtIndex:index];
            _viewControllers[@(index)] = nextViewController;
        }
        return nextViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSInteger index = selectedIndex - 1;
	
	if (index >= 0) {
		
		UIViewController *nextViewController = _viewControllers[@(index)];
		
		if (nextViewController == nil) {
            NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");
            nextViewController =
                [_delegate carbonTabSwipeNavigation:self viewControllerAtIndex:index];
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

    if (completed) {
        id currentView = pageViewController.viewControllers.firstObject;
        selectedIndex = [[_viewControllers allKeysForObject:currentView].firstObject integerValue];

        [self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex];
        [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

        [self callDelegateForCurrentIndex];
    }
}

# pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.carbonSegmentedControl.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.carbonSegmentedControl.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGPoint offset = scrollView.contentOffset;
    CGFloat segmentedWidth = [self.carbonSegmentedControl getWidth];
    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.frame);

    if (selectedIndex < 0 || selectedIndex > self.carbonSegmentedControl.numberOfSegments - 1) {
        return;
    }

    if (!isSwipeLocked) {

        if (offset.x < scrollViewWidth) {
            // we are moving back

            // Support RTL
            NSInteger backIndex = selectedIndex;
            if (self.isRTL) {
                // Ensure index range
                if (++backIndex >= self.carbonSegmentedControl.numberOfSegments) {
                    return;
                }
            } else {
                // Ensure index range
                if (--backIndex < 0) {
                    return;
                }
            }

            CGFloat newX = offset.x - scrollViewWidth;

            CGFloat selectedSegmentWidth =
                [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
            CGFloat selectedOriginX =
                [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
            CGFloat backTabWidth =
                [self.carbonSegmentedControl getWidthForSegmentAtIndex:backIndex];

            CGFloat minX = selectedOriginX + newX / scrollViewWidth * backTabWidth;
            [self.carbonSegmentedControl setIndicatorMinX:minX];

            CGFloat widthDiff = selectedSegmentWidth - backTabWidth;

            CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
            [self.carbonSegmentedControl setIndicatorWidth:newWidth];
            [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

            if (ABS(newX) > scrollViewWidth / 2) {
                if (self.carbonSegmentedControl.selectedSegmentIndex != backIndex) {
                    [self.carbonSegmentedControl setSelectedSegmentIndex:backIndex];
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

            // Support RTL
            NSInteger nextIndex = selectedIndex;
            if (self.isRTL) {
                // Ensure index range
                if (--nextIndex < 0) {
                    return;
                }
            } else {
                // Ensure index range
                if (++nextIndex >= self.carbonSegmentedControl.numberOfSegments) {
                    return;
                }
            }

            CGFloat newX = offset.x - scrollViewWidth;

            CGFloat selectedSegmentWidth =
                [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
            CGFloat selectedOriginX =
                [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
            CGFloat nextTabWidth =
                [self.carbonSegmentedControl getWidthForSegmentAtIndex:nextIndex];

            CGFloat minX = selectedOriginX + newX / scrollViewWidth * selectedSegmentWidth;
            [self.carbonSegmentedControl setIndicatorMinX:minX];

            CGFloat widthDiff = nextTabWidth - selectedSegmentWidth;

            CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
            [self.carbonSegmentedControl setIndicatorWidth:newWidth];
            [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

            if (newX > scrollViewWidth / 2) {
                if (self.carbonSegmentedControl.selectedSegmentIndex != nextIndex) {
                    [self.carbonSegmentedControl setSelectedSegmentIndex:nextIndex];
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

    CGFloat indicatorMaxOriginX =
        scrollViewWidth / 2 - self.carbonSegmentedControl.indicatorWidth / 2;
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

    [UIView animateWithDuration:isSwipeLocked ? 0.3 : 0
                     animations:^{
                         _carbonTabSwipeScrollView.contentOffset = CGPointMake(offsetX, 0);
                     }];

    previewsOffset = scrollView.contentOffset;
}

#pragma mark - Toolbar position

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        return [_delegate barPositionForCarbonTabSwipeNavigation:self];
    }
    return UIToolbarPositionTop;
}

#pragma mark - Common methods

- (void)createPageViewController {
    // Create page controller
    _pageViewController = [[UIPageViewController alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                        options:nil];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;

    // delegate scrollview
    for (id subView in _pageViewController.view.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
			self.pagesScrollView = subView;
            self.pagesScrollView.delegate = self;
            self.pagesScrollView.panGestureRecognizer.maximumNumberOfTouches = 1;
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
    NSDictionary *views =
        @{ @"pageViewController" : _pageViewController.view,
           @"segmentedToolbar" : _toolbar };

    // Create constraints using visual format
	
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

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view
        addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageViewController]|"
                                                               options:0
                                                               metrics:nil
                                                                 views:views]];
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

    UIBarPosition position = UIBarPositionTop;
    if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        position = [_delegate barPositionForCarbonTabSwipeNavigation:self];
    }

    NSString *verticalFormat = @"V:[_toolbar]|";

    if (position == UIBarPositionTop || position == UIBarPositionTopAttached) {
        verticalFormat = @"V:|[_toolbar]";
    }

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
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

    [self.view addConstraint:_toolbarHeight];
}

- (void)createTabSwipeScrollViewWithItems:(NSArray *)items {
    NSAssert(_toolbar, @"Toolbar is not created!");

    _carbonTabSwipeScrollView = [[CarbonTabSwipeScrollView alloc] initWithItems:items];
    [_toolbar addSubview:_carbonTabSwipeScrollView];

    [_carbonTabSwipeScrollView.carbonSegmentedControl addTarget:self
                                                         action:@selector(segmentedTapped:)
                                               forControlEvents:UIControlEventValueChanged];

    UIBarPosition position = UIBarPositionTop;
    if ([_delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        position = [_delegate barPositionForCarbonTabSwipeNavigation:self];
    }

    if (position == UIBarPositionTop || position == UIBarPositionTopAttached) {
        self.carbonSegmentedControl.indicatorPosition = IndicatorPositionBottom;
    } else {
        self.carbonSegmentedControl.indicatorPosition = IndicatorPositionTop;
    }

    // Add layout constraints
    _carbonTabSwipeScrollView.translatesAutoresizingMaskIntoConstraints = NO;

    // Views dictionary
    NSDictionary *views = NSDictionaryOfVariableBindings(_carbonTabSwipeScrollView);

    // Create constraints using visual format
	
	[_toolbar addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"V:|[_carbonTabSwipeScrollView]|"
                                                     options:0
                                                     metrics:nil
                                                       views:views]];
	
    [_toolbar addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|[_carbonTabSwipeScrollView]|"
                                                     options:0
                                                     metrics:nil
                                                       views:views]];
}

- (void)loadFirstViewController {
    // Load first view controller
    NSAssert(_delegate, @"CarbonTabSwipeDelegate is nil");

    id viewController = _viewControllers[@(selectedIndex)];
    if (!viewController) {
        viewController =
            [_delegate carbonTabSwipeNavigation:self viewControllerAtIndex:selectedIndex];
    }
    _viewControllers[@(selectedIndex)] = viewController;

	[self callDelegateForTargetIndex];
	
    id completionBlock = ^(BOOL finished) {
        [self callDelegateForCurrentIndex];
    };
	
    [_pageViewController setViewControllers:@[ viewController ]
                                  direction:self.directionAnimation
                                   animated:YES
                                 completion:completionBlock];
}

- (BOOL)isRTL {
    return [UIApplication sharedApplication].userInterfaceLayoutDirection ==
               UIUserInterfaceLayoutDirectionRightToLeft &&
           [self.view respondsToSelector:@selector(semanticContentAttribute)];
}

- (UIPageViewControllerNavigationDirection)directionAnimation {
    if (self.isRTL) {
        return UIPageViewControllerNavigationDirectionReverse;
    }
    return UIPageViewControllerNavigationDirectionForward;
}

- (void)callDelegateForTargetIndex {
    if ([_delegate respondsToSelector:@selector(carbonTabSwipeNavigation:willMoveAtIndex:)]) {
		NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [_delegate carbonTabSwipeNavigation:self willMoveAtIndex:index];
    }
}

- (void)callDelegateForCurrentIndex {
    if ([_delegate respondsToSelector:@selector(carbonTabSwipeNavigation:didMoveAtIndex:)]) {
		NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [_delegate carbonTabSwipeNavigation:self didMoveAtIndex:index];
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
    NSInteger numberOfSegments = self.carbonSegmentedControl.numberOfSegments;
    if (currentTabIndex != selectedIndex && currentTabIndex < numberOfSegments) {
        // Trigger segmented tap action
        self.carbonSegmentedControl.selectedSegmentIndex = currentTabIndex;
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
    id titleAttr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
    [self.carbonSegmentedControl setTitleTextAttributes:titleAttr forState:UIControlStateNormal];
}

- (void)setSelectedColor:(UIColor *)color {
	[self setSelectedColor:color font:[UIFont boldSystemFontOfSize:14]];
}

- (void)setSelectedColor:(UIColor *)color font:(UIFont *)font {
    id titleAttr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
    [self.carbonSegmentedControl setTitleTextAttributes:titleAttr forState:UIControlStateSelected];
}

- (void)setTabExtraWidth:(CGFloat)extraWidth {
    self.carbonSegmentedControl.tabExtraWidth = extraWidth;
}
-(void)prepareForDisappearance{
	[_pageViewController willMoveToParentViewController:nil];
	[_pageViewController beginAppearanceTransition:NO animated:YES];    
	[_pageViewController.view removeFromSuperview]; 
	[_pageViewController removeFromParentViewController];
	[_pageViewController endAppearanceTransition];
}
@end
