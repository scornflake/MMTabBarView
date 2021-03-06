//
//  MMOverflowPopUpButton.m
//  MMTabBarView
//
//  Created by John Pannell on 11/4/05.
//  Copyright 2005 Positive Spin Media. All rights reserved.
//

#import "MMOverflowPopUpButton.h"

#import "MMOverflowPopUpButtonCell.h"
// #import "MMTabBarView.h"

#define TIMER_INTERVAL 1.0 / 15.0
#define ANIMATION_STEP 0.033f

#define StaticImage(name) \
static NSImage* _static##name##Image() \
{ \
    static NSImage* image = nil; \
    if (!image) \
        image = [[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[MMOverflowPopUpButtonCell class]] pathForImageResource:@#name]]; \
    return image; \
}

@interface MMOverflowPopUpButton (/*Private*/)

@property (assign) CGFloat secondImageAlpha;

- (BOOL)isAnimating;
- (void)setIsAnimating:(BOOL)newState;

- (void)_startCellAnimationIfNeeded;
- (void)_startCellAnimation;
- (void)_stopCellAnimationIfNeeded;
- (void)_stopCellAnimation;

@end

@implementation MMOverflowPopUpButton

StaticImage(overflowImage)
StaticImage(overflowImagePressed)

@dynamic secondImageAlpha;

+ (Class)cellClass {
    return [MMOverflowPopUpButtonCell class];
}

- (id)initWithFrame:(NSRect)frameRect pullsDown:(BOOL)flag {
	if (self = [super initWithFrame:frameRect pullsDown:YES]) {
    
        _isAnimating = NO;
    
		[self setBezelStyle:NSRegularSquareBezelStyle];
		[self setBordered:NO];
		[self setTitle:@""];
		[self setPreferredEdge:NSMaxYEdge];
        
        [self setImage:_staticoverflowImageImage()];
//        [self setSecondImage:_staticoverflowImagePressedImage()];
        [self setAlternateImage:_staticoverflowImagePressedImage()];
        
        [self _startCellAnimationIfNeeded];
	}
	return self;
}


- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [super viewWillMoveToSuperview:newSuperview];
    
    [self _stopCellAnimationIfNeeded];
}

- (void)viewDidMoveToSuperview {

    [super viewDidMoveToSuperview];
    
    [self _startCellAnimationIfNeeded];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {

    [super viewWillMoveToWindow:newWindow];
    
    [self _stopCellAnimationIfNeeded];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    [self _startCellAnimationIfNeeded];
}

#pragma mark -
#pragma mark Accessors 

- (void)setHidden:(BOOL)flag {

    [super setHidden:flag];

    @synchronized (self) {
        if (flag)
            [self _stopCellAnimationIfNeeded];
        else
            [self _startCellAnimationIfNeeded];
    }
}

- (void)setFrame:(NSRect)frameRect {

    [super setFrame:frameRect];

    @synchronized (self) {
        if (NSEqualRects(NSZeroRect, frameRect))
            [self _stopCellAnimationIfNeeded];
        else
            [self _startCellAnimationIfNeeded];
    }
}

#pragma mark -
#pragma mark Interfacing Cell

- (NSImage *)secondImage {
    return [[self cell] secondImage];
}

- (void)setSecondImage:(NSImage *)anImage {

    [[self cell] setSecondImage:anImage];
    
    if (!anImage) {
        [self _stopCellAnimationIfNeeded];
    } else {
        [self _startCellAnimationIfNeeded];
    }
}

#pragma mark -
#pragma mark Animation

+ (id)defaultAnimationForKey:(NSString *)key {

    if ([key isEqualToString:@"isAnimating"]) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"secondImageAlpha"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        animation.duration = 1.0f;
        animation.autoreverses = YES;    
        animation.repeatCount = CGFLOAT_MAX;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        return animation;
    } else {
        return [super defaultAnimationForKey:key];
    }
}

/* currently unused
- (void)mouseDown:(NSEvent *)event {

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NSMenuDidEndTrackingNotification object:[self menu]];
	[self setNeedsDisplay:YES];
	[super mouseDown:event];
}

- (void)notificationReceived:(NSNotification *)notification {

	[self setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
*/

#pragma mark -
#pragma mark Bezel Drawing

- (MMCellBezelDrawingBlock)bezelDrawingBlock {
    return [[self cell] bezelDrawingBlock];
}

- (void)setBezelDrawingBlock:(MMCellBezelDrawingBlock)aBlock {
    [[self cell] setBezelDrawingBlock:aBlock];
}

#pragma mark -
#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
	}
	return self;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)isAnimating {
    return _isAnimating;
}

- (void)setIsAnimating:(BOOL)newState {
    _isAnimating = newState;
}

- (void)_startCellAnimationIfNeeded {

    if ([self window] == nil || [self isHidden] || NSEqualRects(NSZeroRect, [self frame]))
        return;

    if ([[self cell] secondImage] == nil)
        return;
    
    [self _startCellAnimation];
}

- (void)_startCellAnimation {
    [[self animator] setIsAnimating:YES];
}

- (void)_stopCellAnimationIfNeeded {

    if (_isAnimating)
        [self _stopCellAnimation];
}

- (void)_stopCellAnimation {

    [self setIsAnimating:NO];
}

- (CGFloat)secondImageAlpha {
    return [[self cell] secondImageAlpha];
}

- (void)setSecondImageAlpha:(CGFloat)value {
    [[self cell] setSecondImageAlpha:value];
    [self updateCell:[self cell]];
}

@end
