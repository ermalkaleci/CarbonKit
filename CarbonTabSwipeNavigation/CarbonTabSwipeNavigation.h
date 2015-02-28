//
//  CarbonTabSwipeNavigation.h
//  CarbonTabSwipeNavigation
//
//  Created by Ermal Kaleci on 08/02/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarbonTabSwipeNavigation;

/**
 *  Carbon Tab Swipe Delegate
 */
@protocol CarbonTabSwipeDelegate <NSObject>

@required
- (UIViewController *)tabSwipeNavigation:(CarbonTabSwipeNavigation *)tabSwipe viewControllerAtIndex:(NSUInteger)index;

@end

/**
 *  Carbon Tab Swipe Interface
 */
@interface CarbonTabSwipeNavigation : UIViewController

// methods
- (instancetype)createWithRootViewController:(UIViewController *)viewController tabNames:(NSArray *)names tintColor:(UIColor *)tintColor delegate:(id)delegate;

// properties
@property (nonatomic, weak) id<CarbonTabSwipeDelegate> delegate;

@end