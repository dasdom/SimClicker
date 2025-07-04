//  Created by Dominik Hauser on 17.05.25.
//  
//


#import "DDHInfoWindowController.h"
#import "DDHInfoPanel.h"

@interface DDHInfoWindowController ()
@property (nonatomic, weak) id<DDHInfoWindowControllerProtocol> delegate;
@property (nonatomic, strong) NSArray<NSString *> *possibleCharacters;
@property (nonatomic, strong) DDHInfoPanel *contentWindow;
@property (nonatomic, strong) NSMutableString *input;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) id eventMonitor;
@end

@implementation DDHInfoWindowController

- (instancetype)initWithRect:(NSRect)rect delegate:(id<DDHInfoWindowControllerProtocol>)delegate possibleCharacters:(NSArray<NSString *> *)possibleCharacters {
    DDHInfoPanel *infoPanel = [[DDHInfoPanel alloc] initWithContentRect:rect];

    if (self = [super initWithWindow:infoPanel]) {
//        self.eventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent * _Nonnull event) {
//            [self keyDown:event];
//        }];

        [self activate:YES];

        _delegate = delegate;
        _possibleCharacters = possibleCharacters;
        _input = [[NSMutableString alloc] init];

        //        [infoPanel.showGridButton setTarget:self];
        //        [infoPanel.showGridButton setAction:@selector(toggleGrid:)];

        [infoPanel.rescanButton setTarget:self];
        [infoPanel.rescanButton setAction:@selector(rescan:)];

        [infoPanel.activeButton setTarget:self];
        [infoPanel.activeButton setAction:@selector(toggleActive:)];
    }
    return self;
}

- (DDHInfoPanel *)contentWindow {
    return (DDHInfoPanel *)self.window;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

- (void)reset {
    self.input = [[NSMutableString alloc] init];
    [self.contentWindow updateWithInput:self.input];
    [self.delegate windowController:self processInput:self.input];
    [self.timer invalidate];
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"global event %@", event);
    [self.timer invalidate];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        [self reset];
    }];

    [self.input appendString:event.characters.uppercaseString];

    NSString *input;
    if ([self.possibleCharacters containsObject:[event.characters uppercaseString]]) {

        input = self.input;
        [self.contentWindow updateWithInput:input];

        if (self.input.length == 2) {
            [self.timer invalidate];
        }
    } else if (event.keyCode == 36 || event.keyCode == 76) {
        input = @"enter";
    } else if (event.keyCode == 126) {
        input = @"up";
    } else if (event.keyCode == 125) {
        input = @"down";
    } else if (event.keyCode == 123) {
        input = @"left";
    } else if (event.keyCode == 124) {
        input = @"right";
    } else if ([event.characters isEqualToString:@"c"] && event.modifierFlags & NSEventModifierFlagCommand) {
        input = @"copy";
    }

    if (input) {
        [self.delegate windowController:self processInput:input];
    }
}

- (void)startSpinner {
    self.contentWindow.progressIndicator.hidden = NO;
    [self.contentWindow.progressIndicator startAnimation:nil];
}

- (void)stopSpinner {
    [self reset];
    self.contentWindow.progressIndicator.hidden = YES;
    [self.contentWindow.progressIndicator stopAnimation:nil];
}

// MARK: - Actions
//- (void)toggleGrid:(NSButton *)sender {
//    self.gridToggleHandler(sender.state);
//}

- (void)toggleActive:(NSButton *)sender {
    self.activateToggleHandler(sender.state);
}

- (void)rescan:(NSButton *)sender {
    self.rescanHandler();
}

- (void)updateCount:(NSInteger)count duration:(CGFloat)duration {
    [self.contentWindow updateCount:count duration:duration];
}

- (void)activate:(BOOL)activate {
    if (activate) {
        [self reset];
        self.contentWindow.activeButton.state = NSControlStateValueOn;

        self.eventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent * _Nonnull event) {
            [self keyDown:event];
        }];
    } else {
        self.contentWindow.activeButton.state = NSControlStateValueOff;

        [NSEvent removeMonitor:self.eventMonitor];
    }
}

@end
