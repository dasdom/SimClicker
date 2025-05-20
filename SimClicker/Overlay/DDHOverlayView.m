//  Created by Dominik Hauser on 19.05.25.
//  
//


#import "DDHOverlayView.h"

@interface DDHOverlayView ()
@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, strong) NSString *text;
@end

@implementation DDHOverlayView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
        //        textField.translatesAutoresizingMaskIntoConstraints = NO;

        _textField.font = [NSFont boldSystemFontOfSize:13];
        _textField.textColor = [NSColor yellowColor];
        _textField.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.4];

        self.wantsLayer = YES;
        self.layer.borderColor = [[NSColor redColor] CGColor];
        self.layer.borderWidth = 1;

        [self addSubview:_textField];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)updateWithText:(NSString *)text {
    self.text = text;
    self.textField.stringValue = text;
    [self.textField sizeToFit];
}

- (void)updateWithSearchText:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.textField.hidden = NO;
        self.textField.stringValue = self.text;
    } else if ([self.text hasPrefix:searchText]) {
        self.textField.hidden = NO;

        NSRange range = [self.text rangeOfString:searchText];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedText setAttributes:@{NSBackgroundColorAttributeName: [NSColor yellowColor], NSForegroundColorAttributeName: [NSColor blackColor]} range:range];
        self.textField.attributedStringValue = attributedText;
    } else {
        self.textField.hidden = YES;
    }
}

@end
