//  Created by Dominik Hauser on 09.05.25.
//  
//


#import "DDHOverlayWindowController.h"
#import "DDHOverlayElement.h"
#import "UIElementUtilities.h"
#import "DDHGridView.h"
#import "DDHOverlayView.h"

@interface DDHOverlayWindowController ()
@property (nonatomic, strong) NSArray<NSView *> *overlayViews;
@property (nonatomic, strong) DDHGridView *gridView;
@end

@implementation DDHOverlayWindowController

- (instancetype)init {
    NSRect bounds = NSMakeRect(0.0, 0.0, 100.0, 100.0);

    NSWindow *window = [[NSWindow alloc] initWithContentRect:bounds styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
    window.opaque = NO;
    window.level = NSStatusWindowLevel;
    window.backgroundColor = [NSColor clearColor];
    window.ignoresMouseEvents = YES;
    window.hidesOnDeactivate = NO;

    if (self = [super initWithWindow:window]) {
        [window setDelegate:self];
    }
    return self;
}

- (void)setFrame:(NSRect)frame spacing:(CGSize)spacing {
    self.spacing = spacing;
    [self.window setFrame:frame display:NO];

//    DDHGridView *gridView = [[DDHGridView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) spacing:self.spacing];
//    [self.window.contentView addSubview:gridView];
}

- (void)reset {
    for (NSView *view in self.overlayViews) {
        [view removeFromSuperview];
    }
    self.overlayViews = nil;
}

- (void)hideWindow {
    [self.window orderOut:self];
}

- (void)showWindow {
    [self.window orderFrontRegardless];
}

- (void)toggleWindowHidden {
    if (self.window.visible) {
        [self hideWindow];
    } else {
        [self showWindow];
    }
}

- (void)addOverlays:(NSArray<DDHOverlayElement *> *)overlayElements {

    for (NSView *view in self.overlayViews) {
        [view removeFromSuperview];
    }

    NSMutableArray<NSView *> *overlayViews = [[NSMutableArray alloc] init];

    for (DDHOverlayElement *overlayElement in overlayElements) {
        AXUIElementRef uiElement = (__bridge AXUIElementRef)overlayElement.uiElementValue;
        NSRect frame = [UIElementUtilities frameOfUIElement:uiElement];
        NSRect convertedFrame = [self.window convertRectFromScreen:frame];

//        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];

        DDHOverlayView *view = [[DDHOverlayView alloc] initWithFrame:convertedFrame];

        [view updateWithText:overlayElement.tag];

        [overlayViews addObject:view];

        [self.window.contentView addSubview:view];
    }

    self.overlayViews = [overlayViews copy];
}

- (void)updateWithSearchText:(NSString *)searchText {
    for (DDHOverlayView *overlayView in self.overlayViews) {
        [overlayView updateWithSearchText:searchText];
    }
}

@end
