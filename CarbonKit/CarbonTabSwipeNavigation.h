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

#import <UIKit/UIKit.h>

@class CarbonTabSwipeNavigation;

/**
 *	CarbonTabSwipe Delegate
 */
@protocol CarbonTabSwipeDelegate <NSObject>

@required
/**
 *	This method must override to return each view controllers
 *	@param tabSwipe CarbonTabSwipeNavigation
 *	@param index NSUInteger : tab index
 *	@return A UIViewController for tab at index
 */
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index;

@optional
/**
 *	When finished moving to index
 *	@param tabSwipe CarbonTabSwipeNavigation
 *	@param index NSInteger : current index
 */
- (void)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe didMoveAtIndex:(NSInteger)index;

@end

/**
 *  Carbon Tab Swipe Interface
 */
@interface CarbonTabSwipeNavigation : UIViewController

/**
 *	CarbonTabSwipeDelegate
 */
@property (nonatomic, weak) id<CarbonTabSwipeDelegate> delegate;

/**
 *	Get the index value of the currently selected tab. Setting this value will change the previously selected tab to the one which matches the new index value.
 */
@property (nonatomic, assign) NSUInteger currentTabIndex;

/**
 *	This method will create TabSwipeNavigation
 *	@param viewController UIViewController : parent view controller
 *	@param names NSArray : name of each tabs
 *	@param tintColor UIColor : color of navigation and tabs
 *	@param delegate id : object where CarbonTabSwipeNavigation will delegate
 */
- (instancetype)createWithRootViewController:(UIViewController *)viewController tabNames:(NSArray *)names tintColor:(UIColor *)tintColor delegate:(id)delegate;

/**
 *  Navigation tranlucent
 *  @param translucent Navigation Bar translucent
 */
- (void)setTranslucent:(BOOL)translucent;

/**
 *  Change indicator height
 *  @param height Indicator height
 */
- (void)setIndicatorHeight:(CGFloat)height;

/**
 *	UIColor for tab in normal state
 *	@param color UIColor : color of normal state
 */
- (void)setNormalColor:(UIColor *)color;

/**
 *	UIFont and UIColor for tab in normal state
 *	@param color UIColor : color of normal state
 *	@param font UIFont : font of normal state
 */
- (void)setNormalColor:(UIColor *)color font:(UIFont *)font;

/**
 *	UIColor for tab in selected state
 *	@param color UIColor : color of selected state
 */
- (void)setSelectedColor:(UIColor *)color;

/**
 *	UIFont and UIColor for tab in selected state
 *	@param color UIColor : color of selected state
 *	@param font UIFont : font of selected state
 */
- (void)setSelectedColor:(UIColor *)color font:(UIFont *)font;

/**
 * Add 1 pixel shadow
 */
- (void)addShadow;

@end
