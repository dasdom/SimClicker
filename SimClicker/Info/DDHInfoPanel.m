//  Created by Dominik Hauser on 18.05.25.
//  
//


#import "DDHInfoPanel.h"

@interface DDHInfoPanel ()
@property (nonatomic, strong) NSTextField *inputLabel;
@property (nonatomic, strong) NSTextField *countDurationLabel;
@end

@implementation DDHInfoPanel
- (instancetype)initWithContentRect:(NSRect)contentRect {
    if (self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskUtilityWindow | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled | NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:YES]) {

        _progressIndicator = [[NSProgressIndicator alloc] init];
        _progressIndicator.style = NSProgressIndicatorStyleSpinning;
        _progressIndicator.usesThreadedAnimation = YES;

        _inputLabel = [[NSTextField alloc] init];
        _inputLabel.selectable = NO;
        _inputLabel.alignment = NSTextAlignmentCenter;
        _inputLabel.font = [NSFont boldSystemFontOfSize:30];
        _inputLabel.placeholderString = @"Type tag";

        NSStackView *inputStackView = [NSStackView stackViewWithViews:@[_inputLabel, _progressIndicator]];
        inputStackView.distribution = NSStackViewDistributionFill;

        _countDurationLabel = [NSTextField labelWithString:@"duration"];
        _countDurationLabel.selectable = NO;
        _countDurationLabel.alignment = NSTextAlignmentCenter;
        _countDurationLabel.font = [NSFont preferredFontForTextStyle:NSFontTextStyleFootnote options:@{}];

        _activeButton = [NSButton checkboxWithTitle:@"Active" target:nil action:nil];
        _activeButton.state = NSControlStateValueOn;

        NSStackView *stackView = [NSStackView stackViewWithViews:@[inputStackView, _countDurationLabel, _activeButton]];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.orientation = NSUserInterfaceLayoutOrientationVertical;

//        _showGridButton = [NSButton checkboxWithTitle:@"Grid" target:nil action:nil];
//        _showGridButton.translatesAutoresizingMaskIntoConstraints = NO;

        _rescanButton = [NSButton buttonWithTitle:@"Re-Scan" target:nil action:nil];
        _rescanButton.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:stackView];
        [self.contentView addSubview:_showGridButton];
        [self.contentView addSubview:_rescanButton];

        [_progressIndicator setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];

        [NSLayoutConstraint activateConstraints:@[
            [stackView.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
            [stackView.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
            [stackView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],

            [_progressIndicator.widthAnchor constraintEqualToConstant:20],
            [_progressIndicator.heightAnchor constraintEqualToAnchor:_progressIndicator.widthAnchor],

//            [_showGridButton.topAnchor constraintEqualToAnchor:_inputLabel.bottomAnchor constant:10],
//            [_showGridButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],

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

- (void)updateCount:(NSInteger)count duration:(CGFloat)duration {
    self.countDurationLabel.stringValue = [NSString stringWithFormat:@"found %ld elements in %.2lf s", count, duration];
}
@end
