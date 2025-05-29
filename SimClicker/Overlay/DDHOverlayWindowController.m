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

- (void)setFrame:(NSRect)frame {

    NSRect screenFrame = [NSScreen mainScreen].visibleFrame;
    screenFrame.origin.y = 20;
    screenFrame.size.height = screenFrame.size.height + 20;
    [self.window setFrame:screenFrame display:NO];

    //    DDHGridView *gridView = [[DDHGridView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) spacing:self.spacing];
    //    gridView.hidden = YES;
    //    [self.window.contentView addSubview:gridView];
    //    self.gridView = gridView;
}

- (void)reset {
    for (NSView *view in self.overlayViews) {
        [view removeFromSuperview];
    }
    self.overlayViews = nil;
}

//- (void)hideGrid {
//    self.gridView.hidden = YES;
//}
//
//- (void)showGrid {
//    self.gridView.hidden = NO;
//}

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

- (void)addOverlays:(NSArray<DDHOverlayElement *> *)overlayElements toolbarElement:(DDHOverlayElement *)toolbarElement {

    for (NSView *view in self.overlayViews) {
        [view removeFromSuperview];
    }

    NSMutableArray<NSView *> *overlayViews = [[NSMutableArray alloc] init];
    //    NSRect convertedToolbarFrame = [self.window convertRectFromScreen:toolbarElement.frame];

    //    BOOL needsToBeConverted = self.window.contentView.frame.size.width > self.window.contentView.frame.size.height;

    for (DDHOverlayElement *overlayElement in overlayElements) {
        //        NSRect convertedFrame = [self.window convertRectFromScreen:overlayElement.frame];

        //        NSLog(@"tag: %@, role: %@, frame: %@", overlayElement.tag, overlayElement.role, [NSValue valueWithRect:convertedFrame]);
        //        if (needsToBeConverted) {
        //            convertedFrame = [self flippedRectFromRect:convertedFrame toolbarFrame:convertedToolbarFrame];
        //        }

        NSRect movedFrame = NSOffsetRect(overlayElement.frame, 0, -20);
        DDHOverlayView *view = [[DDHOverlayView alloc] initWithFrame:movedFrame];

        if ([overlayElement.actionNames containsObject:@"AXScrollDownByPage"]) {
            [view updateWithText:[NSString stringWithFormat:@"%@*", overlayElement.tag]];
        } else {
            [view updateWithText:overlayElement.tag];
        }

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

//- (NSRect)flippedRectFromRect:(NSRect)rect toolbarFrame:(NSRect)toolbarFrame {
////    return NSMakeRect(rect.origin.y, self.window.contentView.frame.size.height-toolbarFrame.size.height-rect.origin.x-30, rect.size.height, rect.size.width);
//    return NSMakeRect(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
//}

- (void)activate:(BOOL)activate {
    if (activate) {
        [self showWindow];
    } else {
        [self hideWindow];
    }
}

@end
