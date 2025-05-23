//  Created by Dominik Hauser on 18.05.25.
//  
//


#import "DDHInfoPanel.h"

@interface DDHInfoPanel ()
@property (nonatomic, strong) NSTextField *inputLabel;
@end

@implementation DDHInfoPanel
- (instancetype)initWithContentRect:(NSRect)contentRect {
    if (self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskUtilityWindow | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:YES]) {

        _progressIndicator = [[NSProgressIndicator alloc] init];
        _progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _progressIndicator.style = NSProgressIndicatorStyleSpinning;
        _progressIndicator.usesThreadedAnimation = YES;

        _inputLabel = [[NSTextField alloc] init];
        _inputLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _inputLabel.selectable = NO;
        _inputLabel.alignment = NSTextAlignmentCenter;
        _inputLabel.font = [NSFont boldSystemFontOfSize:30];
        _inputLabel.placeholderString = @"Type tag";

        _showGridButton = [NSButton checkboxWithTitle:@"Grid" target:nil action:nil];
        _showGridButton.translatesAutoresizingMaskIntoConstraints = NO;

        _rescanButton = [NSButton buttonWithTitle:@"Re-Scan" target:nil action:nil];
        _rescanButton.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_inputLabel];
        [self.contentView addSubview:_progressIndicator];
        [self.contentView addSubview:_showGridButton];
        [self.contentView addSubview:_rescanButton];

        [NSLayoutConstraint activateConstraints:@[
            [_inputLabel.topAnchor constraintEqualToAnchor:_progressIndicator.bottomAnchor],
            [_inputLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_inputLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],

            [_progressIndicator.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
            [_progressIndicator.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
            [_progressIndicator.widthAnchor constraintEqualToConstant:20],
            [_progressIndicator.heightAnchor constraintEqualToAnchor:_progressIndicator.widthAnchor],

            [_showGridButton.topAnchor constraintEqualToAnchor:_inputLabel.bottomAnchor constant:10],
            [_showGridButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],

            [_rescanButton.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
            [_rescanButton.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
            [_rescanButton.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        ]];
    }
    return self;
}

- (void)updateWithInput:(NSString *)input {
    self.inputLabel.stringValue = input;
}
@end
