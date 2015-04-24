//
//  CarbonTabSwipeView.h
//  CarbonKitExamples
//
//  Created by Troy Stump on 4/23/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarbonTabSwipeView : UIView


@property (nonatomic, strong, readonly) UIScrollView *tabScrollView;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentController;
@property (nonatomic, strong, readonly) UIImageView *indicator;

@property (nonatomic, strong, readonly) NSLayoutConstraint *indicatorLeftConst;
@property (nonatomic, strong, readonly) NSLayoutConstraint *indicatorWidthConst;

// methods
- (instancetype)initWithSegmentTitles:(NSArray*)segmentTitles;


// styling

/**
 *  Customize the color for the tab title text.
 *
 *  @see UIAppearance
 */
@property (nonatomic, weak) UIColor *tabTitleTextColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color for the selected tab title text.
 *
 *  @see UIAppearance
 */
@property (nonatomic, weak) UIColor *tabTitleSelectedTextColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color for the tab title text.
 *
 *  @see UIAppearance
 */
@property (nonatomic, weak) UIColor *tabBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the color for the tab indicator.
 *
 *  @see UIAppearance
 */
@property (nonatomic, weak) UIColor *tabIndicatorColor UI_APPEARANCE_SELECTOR;

/**
 *  Customize the font for the tab title text.
 *
 *  @see UIAppearance
 */
@property (nonatomic, weak) UIFont *tabTitleTextFont UI_APPEARANCE_SELECTOR;

@end
