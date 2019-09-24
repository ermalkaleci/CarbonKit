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
    BOOL isLoaded;
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
    self = [super init];
    if (self) {
        selectedIndex = 0;
        self.delegate = target;
        self.viewControllers = [NSMutableDictionary new];

        [self createSegmentedToolbar];
        [self createTabSwipeScrollViewWithItems:items];
        [self addToolbarIntoSuperview];
        [self createPageViewController];

        [self loadFirstViewController];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items toolBar:(UIToolbar *)toolBar delegate:(id)target {
    self = [super init];
    if (self) {
        selectedIndex = 0;
        self.delegate = target;
        self.viewControllers = [NSMutableDictionary new];

        [self setToolbar:toolBar];
        [self createTabSwipeScrollViewWithItems:items];
        [self createPageViewController];

        [self loadFirstViewController];
    }
    return self;
}

#pragma mark - Override

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.pageViewController viewDidAppear:animated];
    [self syncIndicator];
    isLoaded = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.pageViewController viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pageViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.pageViewController viewDidDisappear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self syncIndicator];
        [CATransaction commit];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        isSwipeLocked = NO;
    }];
    isSwipeLocked = YES;
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Actions

- (void)segmentedTapped:(CarbonTabSwipeSegmentedControl *)segment {
    [self moveToIndex:segment.selectedSegmentIndex withAnimation:YES];
}

- (void)moveToIndex:(NSUInteger)index withAnimation:(BOOL)animate {
    UIViewController *viewController = [self viewControllerAtIndex:index];

    UIPageViewControllerNavigationDirection animateDirection =
        index >= selectedIndex ? UIPageViewControllerNavigationDirectionForward
                               : UIPageViewControllerNavigationDirectionReverse;

    // Support RTL
    if ([self isRTL]) {
        if (animateDirection == UIPageViewControllerNavigationDirectionForward) {
            animateDirection = UIPageViewControllerNavigationDirectionReverse;
        } else {
            animateDirection = UIPageViewControllerNavigationDirectionForward;
        }
    }

    isSwipeLocked = YES;
    self.carbonSegmentedControl.userInteractionEnabled = NO;
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
                                       animated:animate
                                     completion:animateCompletionBlock];
}

- (void)syncIndicator {
    NSInteger index = selectedIndex;
    CGFloat selectedSegmentMinX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:index];
    CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:index];

    [self.carbonSegmentedControl setIndicatorMinX:selectedSegmentMinX];
    [self.carbonSegmentedControl setIndicatorWidth:selectedSegmentWidth];
    [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

    CGFloat segmentedWidth = CGRectGetWidth(self.carbonSegmentedControl.frame);
    CGFloat tabScrollViewWidth = CGRectGetWidth(self.carbonTabSwipeScrollView.frame);

    CGFloat indicatorMaxOriginX = tabScrollViewWidth / 2 - selectedSegmentWidth / 2;
    CGFloat offsetX = selectedSegmentMinX - indicatorMaxOriginX;

    if (segmentedWidth <= tabScrollViewWidth) {
        offsetX = 0;
    } else {
        offsetX = MAX(offsetX, 0);
        offsetX = MIN(offsetX, segmentedWidth - tabScrollViewWidth);
    }

    previewsOffset = CGPointMake(offsetX, 0);
    [UIView animateWithDuration:isLoaded ? 0.3 : 0
                     animations:^{
                         self.carbonTabSwipeScrollView.contentOffset = previewsOffset;
                     }];
}

#pragma mark - PageViewController data source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index =
        [self.viewControllers allKeysForObject:viewController].firstObject.integerValue;
    index += 1;
    if (index < self.carbonSegmentedControl.numberOfSegments) {
        return [self viewControllerAtIndex:index];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index =
        [self.viewControllers allKeysForObject:viewController].firstObject.integerValue;
    index -= 1;
    if (index >= 0) {
        return [self viewControllerAtIndex:index];
    }
    return nil;
}

#pragma mark - PageViewController Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
    willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self callDelegateForStartingTransition];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        id currentView = pageViewController.viewControllers.firstObject;
        selectedIndex =
            [[self.viewControllers allKeysForObject:currentView].firstObject integerValue];

        [self.carbonSegmentedControl setSelectedSegmentIndex:selectedIndex];
        [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

        [self callDelegateForCurrentIndex];
    }

    [self callDelegateForFinishingTransition];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.carbonSegmentedControl.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.carbonSegmentedControl.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGPoint offset = scrollView.contentOffset;
    CGFloat segmentedWidth = CGRectGetWidth(self.carbonSegmentedControl.frame);
    CGFloat scrollViewWidth = CGRectGetWidth(scrollView.frame);
    CGFloat tabScrollViewWidth = CGRectGetWidth(self.carbonTabSwipeScrollView.frame);

    if (selectedIndex < 0 || selectedIndex > self.carbonSegmentedControl.numberOfSegments - 1) {
        return;
    }

    if (isSwipeLocked == false) {

        if (offset.x < scrollViewWidth) {
            // we are moving back

            CGFloat newX = offset.x - scrollViewWidth;

            CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
            CGFloat selectedOriginX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
            CGFloat backTabWidth = 0;

            // Support RTL
            NSInteger backIndex = selectedIndex;
            if ([self isRTL]) {
                // Ensure index range
                if (!(++backIndex >= self.carbonSegmentedControl.numberOfSegments)) {
                    backTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:backIndex];
                }
            } else {
                // Ensure index range
                if (!(--backIndex < 0)) {
                    backTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:backIndex];
                }
            }

            CGFloat minX = selectedOriginX + newX / scrollViewWidth * backTabWidth;
            [self.carbonSegmentedControl setIndicatorMinX:minX];

            CGFloat widthDiff = selectedSegmentWidth - backTabWidth;

            CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
            [self.carbonSegmentedControl setIndicatorWidth:newWidth];
            [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

            if ([self isRTL]) {
                // Ensure index range
                if (backIndex >= self.carbonSegmentedControl.numberOfSegments) {
                    return;
                }
            } else {
                // Ensure index range
                if (backIndex < 0) {
                    return;
                }
            }

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

            CGFloat newX = offset.x - scrollViewWidth;

            CGFloat selectedSegmentWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:selectedIndex];
            CGFloat selectedOriginX = [self.carbonSegmentedControl getMinXForSegmentAtIndex:selectedIndex];
            CGFloat nextTabWidth = 0;

            // Support RTL
            NSInteger nextIndex = selectedIndex;
            if ([self isRTL]) {
                // Ensure index range
                if (!(--nextIndex < 0)) {
                    nextTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:nextIndex];
                }
            } else {
                // Ensure index range
                if (!(++nextIndex >= self.carbonSegmentedControl.numberOfSegments)) {
                    nextTabWidth = [self.carbonSegmentedControl getWidthForSegmentAtIndex:nextIndex];
                }
            }

            CGFloat minX = selectedOriginX + newX / scrollViewWidth * selectedSegmentWidth;
            [self.carbonSegmentedControl setIndicatorMinX:minX];

            CGFloat widthDiff = nextTabWidth - selectedSegmentWidth;

            CGFloat newWidth = selectedSegmentWidth + newX / scrollViewWidth * widthDiff;
            [self.carbonSegmentedControl setIndicatorWidth:newWidth];
            [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];

            if ([self isRTL]) {
                // Ensure index range
                if (nextIndex < 0) {
                    return;
                }
            } else {
                // Ensure index range
                if (nextIndex >= self.carbonSegmentedControl.numberOfSegments) {
                    return;
                }
            }

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

    CGFloat indicatorMaxOriginX = tabScrollViewWidth / 2 - self.carbonSegmentedControl.indicatorWidth / 2;
    CGFloat offsetX = self.carbonSegmentedControl.indicatorMinX - indicatorMaxOriginX;

    if (segmentedWidth <= tabScrollViewWidth) {
        offsetX = 0;
    } else {
        offsetX = MAX(offsetX, 0);
        offsetX = MIN(offsetX, segmentedWidth - tabScrollViewWidth);
    }

    // Stop deceleration
    if ([self.carbonTabSwipeScrollView isDecelerating]) {
        [self.carbonTabSwipeScrollView setContentOffset:self.carbonTabSwipeScrollView.contentOffset animated:NO];
    }

    [UIView animateWithDuration:isSwipeLocked ? 0.3 : 0
                     animations:^{
                         self.carbonTabSwipeScrollView.contentOffset = CGPointMake(offsetX, 0);
                     }];

    previewsOffset = scrollView.contentOffset;
}

#pragma mark - Toolbar position

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    if ([self.delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        return [self.delegate barPositionForCarbonTabSwipeNavigation:self];
    }
    return UIToolbarPositionTop;
}

#pragma mark - Common methods

- (void)createPageViewController {
    // Create page controller
    self.pageViewController = [[UIPageViewController alloc]
        initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                        options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;

    // delegate scrollview
    for (id subView in self.pageViewController.view.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            self.pagesScrollView = subView;
            self.pagesScrollView.delegate = self;
            self.pagesScrollView.panGestureRecognizer.maximumNumberOfTouches = 1;
        }
    }

    BOOL isToolbarChildView = [self.view.subviews containsObject:self.toolbar];
    [self.pageViewController willMoveToParentViewController:self];
    [self addChildViewController:self.pageViewController];
    if (isToolbarChildView) {
        [self.view insertSubview:self.pageViewController.view belowSubview:self.toolbar];
    } else {
        [self.view addSubview:self.pageViewController.view];
    }
    [self.pageViewController didMoveToParentViewController:self];

    // Setup constraints
    self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    // Views dictionary
    NSDictionary *views = @{
        @"pageViewController" : self.pageViewController.view,
        @"segmentedToolbar" : self.toolbar
    };

    // Create constraints using visual format

    UIBarPosition position = UIBarPositionTop;
    if ([self.delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        position = [self.delegate barPositionForCarbonTabSwipeNavigation:self];
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
    [self.view addSubview:self.toolbar];

    // Setup constraints
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;

    // Views dictionary
    NSDictionary *views = NSDictionaryOfVariableBindings(_toolbar);

    // Create constraints using visual format

    UIBarPosition position = UIBarPositionTop;
    if ([self.delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        position = [self.delegate barPositionForCarbonTabSwipeNavigation:self];
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

    self.toolbarHeight = [NSLayoutConstraint constraintWithItem:self.toolbar
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:40];

    [self.view addConstraint:self.toolbarHeight];
}

- (void)createTabSwipeScrollViewWithItems:(NSArray *)items {
    NSAssert(self.toolbar, @"Toolbar is not created!");

    self.carbonTabSwipeScrollView = [[CarbonTabSwipeScrollView alloc] initWithItems:items];
    self.carbonTabSwipeScrollView.clipsToBounds = NO;
    [self.toolbar addSubview:self.carbonTabSwipeScrollView];

    [self.carbonTabSwipeScrollView.carbonSegmentedControl addTarget:self
                                                             action:@selector(segmentedTapped:)
                                                   forControlEvents:UIControlEventValueChanged];

    UIBarPosition position = UIBarPositionTop;
    if ([self.delegate respondsToSelector:@selector(barPositionForCarbonTabSwipeNavigation:)]) {
        position = [self.delegate barPositionForCarbonTabSwipeNavigation:self];
    }

    if (position == UIBarPositionTop || position == UIBarPositionTopAttached) {
        self.carbonSegmentedControl.indicatorPosition = IndicatorPositionBottom;
    } else {
        self.carbonSegmentedControl.indicatorPosition = IndicatorPositionTop;
    }

    // Add layout constraints
    self.carbonTabSwipeScrollView.translatesAutoresizingMaskIntoConstraints = NO;

    // Views dictionary
    NSDictionary *views = NSDictionaryOfVariableBindings(_carbonTabSwipeScrollView);

    // Create constraints using visual format

    [self.toolbar addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:@"V:|[_carbonTabSwipeScrollView]|"
                                                         options:0
                                                         metrics:nil
                                                           views:views]];

    if (@available(iOS 11.0, *)) {
        [NSLayoutConstraint activateConstraints:
         @[
           [_carbonTabSwipeScrollView.leadingAnchor constraintEqualToAnchor:_toolbar.safeAreaLayoutGuide.leadingAnchor],
           [_carbonTabSwipeScrollView.trailingAnchor constraintEqualToAnchor:_toolbar.safeAreaLayoutGuide.trailingAnchor],
           ]
         ];
    } else {
        [self.toolbar addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_carbonTabSwipeScrollView]|"
                                      options:0
                                      metrics:nil
                                      views:views]];
    }
}

- (void)loadFirstViewController {
    // Load first view controller
    NSAssert(self.delegate, @"CarbonTabSwipeDelegate is nil");

    id viewController = [self viewControllerAtIndex:selectedIndex];

    [self callDelegateForTargetIndex];

    id completionBlock = ^(BOOL finished) {
        [self callDelegateForCurrentIndex];
    };

    [self.pageViewController setViewControllers:@[ viewController ]
                                      direction:self.directionAnimation
                                       animated:YES
                                     completion:completionBlock];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    id viewController = self.viewControllers[@(index)];
    if (viewController == nil) {
        NSAssert(self.delegate, @"CarbonTabSwipeDelegate is nil");
        viewController = [self.delegate carbonTabSwipeNavigation:self viewControllerAtIndex:index];
        self.viewControllers[@(index)] = viewController;
    }
    return viewController;
}

- (BOOL)isRTL {
    if (@available(iOS 9.0, *)) {
        return [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.view.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    return NO;
}

- (UIPageViewControllerNavigationDirection)directionAnimation {
    if ([self isRTL]) {
        return UIPageViewControllerNavigationDirectionReverse;
    }
    return UIPageViewControllerNavigationDirectionForward;
}

- (void)callDelegateForTargetIndex {
    if ([self.delegate respondsToSelector:@selector(carbonTabSwipeNavigation:willMoveAtIndex:)]) {
        NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [self.delegate carbonTabSwipeNavigation:self willMoveAtIndex:index];
    }
}

- (void)callDelegateForCurrentIndex {
    if ([self.delegate respondsToSelector:@selector(carbonTabSwipeNavigation:didMoveAtIndex:)]) {
        NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [self.delegate carbonTabSwipeNavigation:self didMoveAtIndex:index];
    }
}

- (void)callDelegateForStartingTransition {
    if ([self.delegate
            respondsToSelector:@selector(carbonTabSwipeNavigation:willBeginTransitionFromIndex:)]) {
        NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [self.delegate carbonTabSwipeNavigation:self willBeginTransitionFromIndex:index];
    }
}

- (void)callDelegateForFinishingTransition {
    if ([self.delegate
            respondsToSelector:@selector(carbonTabSwipeNavigation:didFinishTransitionToIndex:)]) {
        NSInteger index = self.carbonSegmentedControl.selectedSegmentIndex;
        [self.delegate carbonTabSwipeNavigation:self didFinishTransitionToIndex:index];
    }
}

- (void)setTabBarHeight:(CGFloat)height {
    self.toolbarHeight.constant = height;
    [self.carbonSegmentedControl updateIndicatorWithAnimation:NO];
}

- (NSUInteger)currentTabIndex {
    return selectedIndex;
}

- (void)setCurrentTabIndex:(NSUInteger)currentTabIndex {
    if (isLoaded) {
        [self setCurrentTabIndex:currentTabIndex withAnimation:YES];
    } else {
        [self setCurrentTabIndex:currentTabIndex withAnimation:NO];
    }
}

- (void)setCurrentTabIndex:(NSUInteger)currentTabIndex withAnimation:(BOOL)animate {
    if (isLoaded == NO) {
        animate = NO;
    }

    NSInteger numberOfSegments = self.carbonSegmentedControl.numberOfSegments;
    if (currentTabIndex != selectedIndex && currentTabIndex < numberOfSegments) {
        self.carbonSegmentedControl.selectedSegmentIndex = currentTabIndex;
        [self moveToIndex:currentTabIndex withAnimation:animate];
        [self syncIndicator];
    }
}

- (CarbonTabSwipeSegmentedControl *)carbonSegmentedControl {
    return self.carbonTabSwipeScrollView.carbonSegmentedControl;
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

@end
