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

#import "CarbonTabSwipeSegmentedControl.h"

@interface CarbonTabSwipeSegmentedControl()
@end

@implementation CarbonTabSwipeSegmentedControl

- (instancetype)initWithItems:(NSArray *)items {
	self = [super initWithItems:items];
	if (self) {
		
		self.indicatorHeight = 3;
		self.selectedSegmentIndex = 0;
		self.apportionsSegmentWidthsByContent = YES;
		
		// Create indicator
		self.indicator = [UIImageView new];
		self.indicator.backgroundColor = self.tintColor;
		self.indicator.autoresizingMask = UIViewAutoresizingNone;
		[self addSubview:self.indicator];
		
		// Custimize segmented control
		[self setTitleTextAttributes:@{
				NSForegroundColorAttributeName : [self.tintColor colorWithAlphaComponent:0.8],
				NSFontAttributeName	: [UIFont boldSystemFontOfSize:14]
			} forState:UIControlStateNormal];
		[self setTitleTextAttributes:@{
				NSForegroundColorAttributeName : self.tintColor,
				NSFontAttributeName	: [UIFont boldSystemFontOfSize:14]
			} forState:UIControlStateSelected];
		
		// Disable tint color and divider image
		[self setTintColor:[UIColor clearColor]];
		[self setDividerImage:[UIImage new]
		  forLeftSegmentState:UIControlStateNormal
			rightSegmentState:UIControlStateNormal
				   barMetrics:UIBarMetricsDefault];
		
		// Fix indicator frame
		if (items) {
			self.indicatorMinX = [self getMinXForSegmentAtIndex:self.selectedSegmentIndex];
			self.indicatorWidth = [self getWidthForSegmentAtIndex:self.selectedSegmentIndex];
			[self updateIndicatorWithAnimation:NO];
		}
		
		[self addTarget:self
				 action:@selector(segmentedTapped:)
	   forControlEvents:UIControlEventValueChanged];

	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	// Add extra width to each segment and calculate the segment width
	CGFloat totalWidth = 0;
	for (UIView *segment in self.segments) {
		CGFloat width = [self getWidthForSegmentAtIndex:[self.segments indexOfObject:segment]];
		CGRect segmentRect = segment.frame;
		segmentRect.origin.x = totalWidth;
		segmentRect.size.width = width + _tabExtraWidth;
		segment.frame = segmentRect;
		totalWidth += segmentRect.size.width;
	}
	
	// Set the width of UISegmentedControl to fit all segments
	rect.size.width = totalWidth;
	self.frame = rect;
	
	// Change images tint
	[self syncImageTintColor];
}

- (void)didChangeValueForKey:(NSString *)key {
	if ([key isEqualToString:@"selectedSegmentIndex"]) {
		[self syncImageTintColor];
	}
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
	[super setTitleTextAttributes:attributes forState:state];
	
	if (state == UIControlStateNormal) {
		[self setImageNormalColor:attributes[NSForegroundColorAttributeName]];
	} else if (state == UIControlStateSelected) {
		[self setImageSelectedColor:attributes[NSForegroundColorAttributeName]];
	}
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
	[super setSelectedSegmentIndex:selectedSegmentIndex];
	[self syncImageTintColor];
}

- (void)setImageNormalColor:(UIColor *)normalColor {
	_imageNormalColor = normalColor;
	[self syncImageTintColor];
}

- (void)setImageSelectedColor:(UIColor *)selectedColor {
	_imageSelectedColor = selectedColor;
	[self syncImageTintColor];
}

- (void)syncImageTintColor {
	for (UIView *segment in self.segments) {
		for (UIView *subView in segment.subviews) {
			if ([subView isKindOfClass:[UIImageView class]]) {
				if ([self.segments indexOfObject:segment] == self.selectedSegmentIndex) {
					subView.tintColor = _imageSelectedColor;
				} else {
					subView.tintColor = _imageNormalColor;
				}
			}
		}
	}
}

#pragma mark - Properties

- (NSArray *)segments {
	return [self valueForKey:@"_segments"];
}

- (UIView *)getSelectedSegment {
	return self.segments[self.selectedSegmentIndex];
}

- (CGFloat)getMinXForSegmentAtIndex:(NSUInteger)index {
	return CGRectGetMinX(((UIView *)self.segments[index]).frame);
}

- (CGFloat)getWidthForSegmentAtIndex:(NSUInteger)index {
	return CGRectGetWidth(((UIView *)self.segments[index]).frame);
}

- (CGFloat)getWidth {
	CGFloat width = 0;
	for (UIView *segment in self.segments) {
		width += CGRectGetWidth(segment.frame);
	}
	return width;
}

#pragma mark - Actions

- (void)segmentedTapped:(id)sender {
	self.indicatorMinX = [self getMinXForSegmentAtIndex:self.selectedSegmentIndex];
	self.indicatorWidth = [self getWidthForSegmentAtIndex:self.selectedSegmentIndex];
	[self updateIndicatorWithAnimation:YES];
}

- (void)updateIndicatorWithAnimation:(BOOL)animation {
	[UIView animateWithDuration:animation ? 0.3 : 0 animations:^{
		CGRect rect = self.indicator.frame;
		rect.origin.x = self.indicatorMinX;
		rect.origin.y =
		self.indicatorPosition == IndicatorPositionBottom
		? CGRectGetHeight(self.frame) - self.indicatorHeight
		: 0;
		rect.size.width = self.indicatorWidth;
		rect.size.height = self.indicatorHeight;
		self.indicator.frame = rect;
	}];
}

@end
