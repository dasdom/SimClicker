//  Created by Dominik Hauser on 09.05.25.
//  
//


#import "DDHOverlayWindowController.h"

@implementation DDHOverlayWindowController

- (instancetype)init {
    NSRect bounds = NSMakeRect(0.0, 0.0, 100.0, 100.0);

    NSWindow *window = [[NSWindow alloc] initWithContentRect:bounds styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
    window.opaque = NO;
    window.level = NSStatusWindowLevel;
    window.backgroundColor = [NSColor clearColor];
    window.ignoresMouseEvents = YES;

    if (self = [super initWithWindow:window]) {
        [window setDelegate:self];
    }
    return self;
}

- (void)setFrame:(NSRect)frame {
    [self.window setFrame:frame display:NO];
}

- (void)addOverlaysWithFrames:(NSArray<NSValue *> *)frames elementIndex:(NSInteger)elementIndex {

    for (NSInteger i = 0; i < [frames count]; i++) {
        NSValue *frameValue = frames[i];
        NSRect frame = [frameValue rectValue];
        NSRect convertedFrame = [self.window convertRectFromScreen:frame];

        NSView *view = [[NSView alloc] initWithFrame:convertedFrame];
        view.wantsLayer = YES;
        view.layer.borderColor = [[NSColor greenColor] CGColor];
        view.layer.borderWidth = 2;

        NSTextField *textField = [[NSTextField alloc] initWithFrame:view.bounds];

        textField.stringValue = [NSString stringWithFormat:@"%ld%ld", (long)elementIndex, (long)i];
        textField.textColor = [NSColor yellowColor];
        [view addSubview:textField];

        [self.window.contentView addSubview:view];
    }

}

@end
