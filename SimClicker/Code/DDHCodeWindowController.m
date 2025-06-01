//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHCodeWindowController.h"
#import "DDHCodeWindow.h"
#import "DDHCodeViewController.h"

@interface DDHCodeWindowController ()
@property (nonatomic, strong) DDHCodeWindow *contentWindow;
@property (nonatomic, strong) DDHCodeViewController *codeViewController;
@end

@implementation DDHCodeWindowController

- (instancetype)initWithRect:(NSRect)rect {
//    NSRect frame = NSMakeRect(0, 0, 400, 300);
    DDHCodeWindow *codeWindow = [[DDHCodeWindow alloc] initWithContentRect:rect];
    codeWindow.minSize = rect.size;

    if (self = [super initWithWindow:codeWindow]) {

        _codeViewController = [[DDHCodeViewController alloc] init];
        _codeViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentWindow.contentView addSubview:_codeViewController.view];

        [NSLayoutConstraint activateConstraints:@[
            [_codeViewController.view.topAnchor constraintEqualToAnchor:self.contentWindow.contentView.topAnchor],
            [_codeViewController.view.leadingAnchor constraintEqualToAnchor:self.contentWindow.contentView.leadingAnchor],
            [_codeViewController.view.bottomAnchor constraintEqualToAnchor:self.contentWindow.contentView.bottomAnchor],
            [_codeViewController.view.trailingAnchor constraintEqualToAnchor:self.contentWindow.contentView.trailingAnchor],
        ]];
    }
    return self;
}

- (DDHCodeWindow *)contentWindow {
    return (DDHCodeWindow *)self.window;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

- (void)updateWithCode:(NSString *)code updateLast:(BOOL)updateLast {
    [self.codeViewController updateWithCode:code updateLast:updateLast];
}

- (NSString *)lastCodeLine {
    return [self.codeViewController lastCodeLine];
}

@end
