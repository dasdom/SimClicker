//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHCodeWindow.h"

@interface DDHCodeWindow ()
@property (nonatomic, strong) NSTextField *codeLabel;
@end

@implementation DDHCodeWindow
- (instancetype)initWithContentRect:(NSRect)contentRect {
    if (self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES]) {

        self.title = @"UI test code";
        _codeLabel = [NSTextField labelWithString:@"UI test code"];
        _codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _codeLabel.font = [NSFont monospacedSystemFontOfSize:13 weight:NSFontWeightMedium];

        [self.contentView addSubview:_codeLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_codeLabel.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
            [_codeLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
            [_codeLabel.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor],
            [_codeLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor],
        ]];
    }
    return self;
}

- (void)updateWithCode:(NSString *)code {
    self.codeLabel.stringValue = code;
}
@end
