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

#import <UIKit/UIKit.h>
#import "CarbonTabSwipeScrollView.h"


NS_ASSUME_NONNULL_BEGIN

@class CarbonTabSwipeNavigation;

@protocol CarbonTabSwipeNavigationDelegate <NSObject>

@required
/**
 *  This method must override to return each view controller
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *  @param index Tab index
 *
 *  @return UIViewController at index
 */
- (nonnull UIViewController *)carbonTabSwipeNavigation:
                                  (nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                                 viewControllerAtIndex:(NSUInteger)index;

@optional
/**
 *  Will move to index
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *  @param index Target index
 */
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                 willMoveAtIndex:(NSUInteger)index;

/**
 *  Did move to index
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *  @param index Current index
 */
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
                  didMoveAtIndex:(NSUInteger)index;

/**
 *  Will start the page transition from index.
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *  @param index Starting index
 */
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
    willBeginTransitionFromIndex:(NSUInteger)index;

/**
 *  Did finish the page transition to index.
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *  @param index Target index
 */
- (void)carbonTabSwipeNavigation:(nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation
      didFinishTransitionToIndex:(NSUInteger)index;

/**
 *  Toolbar position
 *
 *  @param carbonTabSwipeNavigation CarbonTabSwipeNavigation instance
 *
 *  @return Toolbar position (UIBarPositionTop or UIBarPositionBottom)
 */
- (UIBarPosition)barPositionForCarbonTabSwipeNavigation:
    (nonnull CarbonTabSwipeNavigation *)carbonTabSwipeNavigation;

@end

@interface CarbonTabSwipeNavigation : UIViewController

@property(nonatomic) NSUInteger currentTabIndex;
@property(nonatomic) NSLayoutConstraint *toolbarHeight;
@property(nonatomic, nonnull) UIToolbar *toolbar;
@property(nonatomic, nonnull) UIPageViewController *pageViewController;
@property(nonatomic, nonnull) CarbonTabSwipeScrollView *carbonTabSwipeScrollView;
@property(weak, nonatomic) UIScrollView *pagesScrollView;
@property(weak, nonatomic) id<CarbonTabSwipeNavigationDelegate> delegate;
@property(weak, nonatomic, readonly) CarbonTabSwipeSegmentedControl *carbonSegmentedControl;
@property(nonatomic) NSMutableDictionary<NSNumber *, UIViewController *> *viewControllers;

/**
 *  Insert instance into rootViewController and create constraint using
 *  topLayoutGuide, bottomLayoutGuide, leading, trailing equal to 0.
 *  +-----------------------------------+
 *  |          topLayoutGuide           |
 *  +-----------------------------------+
 *  |                                   |
 *  |                                   |
 *  |     CarbonTabSwipeNavigation      |
 *  |                                   |
 *  |                                   |
 *  +-----------------------------------+
 *  |        bottomLayoutGuide          |
 *  +-----------------------------------+
 *
 *  @param rootViewController Parent view controller
 */
- (void)insertIntoRootViewController:(nonnull UIViewController *)rootViewController;

/**
 *  Insert instance into rootViewController and create constraint using
 *  targetViewTopAnchor, targetViewBottomAnchor, leading, trailing equal to 0.
 *  +-----------------------------------+
 *  |       targetViewTopAnchor         |
 *  +-----------------------------------+
 *  |                                   |
 *  |                                   |
 *  |     CarbonTabSwipeNavigation      |
 *  |                                   |
 *  |                                   |
 *  +-----------------------------------+
 *  |      targetViewBottomAnchor       |
 *  +-----------------------------------+
 *
 *  @param rootViewController Parent view controller
 *	@param targetView Parent view
 */
- (void)insertIntoRootViewController:(nonnull UIViewController *)rootViewController
                       andTargetView:(nonnull UIView *)targetView;

/**
 *  Create CarbonTabSwipeNavigation with items
 *
 *  @param items Array of items
 *  @param target Delegate target object
 *
 *  @return CarbonTabSwipeNavigation instance
 */
- (instancetype)initWithItems:(nullable NSArray *)items delegate:(nonnull id)target;

/**
 *  Create CarbonTabSwipeNavigation with items
 *
 *  @param items Array of items
 *  @param toolBar Tool bar for Menu
 *  @param target Delegate target object
 *
 *  @return CarbonTabSwipeNavigation instance
 */
- (instancetype)initWithItems:(nullable NSArray *)items
                      toolBar:(nonnull UIToolbar *)toolBar
                     delegate:(nonnull id)target __attribute__((deprecated));

/**
 *  Set tab bar height
 *
 *  @param height TabBar height
 */
- (void)setTabBarHeight:(CGFloat)height;

/**
 *  Set indicator height
 *
 *  @param height Indicator height
 */
- (void)setIndicatorHeight:(CGFloat)height;

/**
 *  Set indicator color
 *
 *  @param color Indicator color
 */
- (void)setIndicatorColor:(nullable UIColor *)color;

/**
 *  Set segmented control color for normal state
 *
 *  @param color Normal state color
 */
- (void)setNormalColor:(nonnull UIColor *)color;

/**
 *  Set segmented control color and font for normal state
 *
 *  @param color Normal state color
 *  @param font Normal state font
 */
- (void)setNormalColor:(nonnull UIColor *)color font:(nonnull UIFont *)font;

/**
 *  Set segmented control color for selected sate
 *
 *  @param color Selected state color
 */
- (void)setSelectedColor:(nonnull UIColor *)color;

/**
 *  Set segmented control color and font for selected state
 *
 *  @param color Selected state color
 *  @param font Selected state font
 */
- (void)setSelectedColor:(nonnull UIColor *)color font:(nonnull UIFont *)font;

/**
 *  Set an extra width for each segment
 *  Use positive values for increasign or nevative values for descreasing
 *
 *  @param extraWidth Extra width value
 */
- (void)setTabExtraWidth:(CGFloat)extraWidth;

/**
 *  Change selected tab index
 *
 *  @param currentTabIndex Desired index to move
 *  @param animate Change the tab with animation
 */
- (void)setCurrentTabIndex:(NSUInteger)currentTabIndex withAnimation:(BOOL)animate;

NS_ASSUME_NONNULL_END

@end
