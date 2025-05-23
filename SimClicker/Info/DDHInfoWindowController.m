//  Created by Dominik Hauser on 17.05.25.
//  
//


#import "DDHInfoWindowController.h"
#import "DDHInfoPanel.h"

@interface DDHInfoWindowController ()
@property (nonatomic, strong) NSArray<NSString *> *possibleCharacters;
@property (nonatomic, strong) DDHInfoPanel *contentWindow;
@property (nonatomic, strong) NSMutableString *input;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation DDHInfoWindowController

- (instancetype)initWithRect:(NSRect)rect possibleCharacters:(NSArray<NSString *> *)possibleCharacters {
    DDHInfoPanel *infoPanel = [[DDHInfoPanel alloc] initWithContentRect:rect];

    if (self = [super initWithWindow:infoPanel]) {
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent * _Nonnull event) {
            [self keyDown:event];
        }];

        _possibleCharacters = possibleCharacters;
        _input = [[NSMutableString alloc] init];

        //        [infoPanel.showGridButton setTarget:self];
        //        [infoPanel.showGridButton setAction:@selector(toggleGrid:)];

        [infoPanel.rescanButton setTarget:self];
        [infoPanel.rescanButton setAction:@selector(rescan:)];
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
    self.inputHandler(self.input);
    [self.timer invalidate];
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"global event %@", event);
    if ([self.possibleCharacters containsObject:[event.characters uppercaseString]]) {
        [self.timer invalidate];

        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [timer invalidate];
            [self reset];
        }];

        [self.input appendString:event.characters.uppercaseString];
        self.inputHandler(self.input);
        [self.contentWindow updateWithInput:self.input];

        if (self.input.length == 2) {
            [self.timer invalidate];
        }
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

- (void)rescan:(NSButton *)sender {
    self.rescanHandler();
}

- (void)updateCount:(NSInteger)count duration:(CGFloat)duration {
    [self.contentWindow updateCount:count duration:duration];
}

@end
