//
//  SNRHUDButtonCell.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-23.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDButtonCell.h"

#define SNRButtonBlackGradientBottomColor         [NSColor colorWithDeviceWhite:0.150 alpha:1.000]
#define SNRButtonBlackGradientTopColor            [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define SNRButtonBlackHighlightColor              [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRButtonBlueGradientBottomColor          [NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]
#define SNRButtonBlueGradientTopColor             [NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000]
#define SNRButtonBlueHighlightColor               [NSColor colorWithDeviceWhite:1.000 alpha:0.250]

#define SNRButtonTextFont                         [NSFont systemFontOfSize:11.f]
#define SNRButtonTextColor                        [NSColor whiteColor]
#define SNRButtonBlackTextShadowOffset            NSMakeSize(0.f, 1.f)
#define SNRButtonBlackTextShadowBlurRadius        1.f
#define SNRButtonBlackTextShadowColor             [NSColor blackColor]
#define SNRButtonBlueTextShadowOffset             NSMakeSize(0.f, -1.f)
#define SNRButtonBlueTextShadowBlurRadius         2.f
#define SNRButtonBlueTextShadowColor              [NSColor colorWithDeviceWhite:0.000 alpha:0.600]

#define SNRButtonDisabledAlpha                    0.7f
#define SNRButtonCornerRadius                     3.f
#define SNRButtonDropShadowColor                  [NSColor colorWithDeviceWhite:1.000 alpha:0.050]
#define SNRButtonDropShadowBlurRadius             1.f
#define SNRButtonDropShadowOffset                 NSMakeSize(0.f, -1.f)
#define SNRButtonBorderColor                      [NSColor blackColor]
#define SNRButtonHighlightOverlayColor            [NSColor colorWithDeviceWhite:0.000 alpha:0.300]

#define SNRButtonCheckboxTextOffset               3.f
#define SNRButtonCheckboxCheckmarkColor           [NSColor colorWithDeviceWhite:0.780 alpha:1.000]
#define SNRButtonCheckboxCheckmarkLeftOffset      4.f
#define SNRButtonCheckboxCheckmarkTopOffset       1.f
#define SNRButtonCheckboxCheckmarkShadowOffset    NSMakeSize(0.f, 0.f)
#define SNRButtonCheckboxCheckmarkShadowBlurRadius 3.f
#define SNRButtonCheckboxCheckmarkShadowColor     [NSColor colorWithDeviceWhite:0.000 alpha:0.750]
#define SNRButtonCheckboxCheckmarkLineWidth       2.f

static NSString* const SNRButtonReturnKeyEquivalent = @"\r";

@interface SNRHUDButtonCell ()
- (BOOL)snr_shouldDrawBlueButton;
- (void)snr_drawButtonBezelWithFrame:(NSRect)frame inView:(NSView*)controlView;
- (void)snr_drawCheckboxBezelWithFrame:(NSRect)frame inView:(NSView*)controlView;
- (NSRect)snr_drawButtonTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView;
- (NSRect)snr_drawCheckboxTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView;
- (NSBezierPath *)snr_checkmarkPathForRect:(NSRect)rect mixed:(BOOL)mixed;
@end

@implementation SNRHUDButtonCell {
    NSBezierPath *__bezelPath;
    NSButtonType __buttonType;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        __buttonType = (NSButtonType)[[self valueForKey:@"buttonType"] unsignedIntegerValue];
    }
    return self;
}

- (void)setButtonType:(NSButtonType)aType
{
    __buttonType = aType;
    [super setButtonType:aType];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (![self isEnabled]) {
        CGContextSetAlpha([[NSGraphicsContext currentContext] graphicsPort], SNRButtonDisabledAlpha);
    }
    [super drawWithFrame:cellFrame inView:controlView];
    if (__bezelPath && [self isHighlighted]) {
        [SNRButtonHighlightOverlayColor set];
        [__bezelPath fill];
    }
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    [self snr_drawButtonBezelWithFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    switch (__buttonType) {
        case NSSwitchButton:
            return [self snr_drawCheckboxTitle:title withFrame:frame inView:controlView];
            break;
        default:
            return [self snr_drawButtonTitle:title withFrame:frame inView:controlView];
            break;
    }
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if(self.bezelStyle == NSDisclosureBezelStyle)
    {
        [self snr_drawDisclosureWithFrame:cellFrame inView:controlView];
    }
    else
    {
        [super drawInteriorWithFrame:cellFrame inView:controlView];
    }
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
    if (__buttonType == NSSwitchButton)
    {
        [self snr_drawCheckboxBezelWithFrame:frame inView:controlView];
    }
    else if ([image isTemplate])
    {
        [super drawImage:image withFrame:frame inView:controlView];
    }
    else
    {
        NSRect imageBounds = NSZeroRect;
        imageBounds.size = image.size;
        [image drawInRect:frame fromRect:imageBounds operation:NSCompositeSourceOver fraction:1.0];
    }
}

- (void)snr_drawButtonBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    frame = NSInsetRect(frame, 0.5f, 0.5f);
    frame.size.height -= SNRButtonDropShadowBlurRadius;
    BOOL blue = [self snr_shouldDrawBlueButton];
    __bezelPath = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:SNRButtonCornerRadius yRadius:SNRButtonCornerRadius];
    NSGradient *gradientFill = [[NSGradient alloc] initWithStartingColor:blue ? SNRButtonBlueGradientBottomColor : SNRButtonBlackGradientBottomColor endingColor:blue ? SNRButtonBlueGradientTopColor : SNRButtonBlackGradientTopColor];
    // Draw the gradient fill
    [gradientFill drawInBezierPath:__bezelPath angle:270.f];
    // Draw the border and drop shadow
    [NSGraphicsContext saveGraphicsState];
    [SNRButtonBorderColor set];
    NSShadow *dropShadow = [NSShadow new];
    [dropShadow setShadowColor:SNRButtonDropShadowColor];
    [dropShadow setShadowBlurRadius:SNRButtonDropShadowBlurRadius];
    [dropShadow setShadowOffset:SNRButtonDropShadowOffset];
    [dropShadow set];
    [__bezelPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    // Draw the highlight line around the top edge of the pill
    // Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
    // Outset the height by 1px so that the line is drawn right below the border
    NSRect highlightRect = NSInsetRect(frame, -0.5f, 1.f);
    // Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
    highlightRect.size.height *= 2.f;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:SNRButtonCornerRadius yRadius:SNRButtonCornerRadius];
    [__bezelPath addClip];
    [blue ? SNRButtonBlueHighlightColor : SNRButtonBlackHighlightColor set];
    [highlightPath stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)snr_drawDisclosureWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    
    
    //// Frames
    //NSRect frame = NSMakeRect(69, 86, 19, 24);
    
    //// Subframes
    NSRect mixedStateFrame = NSMakeRect(NSMinX(frame) + floor((NSWidth(frame) - 9) * 0.50000 + 0.5), NSMinY(frame) + floor((NSHeight(frame) - 10) * 0.50000 + 0.5), 9, 10);
    NSRect offStateFrame = NSMakeRect(NSMinX(mixedStateFrame) + 1, NSMinY(mixedStateFrame), 8, 9);
    NSRect onStateFrame = NSMakeRect(NSMinX(mixedStateFrame), NSMinY(mixedStateFrame) + 1, 9, 8);
    
    [SNRButtonTextColor setFill];
    
    if (self.state == NSOffState) {
        //// OffState Drawing
        NSBezierPath* offStatePath = [NSBezierPath bezierPath];
        [offStatePath moveToPoint: NSMakePoint(NSMinX(offStateFrame), NSMinY(offStateFrame))];
        [offStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame) + 9, NSMinY(onStateFrame) + 3.5)];
        [offStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame) + 1, NSMinY(onStateFrame) + 8)];
        [offStatePath lineToPoint: NSMakePoint(NSMinX(offStateFrame), NSMinY(offStateFrame))];
        [offStatePath closePath];
        [offStatePath fill];
    }
    else if (self.state == NSMixedState)
    {
        //// MixedState Drawing
        NSBezierPath* mixedStatePath = [NSBezierPath bezierPath];
        [mixedStatePath moveToPoint: NSMakePoint(NSMinX(offStateFrame) + 5.5, NSMinY(offStateFrame) + 0.5)];
        [mixedStatePath lineToPoint: NSMakePoint(NSMinX(mixedStateFrame) + 8.5, NSMinY(mixedStateFrame) + 9.5)];
        [mixedStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame), NSMinY(onStateFrame) + 6)];
        [mixedStatePath lineToPoint: NSMakePoint(NSMinX(offStateFrame) + 5.5, NSMinY(offStateFrame) + 0.5)];
        [mixedStatePath closePath];
        [mixedStatePath fill];
    }
    else if (self.state == NSOnState)
    {
        //// OnState Drawing
        NSBezierPath* onStatePath = [NSBezierPath bezierPath];
        [onStatePath moveToPoint: NSMakePoint(NSMinX(onStateFrame), NSMinY(onStateFrame))];
        [onStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame) + 9, NSMinY(onStateFrame))];
        [onStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame) + 4.5, NSMinY(onStateFrame) + 8)];
        [onStatePath lineToPoint: NSMakePoint(NSMinX(onStateFrame), NSMinY(onStateFrame))];
        [onStatePath closePath];
        [onStatePath fill];
    }
}

- (void)snr_drawCheckboxBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    // At this time the checkbox uses the same style as the black button so we can use that method to draw the background
    frame.size.width -= 2.f;
    frame.size.height -= 1.f;
    [self snr_drawButtonBezelWithFrame:frame inView:controlView];
    // Draw the checkmark itself
    if ([self state] == NSOffState) { return; }
    NSBezierPath *path = [self snr_checkmarkPathForRect:frame mixed:[self state] == NSMixedState];
    [path setLineWidth:SNRButtonCheckboxCheckmarkLineWidth];
    [SNRButtonCheckboxCheckmarkColor set];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:SNRButtonCheckboxCheckmarkShadowColor];
    [shadow setShadowBlurRadius:SNRButtonCheckboxCheckmarkShadowBlurRadius];
    [shadow setShadowOffset:SNRButtonCheckboxCheckmarkShadowOffset];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (NSBezierPath *)snr_checkmarkPathForRect:(NSRect)rect mixed:(BOOL)mixed
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    if (mixed) {
        NSPoint left = NSMakePoint(rect.origin.x + SNRButtonCheckboxCheckmarkLeftOffset, round(NSMidY(rect)));
        NSPoint right = NSMakePoint(NSMaxX(rect) - SNRButtonCheckboxCheckmarkLeftOffset, left.y);
        [path moveToPoint:left];
        [path lineToPoint:right];
    } else {
        NSPoint top = NSMakePoint(NSMaxX(rect), rect.origin.y);
        NSPoint bottom = NSMakePoint(round(NSMidX(rect)), round(NSMidY(rect)) + SNRButtonCheckboxCheckmarkTopOffset);
        NSPoint left = NSMakePoint(rect.origin.x + SNRButtonCheckboxCheckmarkLeftOffset, round(bottom.y / 2.f));
        [path moveToPoint:top];
        [path lineToPoint:bottom];
        [path lineToPoint:left];
    }
    return path;
}

- (NSRect)snr_drawButtonTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    BOOL blue = [self snr_shouldDrawBlueButton];
    NSString *label = [title string];
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:blue ? SNRButtonBlueTextShadowOffset : SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:blue ? SNRButtonBlueTextShadowColor : SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:blue ? SNRButtonBlueTextShadowBlurRadius : SNRButtonBlackTextShadowBlurRadius];
    NSDictionary *attributes = @{NSFontAttributeName: SNRButtonTextFont, NSForegroundColorAttributeName: SNRButtonTextColor, NSShadowAttributeName: textShadow};
    NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
    NSSize labelSize = attrLabel.size;
    NSRect labelRect = NSMakeRect(NSMidX(frame) - (labelSize.width / 2.f), NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
    [attrLabel drawInRect:NSIntegralRect(labelRect)];
    return labelRect;
}

- (NSRect)snr_drawCheckboxTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSString *label = [title string];
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:SNRButtonBlackTextShadowBlurRadius];
    NSDictionary *attributes = @{NSFontAttributeName: SNRButtonTextFont, NSForegroundColorAttributeName: SNRButtonTextColor, NSShadowAttributeName: textShadow};
    NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
    NSSize labelSize = attrLabel.size;
    NSRect labelRect = NSMakeRect(frame.origin.x + SNRButtonCheckboxTextOffset, NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
    [attrLabel drawInRect:NSIntegralRect(labelRect)];
    return labelRect;
}

#pragma mark - Private

- (BOOL)snr_shouldDrawBlueButton
{
    return [[self keyEquivalent] isEqualToString:SNRButtonReturnKeyEquivalent] && (__buttonType != NSSwitchButton);
}
@end
