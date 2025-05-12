//  Created by Dominik Hauser on 09.05.25.
//
//


#import "DDHInfoViewController.h"

@interface DDHInfoViewController ()
@property (weak) IBOutlet NSPopUpButton *simulatorButton;
@property (nonatomic, strong) NSMutableString *input;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation DDHInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.input = [[NSMutableString alloc] init];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)updateSimulatorPickerWithNames:(NSArray<NSString *> *)names {
    [self.simulatorButton removeAllItems];

    for (NSString *name in names) {
        [self.simulatorButton addItemWithTitle:name];
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"event %@", event);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [timer invalidate];
        self.inputHandler(self.input);
        self.input = [[NSMutableString alloc] init];
    }];
    [self.input appendString:event.characters];
}

@end
