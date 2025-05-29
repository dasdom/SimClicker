//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHCodeWindowController.h"
#import "DDHCodeWindow.h"

@interface DDHCodeWindowController ()
@property (nonatomic, strong) DDHCodeWindow *contentWindow;
@end

@implementation DDHCodeWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 200, 200);
    DDHCodeWindow *codeWindow = [[DDHCodeWindow alloc] initWithContentRect:frame];

    if (self = [super initWithWindow:codeWindow]) {

    }
    return self;
}

- (DDHCodeWindow *)contentWindow {
    return (DDHCodeWindow *)self.window;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)updateWithCode:(NSString *)code {
    [self.contentWindow updateWithCode:code];
}

@end
