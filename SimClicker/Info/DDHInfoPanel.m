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

        _inputLabel = [[NSTextField alloc] init];
        _inputLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _inputLabel.selectable = NO;
        _inputLabel.alignment = NSTextAlignmentCenter;
        _inputLabel.font = [NSFont boldSystemFontOfSize:30];
        _inputLabel.placeholderString = @"Type tag";

        _progressIndicator = [[NSProgressIndicator alloc] init];
        _progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        _progressIndicator.style = NSProgressIndicatorStyleSpinning;
        _progressIndicator.usesThreadedAnimation = YES;

        [self.contentView addSubview:_inputLabel];
        [self.contentView addSubview:_progressIndicator];

        [NSLayoutConstraint activateConstraints:@[
            [_inputLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_inputLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_inputLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

            [_progressIndicator.centerXAnchor constraintEqualToAnchor:_inputLabel.centerXAnchor],
            [_progressIndicator.topAnchor constraintEqualToAnchor:_inputLabel.bottomAnchor constant:8],
        ]];
    }
    return self;
}

- (void)updateWithInput:(NSString *)input {
    self.inputLabel.stringValue = input;
}
@end
