//
//  CarbonSwipeRefresh.h
//  CarbonKit
//
//  Created by Ermal Kaleci on 23/03/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarbonSwipeRefresh : UIControl

@property (nonatomic, retain, setter=setColors:) NSArray *colors;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)endRefreshing;

// in case when navigation bar is not tranparent set 0
- (void)setMarginTop:(CGFloat)topMargin;

@end
