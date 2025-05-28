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

        _textField.bezeled = NO;
        _textField.font = [NSFont boldSystemFontOfSize:13];
        _textField.textColor = [NSColor yellowColor];
        _textField.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];

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
        self.layer.borderWidth = 1;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
    } else if ([self.text hasPrefix:searchText]) {
        self.textField.hidden = NO;
        self.layer.borderWidth = 1;

        NSRange range = [self.text rangeOfString:searchText];

        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedText setAttributes:@{NSBackgroundColorAttributeName: [NSColor yellowColor], NSForegroundColorAttributeName: [NSColor blackColor]} range:range];
        self.textField.attributedStringValue = attributedText;

        if ([self.text isEqualToString:searchText]) {
            self.layer.backgroundColor = [[NSColor greenColor] colorWithAlphaComponent:0.2].CGColor;
        } else {
            self.layer.backgroundColor = [NSColor clearColor].CGColor;
        }
    } else {
        self.layer.borderWidth = 0;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;

        self.textField.hidden = YES;
    }
}

@end
