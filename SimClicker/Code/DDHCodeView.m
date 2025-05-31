//  Created by Dominik Hauser on 30.05.25.
//  
//


#import "DDHCodeView.h"

@interface DDHCodeView ()
@property (nonatomic, strong) NSScrollView *scrollView;
@end

@implementation DDHCodeView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        _scrollView = [[NSScrollView alloc] initWithFrame:frameRect];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;

        _tableView = [[NSTableView alloc] initWithFrame:frameRect];

        NSTableColumn *tableColumn = [[NSTableColumn alloc] initWithIdentifier:@"Col 1"];
        tableColumn.minWidth = 200;
        [_tableView addTableColumn:tableColumn];

        _scrollView.documentView = _tableView;

        [self addSubview:_scrollView];

        [NSLayoutConstraint activateConstraints:@[
            [_scrollView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        ]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    
}

@end
