//  Created by Dominik Hauser on 17.05.25.
//  
//


#import "DDHInfoWindowController.h"
#import "DDHInfoPanel.h"

@interface DDHInfoWindowController ()
@property (nonatomic, strong) DDHInfoPanel *contentWindow;
@property (nonatomic, strong) NSMutableString *input;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation DDHInfoWindowController

- (instancetype)init {
    NSRect contentRect = NSMakeRect(0, 200, 200, 200);
    DDHInfoPanel *infoPanel = [[DDHInfoPanel alloc] initWithContentRect:contentRect];

    if (self = [super initWithWindow:infoPanel]) {
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent * _Nonnull event) {
            [self keyDown:event];
        }];

        _input = [[NSMutableString alloc] init];
    }
    return self;
}

- (DDHInfoPanel *)contentWindow {
    return (DDHInfoPanel *)self.window;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"global event %@", event);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        self.inputHandler(self.input);
        self.input = [[NSMutableString alloc] init];
    }];
    [self.input appendString:event.characters];
    [self.contentWindow updateWithInput:self.input];
}

@end
