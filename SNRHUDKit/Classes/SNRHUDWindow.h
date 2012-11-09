//
//  SNRHUDWindow.h
//  SNRHUDKit
//
//  Created by Indragie Karunaratne on 12-01-22.
//  Copyright (c) 2012 indragie.com. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface RAWindowButtonCell : NSButtonCell

@property (nonatomic, unsafe_unretained) id delegate;

@end

@interface RACloseButtonCell : RAWindowButtonCell
@end

@interface RAMinimizeButtonCell : RAWindowButtonCell
@end

@interface RAZoomButtonCell : RAWindowButtonCell
@end

@interface RAWindowTitleBarView : NSView

@end

@interface SNRHUDWindowFrameView : NSView

- (void)snr_drawTitleInRect:(NSRect)rect;

@end

@interface SNRHUDWindow : NSWindow
{
    NSButton *closeButton;
    NSButton *minimizeButton;
    NSButton *zoomButton;
    
    NSView *titleBarView;
    
    NSTrackingRectTag trafficLight;

}

+ (Class)frameViewClass;

@property (nonatomic,assign) BOOL hasTitleBar;
@property (nonatomic,assign) BOOL closable;
@property (nonatomic,assign) BOOL minaturizable;
@property (nonatomic,assign) BOOL zoomable;
@property (nonatomic,assign) BOOL floating;
@property (nonatomic,assign) CGFloat transparency;
@property (nonatomic,assign) BOOL drawsKeyLine;

@property (nonatomic,assign) BOOL trafficLightHover;

@end