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

#import "CarbonTabSwipeScrollView.h"

@implementation CarbonTabSwipeScrollView

- (instancetype)initWithItems:(NSArray *)items {
	self = [self init];
	if (self) {
		[self setItems:items];
	}
	return self;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		// Disable scroll indicators
		self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
	}
	return self;
}

- (void)setItems:(NSArray *)items {
	// Remove all subviews if it exists.
	for (UIView *view in self.subviews) {
		[view removeFromSuperview];
	}
	
	// Create Carbon segmented control
	_carbonSegmentedControl = [[CarbonTabSwipeSegmentedControl alloc] initWithItems:items];
	[self addSubview:_carbonSegmentedControl];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	// Validate `_carbonSegmentedControl` is exist.
	if (_carbonSegmentedControl == nil) { return; }
	
	// Set segmented control height equal to scroll view height
	CGRect segmentRect = _carbonSegmentedControl.frame;
	segmentRect.size.height = CGRectGetHeight(self.frame);
	_carbonSegmentedControl.frame = segmentRect;
	
	// Min content width equal to scroll view width
	CGFloat contentWidth = [_carbonSegmentedControl getWidth];
	if (contentWidth < CGRectGetWidth(self.frame)) {
		contentWidth = CGRectGetWidth(self.frame) + 1;
	}
	
	// Scroll view content size
	self.contentSize = CGSizeMake(contentWidth, CGRectGetHeight(self.frame));
}

@end
