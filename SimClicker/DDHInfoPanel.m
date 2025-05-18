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

        [self.contentView addSubview:_inputLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_inputLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_inputLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_inputLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        ]];
    }
    return self;
}

- (void)updateWithInput:(NSString *)input {
    self.inputLabel.stringValue = input;
}
@end
