//
//  CarbonTabSwipeView.m
//  CarbonKitExamples
//
//  Created by Troy Stump on 4/23/15.
//  Copyright (c) 2015 Ermal Kaleci. All rights reserved.
//

#import "CarbonTabSwipeView.h"


@interface CarbonTabSwipeView ()

@property (nonatomic, strong) NSArray *segmentTitles;
@property (nonatomic, strong) NSLayoutConstraint *bottomBorderConstraint;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation CarbonTabSwipeView

@synthesize tabBackgroundColor = _tabBackgroundColor;
@synthesize tabIndicatorColor = _tabIndicatorColor;
@synthesize tabTitleTextColor = _tabTitleTextColor;
@synthesize tabTitleSelectedTextColor = _tabTitleSelectedTextColor;
@synthesize tabTitleTextFont = _tabTitleTextFont;


- (instancetype)init
{
	if (self = [super initWithFrame:CGRectZero]) {
		[self commonInit];
	}
	
	return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}
	
	return self;
}

- (instancetype)initWithSegmentTitles:(NSArray*)segmentTitles
{
	if (self = [super initWithFrame:CGRectZero]) {
		_segmentTitles = segmentTitles;
		
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit
{
	self.backgroundColor = [UIColor blackColor];
	// create segment control
	_segmentController = [[UISegmentedControl alloc] initWithItems:_segmentTitles];
	[_segmentController setTranslatesAutoresizingMaskIntoConstraints:NO];
	//_segmentController.backgroundColor = [UIColor orangeColor];
	[_segmentController setTintColor:[UIColor clearColor]];
	[_segmentController setDividerImage:[UIImage new] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[_segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:self.tabTitleTextColor,
												 NSFontAttributeName:self.tabTitleTextFont}
									  forState:UIControlStateNormal];
	[_segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:self.tabTitleSelectedTextColor,
												 NSFontAttributeName:self.tabTitleTextFont}
									  forState:UIControlStateSelected];
	
	
	// create scrollview
	_tabScrollView = [[UIScrollView alloc] init];
	_tabScrollView.backgroundColor = self.tabBackgroundColor;
	[_tabScrollView setShowsHorizontalScrollIndicator:NO];
	[_tabScrollView setShowsVerticalScrollIndicator:NO];
	[_tabScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	
	// create indicator
	_indicator = [[UIImageView alloc] init];
	[_indicator setTranslatesAutoresizingMaskIntoConstraints:NO];
	_indicator.backgroundColor = self.tabIndicatorColor;
	
	
	// create container view for scroll view
	_containerView = [[UIView alloc] init];
	[_containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
	
	[self addSubview:_tabScrollView];
	[_tabScrollView addSubview:_containerView];
	[_containerView addSubview:_segmentController];
	[_segmentController addSubview:_indicator];
	
	
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_tabScrollView, _containerView, _segmentController, _indicator);
	
	[_segmentController addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_indicator(==3)]|" options:0 metrics:nil views:viewsDictionary]];
	[_segmentController addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_indicator]" options:0 metrics:nil views:viewsDictionary]];
	
	[_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_segmentController]|" options:0 metrics:nil views:viewsDictionary]];
	[_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentController]|" options:0 metrics:nil views:viewsDictionary]];
	
	[_tabScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerView]|" options:0 metrics:nil views:viewsDictionary]];
	[_tabScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerView]|" options:0 metrics:nil views:viewsDictionary]];
	
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tabScrollView]" options:0 metrics:nil views:viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tabScrollView]|" options:0 metrics:nil views:viewsDictionary]];
	
	
	// subtract the top and bottom border that exists no matter what on UISegmentedControls
	NSLayoutConstraint *containerViewHeightConst = [NSLayoutConstraint constraintWithItem:_containerView
																				attribute:NSLayoutAttributeHeight
																				relatedBy:NSLayoutRelationEqual
																				   toItem:_tabScrollView
																				attribute:NSLayoutAttributeHeight
																			   multiplier:1.0
																				 constant:0.0f];
	[self addConstraint:containerViewHeightConst];
	
	
	// 1px bottom border to mimic the illusion of being integrated below a navigation bar
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self
													 attribute:NSLayoutAttributeBottom
													 relatedBy:NSLayoutRelationEqual
														toItem:_tabScrollView
													 attribute:NSLayoutAttributeBottom
													multiplier:1.0
													  constant:(1.0f/[UIScreen mainScreen].scale)]];
	
	_indicatorLeftConst = [NSLayoutConstraint constraintWithItem:_indicator
													   attribute:NSLayoutAttributeLeading
													   relatedBy:NSLayoutRelationEqual
														  toItem:_indicator.superview
													   attribute:NSLayoutAttributeLeading
													  multiplier:1
														constant:0];
	
	_indicatorWidthConst = [NSLayoutConstraint constraintWithItem:_indicator
														attribute:NSLayoutAttributeWidth
														relatedBy:NSLayoutRelationEqual
														   toItem:nil
														attribute:NSLayoutAttributeNotAnAttribute
													   multiplier:1.0f
														 constant:0];
	
	[_segmentController addConstraint:_indicatorLeftConst];
	[_segmentController addConstraint:_indicatorWidthConst];
	
	_segmentControllerWidthConst = [NSLayoutConstraint constraintWithItem:_segmentController
																attribute:NSLayoutAttributeWidth
																relatedBy:NSLayoutRelationEqual
																   toItem:nil
																attribute:NSLayoutAttributeNotAnAttribute
															   multiplier:0
																 constant:0];
	
	[_containerView addConstraint:_segmentControllerWidthConst];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.tabScrollView.contentInset = UIEdgeInsetsZero;
	
	[self.tabScrollView layoutIfNeeded];
	
	// UISegmentedControls do not deal well with auto layout and their frame height
	// sync the actual frame height to match the autolayout constraint
	self.segmentController.frame = CGRectMake(self.segmentController.frame.origin.x, self.segmentController.frame.origin.y, self.segmentController.frame.size.width, CGRectGetHeight(self.containerView.frame));
}

#pragma mark - Styling
- (UIColor *)tabBackgroundColor
{
	if (!_tabBackgroundColor) {
		_tabBackgroundColor = [[[self class] appearance] tabBackgroundColor];
	}
	
	return _tabBackgroundColor ? : [UIColor whiteColor];
}

- (UIColor *)tabIndicatorColor
{
	if (!_tabIndicatorColor) {
		_tabIndicatorColor = [[[self class] appearance] tabIndicatorColor];
	}
	
	return _tabIndicatorColor ? : [UIColor blackColor];
}

- (UIColor *)tabTitleTextColor
{
	if (!_tabTitleTextColor) {
		_tabTitleTextColor = [[[self class] appearance] tabTitleTextColor];
	}
	
	return _tabTitleTextColor ? : [UIColor lightGrayColor];
}

- (UIColor *)tabTitleSelectedTextColor
{
	if (!_tabTitleSelectedTextColor) {
		_tabTitleSelectedTextColor = [[[self class] appearance] tabTitleSelectedTextColor];
	}
	
	return _tabTitleSelectedTextColor ? : [UIColor darkGrayColor];
}

- (UIFont *)tabTitleTextFont
{
	if (!_tabTitleTextFont) {
		_tabTitleTextFont = [[[self class] appearance] tabTitleTextFont];
	}
	
	// default system font
	return _tabTitleTextFont ? : [UIFont systemFontOfSize:17.0f];
}

- (void)setTabBackgroundColor:(UIColor *)tabBackgroundColor
{
	if (![_tabBackgroundColor isEqual:tabBackgroundColor]) {
		_tabBackgroundColor = tabBackgroundColor;
		
		self.tabScrollView.backgroundColor = _tabBackgroundColor;
	}
}

- (void)setTabIndicatorColor:(UIColor *)tabIndicatorColor
{
	if (![_tabIndicatorColor isEqual:tabIndicatorColor]) {
		_tabIndicatorColor = tabIndicatorColor;
		
		self.indicator.backgroundColor = _tabIndicatorColor;
	}
}

- (void)setTabTitleTextColor:(UIColor *)tabTitleTextColor
{
	if (![_tabTitleTextColor isEqual:tabTitleTextColor]) {
		_tabTitleTextColor = tabTitleTextColor;
		
		[self.segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:_tabTitleTextColor, NSFontAttributeName:self.tabTitleTextFont} forState:UIControlStateNormal];
	}
}

- (void)setTabTitleSelectedTextColor:(UIColor *)tabTitleSelectedTextColor
{
	if (![_tabTitleSelectedTextColor isEqual:tabTitleSelectedTextColor]) {
		_tabTitleSelectedTextColor = tabTitleSelectedTextColor;
		
		[self.segmentController setTitleTextAttributes:@{NSForegroundColorAttributeName:_tabTitleSelectedTextColor, NSFontAttributeName:self.tabTitleTextFont} forState:UIControlStateSelected];
	}
}

- (void)setTabTitleTextFont:(UIFont *)tabTitleTextFont
{
	if (![_tabTitleTextFont isEqual:tabTitleTextFont]) {
		_tabTitleTextFont = tabTitleTextFont;
		
		[self.segmentController setTitleTextAttributes:@{NSFontAttributeName:_tabTitleTextFont, NSForegroundColorAttributeName:self.tabTitleTextColor} forState:UIControlStateNormal];
		[self.segmentController setTitleTextAttributes:@{NSFontAttributeName:_tabTitleTextFont, NSForegroundColorAttributeName:self.tabTitleSelectedTextColor} forState:UIControlStateSelected];
	}
}

+ (BOOL)requiresConstraintBasedLayout {
	return YES;
}

@end
