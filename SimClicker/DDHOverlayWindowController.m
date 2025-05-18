//  Created by Dominik Hauser on 09.05.25.
//  
//


#import "DDHOverlayWindowController.h"
#import "DDHOverlayElement.h"
#import "UIElementUtilities.h"
#import "DDHGridView.h"

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

- (void)toggleWindowHidden {
    if (self.window.visible) {
        [self.window orderOut:self];
    } else {
        [self.window orderFrontRegardless];
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

        NSString *role = [UIElementUtilities roleOfUIElement:uiElement];

        NSView *view = [[NSView alloc] initWithFrame:convertedFrame];
        view.wantsLayer = YES;

        if ([role isEqualToString:@"AXButton"] ||
            [role isEqualToString:@"AXTextField"] ||
            [role isEqualToString:@"AXStaticText"]) {
            view.layer.borderColor = [[NSColor redColor] CGColor];
        } else if ([role isEqualToString:@"AXGroup"]) {
//            NSArray<NSValue *> *children = [UIElementUtilities childrenOfUIElement:uiElement];
            overlayElement.tag = @"";//[NSString stringWithFormat:@"count %ld", (long)children.count];
            view.layer.borderColor = [[NSColor yellowColor] CGColor];
        } else if ([role isEqualToString:@"AXToolbar"]) {
            view.layer.borderColor = [[NSColor magentaColor] CGColor];
        } else {
            view.layer.borderColor = [[NSColor greenColor] CGColor];
        }
        view.layer.borderWidth = 1;

        NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
//        textField.translatesAutoresizingMaskIntoConstraints = NO;

        textField.font = [NSFont boldSystemFontOfSize:13];
        textField.stringValue = overlayElement.tag;
        [textField sizeToFit];
        textField.textColor = [NSColor yellowColor];
        textField.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.4];
        [view addSubview:textField];

//        [NSLayoutConstraint activateConstraints:@[
//            [textField.topAnchor constraintEqualToAnchor:view.topAnchor],
//            [textField.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
//        ]];

        [overlayViews addObject:view];

        [self.window.contentView addSubview:view];
    }

    self.overlayViews = [overlayViews copy];
}

@end
