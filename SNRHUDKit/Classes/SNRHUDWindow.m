//
//  SNRHUDWindow.m
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-22.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import "SNRHUDWindow.h"
#import "NSBezierPath+MCAdditions.h"

#define SNRWindowTitlebarHeight         22.f
#define SNRWindowBorderColor            [NSColor blackColor]
#define SNRWindowTopColor               [NSColor colorWithDeviceWhite:0.240 alpha:0.960]
#define SNRWindowBottomColor            [NSColor colorWithDeviceWhite:0.150 alpha:0.960]
#define SNRWindowHighlightColor         [NSColor colorWithDeviceWhite:1.000 alpha:0.200]
#define SNRWindowCornerRadius           5.f

#define SNRWindowTitleFont              [NSFont systemFontOfSize:11.f]
#define SNRWindowTitleColor             [NSColor colorWithDeviceWhite:0.700 alpha:1.000]
#define SNRWindowTitleShadowOffset      NSMakeSize(0.f, 1.f)
#define SNRWindowTitleShadowBlurRadius  1.f
#define SNRWindowTitleShadowColor       [NSColor blackColor]

#define SNRWindowButtonSize             NSMakeSize(14.f, 16.f)
#define SNRWindowButtonEdgeMargin       5.f
#define SNRWindowButtonBorderColor      [NSColor colorWithDeviceWhite:0.040 alpha:1.000]
#define SNRWindowButtonGradientBottomColor  [NSColor colorWithDeviceWhite:0.070 alpha:1.000]
#define SNRWindowButtonGradientTopColor     [NSColor colorWithDeviceWhite:0.220 alpha:1.000]
#define SNRWindowButtonDropShadowColor  [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define SNRWindowButtonCrossColor       [NSColor colorWithDeviceWhite:0.450 alpha:1.000]
#define SNRWindowButtonCrossInset       0.1f
#define SNRWindowButtonHighlightOverlayColor [NSColor colorWithDeviceWhite:0.000 alpha:0.300]
#define SNRWindowButtonInnerShadowColor [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define SNRWindowButtonInnerShadowOffset NSMakeSize(0.f, 0.f)
#define SNRWindowButtonInnerShadowBlurRadius    1.f

@interface SNRHUDWindow ()

- (BOOL)windowShouldClose;
- (void)windowWillClose;

@end

@implementation SNRHUDWindow {
    NSView *__customContentView;
}

@dynamic floating;
@synthesize transparency;
@synthesize drawsKeyLine;
@synthesize hasTitleBar = _hasTitleBar;
@synthesize closable;
@synthesize minaturizable;
@synthesize zoomable;
@synthesize trafficLightHover;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
    if ((self=[super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask|NSResizableWindowMask|NSTexturedBackgroundWindowMask backing:bufferingType defer:deferCreation])) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        
        self.closable = ((windowStyle & NSClosableWindowMask) == NSClosableWindowMask);
        self.minaturizable = ((windowStyle & NSMiniaturizableWindowMask) == NSMiniaturizableWindowMask);
        self.zoomable = ((windowStyle & NSResizableWindowMask) == NSResizableWindowMask);
        
        self.floating = NO;
        self.hasTitleBar = ((windowStyle & NSTitledWindowMask) == NSTitledWindowMask);
        self.drawsKeyLine = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTrafficLights) name:NSWindowDidResizeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTrafficLights) name:NSWindowDidMoveNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayWindowAndTitlebar) name:NSWindowDidResignKeyNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayWindowAndTitlebar) name:NSWindowDidBecomeKeyNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayWindowAndTitlebar) name:NSApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_displayWindowAndTitlebar) name:NSApplicationDidResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    closeButton = nil;
    minimizeButton = nil;
    zoomButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_displayWindowAndTitlebar
{
    // Redraw the window and titlebar
    [titleBarView setNeedsDisplay:YES];
    [self.contentView setNeedsDisplay:YES];
}

- (void)_updateTrafficLights
{
    if(trafficLight != 0)
        [titleBarView removeTrackingRect:trafficLight];
        
    NSRect bounds = titleBarView.bounds;
    bounds.size.width = 60;
    trafficLight = [titleBarView addTrackingRect:bounds owner:self userData:NULL assumeInside:NO];
}

- (void)setDrawsKeyLine:(BOOL)value
{
    [self willChangeValueForKey:@"drawsKeyLine"];
    drawsKeyLine = value;
    [self didChangeValueForKey:@"drawsKeyLine"];
    
    SNRHUDWindowFrameView *frameView = (SNRHUDWindowFrameView *)[super contentView];
    [frameView setNeedsDisplay:YES];
}

- (void)setHasTitleBar:(BOOL)value
{
    [self willChangeValueForKey:@"hasTitleBar"];
    _hasTitleBar = value;
    [self didChangeValueForKey:@"hasTitleBar"];
    
    titleBarView.alphaValue = value ? 1.0 : 0.0;
    
    //SNRHUDWindowFrameView *frameView = (SNRHUDWindowFrameView *)[super contentView];
    NSRect bounds = [self frame];
    [__customContentView setFrame:[self contentRectForFrameRect:bounds]];
    //[frameView setNeedsDisplay:YES];
}

- (void)setClosable:(BOOL)value
{
    [self willChangeValueForKey:@"closable"];
    closable = value;
    [self didChangeValueForKey:@"closable"];
    
    [closeButton setEnabled:value];
}

- (void)setMinaturizable:(BOOL)value
{
    [self willChangeValueForKey:@"minaturizable"];
    minaturizable = value;
    [self didChangeValueForKey:@"minaturizable"];
    
    [minimizeButton setEnabled:value];
}

- (void)setZoomable:(BOOL)value
{
    [self willChangeValueForKey:@"zoomable"];
    zoomable = value;
    [self didChangeValueForKey:@"zoomable"];
    
    [zoomButton setEnabled:value];
}

- (void)setFloating:(BOOL)floating
{
    [self setLevel:floating?NSFloatingWindowLevel:NSNormalWindowLevel];
}

- (BOOL)floating
{
    return self.level == NSFloatingWindowLevel;
}

- (NSRect)contentRectForFrameRect:(NSRect)windowFrame
{
    windowFrame.origin = NSZeroPoint;
    windowFrame.size.height -= self.hasTitleBar ? SNRWindowTitlebarHeight : 0;
    return windowFrame;
}

+ (NSRect)frameRectForContentRect:(NSRect)windowContentRect
                        styleMask:(NSUInteger)windowStyle
{
    windowContentRect.size.height += SNRWindowTitlebarHeight;
    return windowContentRect;
}

- (NSRect)frameRectForContentRect:(NSRect)windowContent
{
    windowContent.size.height += SNRWindowTitlebarHeight;
    return windowContent;
}

+ (Class)frameViewClass
{
    return [SNRHUDWindowFrameView class];
}

- (void)setContentView:(NSView *)aView
{
    if ([__customContentView isEqualTo:aView])
        return;
    
    NSRect bounds = [self frame];
    bounds.origin = NSZeroPoint;
    SNRHUDWindowFrameView *frameView = [super contentView];
    if (!frameView) 
    {
        frameView = [[[[self class] frameViewClass] alloc] initWithFrame:bounds];
        
        NSRect titleBarRect = bounds;
        titleBarRect.size.height =  SNRWindowTitlebarHeight;
        titleBarRect.origin.y = frameView.frame.size.height-SNRWindowTitlebarHeight;
        titleBarView = [[RAWindowTitleBarView alloc] initWithFrame:titleBarRect];
        titleBarView.alphaValue = self.hasTitleBar?1.0:0.0;
        titleBarView.autoresizingMask = NSViewMinYMargin | NSViewWidthSizable;
        [frameView addSubview:titleBarView];
        
        // Set the frame of the window buttons
        NSRect closeFrame = CGRectMake(7,0, 14, 16);
        NSRect minimizeFrame = closeFrame;
        minimizeFrame.origin.x += closeFrame.size.width + 6;
        NSRect zoomFrame = minimizeFrame;
        zoomFrame.origin.x += closeFrame.size.width + 6;

        closeButton = [[NSButton alloc] initWithFrame:closeFrame];
        [closeButton setCell:[[RACloseButtonCell alloc] init]];
        [closeButton setButtonType:NSMomentaryChangeButton];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(performClose:)];
        [closeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
        [closeButton.cell setDelegate:self];
        [closeButton setEnabled:closable];
        [titleBarView addSubview:closeButton];

        minimizeButton = [[NSButton alloc] initWithFrame:minimizeFrame];
        [minimizeButton setCell:[[RAMinimizeButtonCell alloc] init]];
        [minimizeButton setButtonType:NSMomentaryChangeButton];
        [minimizeButton setTarget:self];
        [minimizeButton setAction:@selector(miniaturize:)];
        [minimizeButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
        [minimizeButton.cell setDelegate:self];
        [minimizeButton setEnabled:minaturizable];
        [titleBarView addSubview:minimizeButton];

    
        zoomButton = [[NSButton alloc] initWithFrame:zoomFrame];
        [zoomButton setCell:[[RAZoomButtonCell alloc] init]];
        [zoomButton setButtonType:NSMomentaryChangeButton];
        [zoomButton setTarget:self];
        [zoomButton setAction:@selector(zoom:)];
        [zoomButton setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
        [zoomButton.cell setDelegate:self];
        [zoomButton setEnabled:zoomable];
        [titleBarView addSubview:zoomButton];
        
        [super setContentView:frameView];
    }
    if (__customContentView) {
        [__customContentView removeFromSuperview];
    }
    __customContentView = aView;
    [__customContentView setFrame:[self contentRectForFrameRect:bounds]];
    [__customContentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [frameView addSubview:__customContentView];
    
    [self _updateTrafficLights];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.trafficLightHover = YES;
    [titleBarView setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.trafficLightHover = NO;
    [titleBarView setNeedsDisplay:YES];
}

- (NSView *)contentView
{
    return __customContentView;
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    [[super contentView] setNeedsDisplay:YES];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)performClose:(id)sender
{
    BOOL canClose = YES;
    if([self.delegate respondsToSelector:@selector(windowShouldClose:)])
        canClose = [self.delegate windowShouldClose:nil];
    else if([self respondsToSelector:@selector(windowShouldClose)])
        canClose = [self windowShouldClose];
    
    if(canClose)
    {
//        if([self.delegate respondsToSelector:@selector(windowWillClose:)])
//            [self.delegate windowWillClose:nil];
//        else if([self respondsToSelector:@selector(windowWillClose)])
//            [self windowWillClose];
        [self close];
    }
}

#pragma mark - Window Stuff

- (BOOL)windowShouldClose
{
    return YES;
}

- (void)windowWillClose
{
}

@end

@implementation SNRHUDWindowFrameView

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect drawingRect = NSInsetRect(self.bounds, 0.5f, 0.5f);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:SNRWindowCornerRadius yRadius:SNRWindowCornerRadius];
    [NSGraphicsContext saveGraphicsState];
    [path addClip];
    
    BOOL titleBar = [[self window] hasTitleBar];
    
    if(titleBar)
    {
        NSRect titleBarRect = NSMakeRect(0.f, NSMaxY(self.bounds) - SNRWindowTitlebarHeight, self.bounds.size.width, SNRWindowTitlebarHeight);
        if([self.window isKeyWindow])
        {
            // Fill in the title bar with a gradient background
            NSGradient *titlebarGradient = [[NSGradient alloc] initWithStartingColor:SNRWindowBottomColor endingColor:SNRWindowTopColor];
            [titlebarGradient drawInRect:titleBarRect angle:90.f];
        }
        else {
            [SNRWindowBottomColor set];
            [NSBezierPath fillRect:titleBarRect];
        }
        
        // Draw the window title
        [self snr_drawTitleInRect:titleBarRect];
    }
    
    // Rest of the window has a solid fill
    NSRect bottomRect = NSMakeRect(0.f, 0.f, self.bounds.size.width, self.bounds.size.height - (titleBar ? SNRWindowTitlebarHeight : 0));
    [SNRWindowBottomColor set];
    [NSBezierPath fillRect:bottomRect];
    // Draw the highlight line around the top edge of the window
    // Outset the width of the rectangle by 0.5px so that the highlight "bleeds" around the rounded corners
    // Outset the height by 1px so that the line is drawn right below the border
    NSRect highlightRect = NSInsetRect(drawingRect, 0.f, 0.5f);
    // Make the height of the highlight rect something bigger than the bounds so that it won't show up on the bottom
    highlightRect.size.height += 50.f;
    highlightRect.origin.y -= 50.f;
    NSBezierPath *highlightPath = [NSBezierPath bezierPathWithRoundedRect:highlightRect xRadius:SNRWindowCornerRadius yRadius:SNRWindowCornerRadius];
    [SNRWindowHighlightColor set];
    [highlightPath stroke];
    [NSGraphicsContext restoreGraphicsState];
    [SNRWindowBorderColor set];
    [path stroke];
    
    if(titleBar && [(SNRHUDWindow *)self.window drawsKeyLine] && [self.window isKeyWindow])
    {
        
        NSBezierPath *topHighlightPath = [NSBezierPath bezierPath];
        [topHighlightPath setLineWidth:0.0];
        [topHighlightPath moveToPoint:NSPointFromCGPoint(CGPointMake(drawingRect.origin.x, NSMaxY(drawingRect) -SNRWindowTitlebarHeight+1))];
        [topHighlightPath lineToPoint:NSPointFromCGPoint(CGPointMake(NSMaxX(drawingRect), NSMaxY(drawingRect) -SNRWindowTitlebarHeight+1))];
        [topHighlightPath closePath];
        [[[NSColor blackColor] colorWithAlphaComponent:0.5] set];
        
        [topHighlightPath stroke];
    }
    
    //[highlightPath setClip];
}

- (void)snr_drawTitleInRect:(NSRect)titleBarRect
{
    NSString *title = [[self window] title];
    if (!title) { return; }
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:SNRWindowTitleShadowColor];
    [shadow setShadowOffset:SNRWindowTitleShadowOffset];
    [shadow setShadowBlurRadius:SNRWindowTitleShadowBlurRadius];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: SNRWindowTitleColor, NSFontAttributeName: SNRWindowTitleFont, NSShadowAttributeName: shadow, NSParagraphStyleAttributeName: style};
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    NSSize titleSize = attrTitle.size;
    NSRect titleRect = NSMakeRect(0.f, NSMidY(titleBarRect) - (titleSize.height / 2.f), titleBarRect.size.width, titleSize.height);
    [attrTitle drawInRect:NSIntegralRect(titleRect)];
}

@end

@implementation RAWindowTitleBarView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 2) {
        // Get settings from "System Preferences" >  "Appearance" > "Double-click on windows title bar to minimize"
        NSString *const MDAppleMiniaturizeOnDoubleClickKey = @"AppleMiniaturizeOnDoubleClick";
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults addSuiteNamed:NSGlobalDomain];
        BOOL shouldMiniaturize = [[userDefaults objectForKey:MDAppleMiniaturizeOnDoubleClickKey] boolValue];
        if (shouldMiniaturize) {
            [[self window] miniaturize:self];
        }
    }
}

@end

@implementation RAWindowButtonCell

@synthesize delegate;

- (NSColor *)highlightColor
{
    return [NSColor colorWithDeviceRed:0.000 green:0.733 blue:0.000 alpha:1.000];
}

- (NSBezierPath *)pathForDetailInFrame:(NSRect)frame
{
    return nil;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    BOOL active = [self.delegate isKeyWindow];
    BOOL hover = [self.delegate trafficLightHover];
    
    cellFrame.size = NSMakeSize(14, 14);
    NSRect drawingRect = NSInsetRect(cellFrame, 1.5f, 1.5f);
    drawingRect.origin.y = 0.5f;
    NSRect dropShadowRect = drawingRect;
    dropShadowRect.origin.y += 1.f;
    // Draw the drop shadow so that the bottom edge peeks through
    NSBezierPath *dropShadow = [NSBezierPath bezierPathWithOvalInRect:dropShadowRect];
    [SNRWindowButtonDropShadowColor set];
    [dropShadow stroke];
    // Draw the main circle w/ gradient & border on top of it
    NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:drawingRect];
    NSGradient *gradient = nil;
    
    NSColor *color = [self highlightColor];
    
    if((active || hover) && self.isEnabled)
        gradient = [[NSGradient alloc] initWithStartingColor:[color highlightWithLevel:0.2] endingColor:[color shadowWithLevel:0.4]];
    else
        gradient = [[NSGradient alloc] initWithStartingColor:SNRWindowButtonGradientBottomColor endingColor:SNRWindowButtonGradientTopColor];
    
    [gradient drawInBezierPath:circle angle:270.f];
    [SNRWindowButtonBorderColor set];
    [circle stroke];

    CGFloat boxDimension = floor(drawingRect.size.width * cos(45.f)) - SNRWindowButtonCrossInset;
    CGFloat origin = round((drawingRect.size.width - boxDimension) / 2.f);
    
    if(hover && self.isEnabled)
    {
        NSBezierPath *icon = [self pathForDetailInFrame:NSMakeRect(0,0,14,14)];
        
        //[[SNRWindowTitleShadowColor colorWithAlphaComponent:1] set];
        //[icon setLineWidth:1.5];
        
        //[icon stroke];
        [icon fill];
        
        NSColor* color = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.54];
        NSShadow* shadow3 = [[NSShadow alloc] init];
        [shadow3 setShadowColor: color];
        [shadow3 setShadowOffset: NSMakeSize(-0, -1)];
        [shadow3 setShadowBlurRadius: 1];
        
        NSRect bezier11BorderRect = NSInsetRect([icon bounds], -shadow3.shadowBlurRadius, -shadow3.shadowBlurRadius);
        bezier11BorderRect = NSOffsetRect(bezier11BorderRect, -shadow3.shadowOffset.width, shadow3.shadowOffset.height);
        bezier11BorderRect = NSInsetRect(NSUnionRect(bezier11BorderRect, [icon bounds]), -1, -1);
        
        NSBezierPath* bezier11NegativePath = [NSBezierPath bezierPathWithRect: bezier11BorderRect];
        [bezier11NegativePath appendBezierPath: icon];
        [bezier11NegativePath setWindingRule: NSEvenOddWindingRule];
        
        [NSGraphicsContext saveGraphicsState];
        {
            NSShadow* shadow3WithOffset = [shadow3 copy];
            CGFloat xOffset = shadow3WithOffset.shadowOffset.width + round(bezier11BorderRect.size.width);
            CGFloat yOffset = shadow3WithOffset.shadowOffset.height;
            shadow3WithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
            [shadow3WithOffset set];
            [[NSColor grayColor] setFill];
            [icon addClip];
            NSAffineTransform* transform = [NSAffineTransform transform];
            [transform translateXBy: -round(bezier11BorderRect.size.width) yBy: 0];
            [[transform transformBezierPath: bezier11NegativePath] fill];
        }
        [NSGraphicsContext restoreGraphicsState];
//        NSShadow *shadow = [[NSShadow alloc] init];
//        [shadow setShadowColor:[NSColor blackColor]];
//        [shadow setShadowBlurRadius:0.2f];
//        [shadow setShadowOffset:SNRWindowButtonInnerShadowOffset];
//        [icon fillWithInnerShadow:shadow];
    }
    
    // Draw the inner shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:SNRWindowButtonInnerShadowColor];
    [shadow setShadowBlurRadius:SNRWindowButtonInnerShadowBlurRadius];
    [shadow setShadowOffset:SNRWindowButtonInnerShadowOffset];
    NSRect shadowRect = drawingRect;
    shadowRect.size.height = origin;
    [NSGraphicsContext saveGraphicsState];
    [NSBezierPath clipRect:shadowRect];
    [circle fillWithInnerShadow:shadow];
    [NSGraphicsContext restoreGraphicsState];
    if ([self isHighlighted]) {
        [SNRWindowButtonHighlightOverlayColor set];
        [circle fill];
    }
}

@end

@implementation RACloseButtonCell

- (NSColor *)highlightColor
{
    return [NSColor colorWithDeviceRed:0.733 green:0.000 blue:0.000 alpha:1.000];
}

- (NSBezierPath *)pathForDetailInFrame:(NSRect)frame
{
    //// Bezier Drawing
    //// Bezier 11 Drawing
    NSBezierPath* bezier11Path = [NSBezierPath bezierPath];
    [bezier11Path moveToPoint: NSMakePoint(NSMinX(frame) + 9, NSMinY(frame) + 2.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 10.5, NSMinY(frame) + 4)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 8.5, NSMinY(frame) + 6)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 10.5, NSMinY(frame) + 8)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 9, NSMinY(frame) + 9.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 7, NSMinY(frame) + 7.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 5, NSMinY(frame) + 9.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 3.5, NSMinY(frame) + 8)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 5.5, NSMinY(frame) + 6)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 3.5, NSMinY(frame) + 4)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 5, NSMinY(frame) + 2.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 7, NSMinY(frame) + 4.5)];
    [bezier11Path lineToPoint: NSMakePoint(NSMinX(frame) + 9, NSMinY(frame) + 2.5)];
    [bezier11Path closePath];
    NSColor* color4 = [NSColor colorWithCalibratedRed: 0.28 green: 0 blue: 0 alpha: 0.75];
    [color4 setFill];
    //[bezier11Path fill];
    return bezier11Path;
}

@end

@implementation RAMinimizeButtonCell

- (NSColor *)highlightColor
{
    return [NSColor colorWithDeviceRed:0.876 green:0.581 blue:0.000 alpha:1.000];
}

- (NSBezierPath *)pathForDetailInFrame:(NSRect)frame
{
    NSBezierPath* minimizePath = [NSBezierPath bezierPath];
    [minimizePath moveToPoint: NSMakePoint(NSMinX(frame) + 3, NSMinY(frame) + 5)];
    [minimizePath lineToPoint: NSMakePoint(NSMinX(frame) + 11, NSMinY(frame) + 5)];
    [minimizePath lineToPoint: NSMakePoint(NSMinX(frame) + 11, NSMinY(frame) + 7)];
    [minimizePath lineToPoint: NSMakePoint(NSMinX(frame) + 3, NSMinY(frame) + 7)];
    [minimizePath lineToPoint: NSMakePoint(NSMinX(frame) + 3, NSMinY(frame) + 5)];
    [minimizePath closePath];
    NSColor* minimiseBase = [NSColor colorWithCalibratedRed: 0.61 green: 0.33 blue: 0.02 alpha: 0.87];
    [minimiseBase setFill];
    //[minimizePath fill];
    
    return minimizePath;

}

@end


@implementation RAZoomButtonCell

- (NSColor *)highlightColor
{
    return [NSColor colorWithDeviceRed:0.000 green:0.733 blue:0.000 alpha:1.000];
}

- (NSBezierPath *)pathForDetailInFrame:(NSRect)frame3
{
    NSBezierPath* maximisePath = [NSBezierPath bezierPath];
    [maximisePath moveToPoint: NSMakePoint(NSMinX(frame3) + 3, NSMinY(frame3) + 5)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 6, NSMinY(frame3) + 5)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 6, NSMinY(frame3) + 2)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 8, NSMinY(frame3) + 2)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 8, NSMinY(frame3) + 5)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 11, NSMinY(frame3) + 5)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 11, NSMinY(frame3) + 7)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 8, NSMinY(frame3) + 7)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 8, NSMinY(frame3) + 10)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 6, NSMinY(frame3) + 10)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 6, NSMinY(frame3) + 7)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 3, NSMinY(frame3) + 7)];
    [maximisePath lineToPoint: NSMakePoint(NSMinX(frame3) + 3, NSMinY(frame3) + 5)];
    [maximisePath closePath];
    NSColor* maximiseBase = [NSColor colorWithCalibratedRed: 0.12 green: 0.29 blue: 0.01 alpha: 0.79];
    [maximiseBase setFill];
    //[maximisePath fill];
    return maximisePath;
}

@end

