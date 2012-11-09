//
//  SNRHUDPopUpButtonCell.m
//  RailsAssistant
//
//  Created by Daniel Brooker on 9/11/12.
//  Copyright (c) 2012 Nocturnal Code Limited. All rights reserved.
//

#import "SNRHUDPopUpButtonCell.h"

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

@implementation SNRHUDPopUpButtonCell
{
    NSBezierPath *__bezelPath;
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    [self snr_drawButtonBezelWithFrame:frame inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    return [self snr_drawButtonTitle:title withFrame:frame inView:controlView];
}

- (NSRect)snr_drawButtonTitle:(NSAttributedString*)title withFrame:(NSRect)frame inView:(NSView*)controlView
{
    BOOL blue = NO;
    NSString *label = [title string];
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:blue ? SNRButtonBlueTextShadowOffset : SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:blue ? SNRButtonBlueTextShadowColor : SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:blue ? SNRButtonBlueTextShadowBlurRadius : SNRButtonBlackTextShadowBlurRadius];
    NSDictionary *attributes = @{NSFontAttributeName: SNRButtonTextFont, NSForegroundColorAttributeName: SNRButtonTextColor, NSShadowAttributeName: textShadow};
    NSAttributedString *attrLabel = [[NSAttributedString alloc] initWithString:label attributes:attributes];
    NSSize labelSize = attrLabel.size;
    NSRect labelRect = NSMakeRect(NSMinX(frame), NSMidY(frame) - (labelSize.height / 2.f), labelSize.width, labelSize.height);
    [attrLabel drawInRect:NSIntegralRect(labelRect)];
    return labelRect;
}

- (void)snr_drawButtonBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    frame = NSInsetRect(frame, 0.5f, 0.5f);
    frame.size.height -= SNRButtonDropShadowBlurRadius;
    BOOL blue = NO;
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
    
    NSPopUpArrowPosition position = [self arrowPosition];
    if(position != NSPopUpNoArrow)
    {
        CGFloat yPos = position == NSPopUpArrowAtCenter ? NSMidY(frame) : NSMidY(frame);
        
        if(self.pullsDown)
            [self snr_drawPullDownArrowsInFrame:NSMakeRect(NSMaxX(frame)- 15.f, yPos - (5.f/2.f), 7.f, 5.f)];
        else
            [self snr_drawPopUpArrowsInFrame:NSMakeRect(NSMaxX(frame)- 15.f, yPos - (8.f/2.f), 5.f, 8.f)];
            
    }
}

- (void)snr_drawPullDownArrowsInFrame:(NSRect)frame
{
    BOOL blue = NO;
    
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:blue ? SNRButtonBlueTextShadowOffset : SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:blue ? SNRButtonBlueTextShadowColor : SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:blue ? SNRButtonBlueTextShadowBlurRadius : SNRButtonBlackTextShadowBlurRadius];
    [textShadow set];
    
    NSBezierPath* downPath = [NSBezierPath bezierPath];
    [downPath moveToPoint: NSMakePoint(NSMinX(frame), NSMinY(frame))];
    [downPath lineToPoint: NSMakePoint(NSMinX(frame) + 7, NSMinY(frame))];
    [downPath lineToPoint: NSMakePoint(NSMinX(frame) + 3.5, NSMinY(frame) + 5)];
    [downPath lineToPoint: NSMakePoint(NSMinX(frame), NSMinY(frame))];
    [downPath closePath];
    [SNRButtonCheckboxCheckmarkColor setFill];
    [downPath fill];
}

- (void)snr_drawPopUpArrowsInFrame:(NSRect)frame
{
    BOOL blue = NO;
    
    NSShadow *textShadow = [NSShadow new];
    [textShadow setShadowOffset:blue ? SNRButtonBlueTextShadowOffset : SNRButtonBlackTextShadowOffset];
    [textShadow setShadowColor:blue ? SNRButtonBlueTextShadowColor : SNRButtonBlackTextShadowColor];
    [textShadow setShadowBlurRadius:blue ? SNRButtonBlueTextShadowBlurRadius : SNRButtonBlackTextShadowBlurRadius];
    [textShadow set];
    
    NSBezierPath* bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint: NSMakePoint(NSMinX(frame) + 0.5, NSMinY(frame) + 3)];
    [bezierPath lineToPoint: NSMakePoint(NSMinX(frame) + 2.5, NSMinY(frame))];
    [bezierPath lineToPoint: NSMakePoint(NSMinX(frame) + 4.5, NSMinY(frame) + 3)];
    [bezierPath lineToPoint: NSMakePoint(NSMinX(frame) + 0.5, NSMinY(frame) + 3)];
    [bezierPath closePath];
    [SNRButtonCheckboxCheckmarkColor setFill];
    [bezierPath fill];
    
    NSBezierPath* bezier3Path = [NSBezierPath bezierPath];
    [bezier3Path moveToPoint: NSMakePoint(NSMinX(frame) + 0.5, NSMinY(frame) + 5)];
    [bezier3Path lineToPoint: NSMakePoint(NSMinX(frame) + 2.5, NSMinY(frame) + 8)];
    [bezier3Path lineToPoint: NSMakePoint(NSMinX(frame) + 4.5, NSMinY(frame) + 5)];
    [bezier3Path lineToPoint: NSMakePoint(NSMinX(frame) + 0.5, NSMinY(frame) + 5)];
    [bezier3Path closePath];
    [SNRButtonCheckboxCheckmarkColor setFill];
    [bezier3Path fill];
}

@end
