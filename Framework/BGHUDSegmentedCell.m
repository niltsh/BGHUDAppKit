//
//  BGHUDSegmentedCell.m
//  BGHUDAppKit
//
//  Created by BinaryGod on 7/1/08.
//  Copyright 2008 none. All rights reserved.
//

#import "BGHUDSegmentedCell.h"

@implementation BGHUDSegmentedCell

@synthesize themeKey;

-(id)init {
	
	self = [super init];
	
	if(self) {
		
		self.themeKey = @"gradientTheme";
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder: aDecoder];
	
	if(self) {
		
		if([aDecoder containsValueForKey: @"themeKey"]) {
			
			self.themeKey = [aDecoder decodeObjectForKey: @"themeKey"];
		} else {
			
			self.themeKey = @"gradientTheme";
		}
	}
	
	return self;
}

-(void)encodeWithCoder: (NSCoder *)coder {
	
	[super encodeWithCoder: coder];
	
	[coder encodeObject: self.themeKey forKey: @"themeKey"];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view {
	
	NSBezierPath *border;
	
	switch ([self segmentStyle]) {
			
		case NSSegmentStyleTexturedRounded:
			
			//Adjust frame for shadow
			frame.origin.x += 1.5;
			frame.origin.y += .5;
			frame.size.width -= 3;
			frame.size.height -= 3;
			
			border = [[NSBezierPath alloc] init];
			
			[border appendBezierPathWithRoundedRect: frame
											xRadius: 4.0 yRadius: 4.0];
			
			//Setup to Draw Border
			[NSGraphicsContext saveGraphicsState];
			
			//Set Shadow + Border Color
			[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] dropShadow] set];
			[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] strokeColor] set];
			
			//Draw Border + Shadow
			[border stroke];
			
			[NSGraphicsContext restoreGraphicsState];
			
			[border release];
			break;
	}
	
	int segCount = 0;
	
	while (segCount <= [self segmentCount] -1) {
	
		[self drawSegment: segCount inFrame: frame withView: view];
		segCount++;
	}
}

- (void)drawSegment:(int)segment inFrame:(NSRect)frame withView:(NSView *)view {
	
	//Calculate rect for this segment
	NSRect fillRect = [self rectForSegment: segment inFrame: frame];
	NSBezierPath *fillPath;
	
	switch ([self segmentStyle]) {
			
		case NSSegmentStyleTexturedRounded:
			
			if(segment == 0) {
				
				fillPath = [[NSBezierPath alloc] init];
				
				[fillPath appendBezierPathWithRoundedRect: fillRect xRadius: 3 yRadius: 3];
				
				//Setup our joining rect
				NSRect joinRect = fillRect;
				joinRect.origin.x += 4;
				joinRect.size.width -= 4;
				
				[fillPath appendBezierPathWithRect: joinRect];
				
			} else if (segment == ([self segmentCount] -1)) {
				
				fillPath = [[NSBezierPath alloc] init];
				
				[fillPath appendBezierPathWithRoundedRect: fillRect xRadius: 3 yRadius: 3];
				
				//Setup our joining rect
				NSRect joinRect = fillRect;
				joinRect.size.width -= 4;
				
				[fillPath appendBezierPathWithRect: joinRect];
				
			} else if (segment != 0 && segment != ([self segmentCount] -1)) {
			
				fillPath = [[NSBezierPath alloc] init];
				[fillPath appendBezierPathWithRect: fillRect];
			}
			
			if([self selectedSegment] == segment) {
				
				[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] highlightGradient] drawInBezierPath: fillPath angle: 90];
			} else {
				
				[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] normalGradient] drawInBezierPath: fillPath angle: 90];
			}
			
			[fillPath release];
			
			break;
			
	}
	
	//Draw Segment dividers ONLY if they are
	//inside segments
	if(segment != ([self segmentCount] -1)) {
		
		[[[[BGThemeManager keyedManager] themeForKey: self.themeKey] strokeColor] set];
		[NSBezierPath strokeLineFromPoint: NSMakePoint(fillRect.origin.x + fillRect.size.width , fillRect.origin.y)
								  toPoint: NSMakePoint(fillRect.origin.x + fillRect.size.width, fillRect.origin.y + fillRect.size.height)];
	}
}

-(NSRect)rectForSegment:(int)segment inFrame:(NSRect)frame {

	//Setup base values
	float x = frame.origin.x + .5;
	float y = frame.origin.y + .5;
	float w = [self widthForSegment: segment] + .5;
	float h = frame.size.height - 1;
	
	int segCount = 0;
	
	while (segCount < segment) {
		
		x += [self widthForSegment: segCount] + 1;
		
		if(segCount == 0 || segCount == ([self segmentCount] -1)) {
			
			x += 1;
		}
		
		if([self widthForSegment: segCount] == 0) {
			
			x += 12;
		}
		
		segCount++;
	}
	
	if(segment == 0 || segment == ([self segmentCount] -1)) {
		
		w += 1;
	}
	
	if(w == .5) {
		
		w += 12;
		[self setWidth: 12 forSegment: segment];
	}
	
	return NSMakeRect(x, y, w, h);
}

@end
