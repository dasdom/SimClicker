//  Created by Dominik Hauser on 16.05.25.
//  
//


#import "DDHGridView.h"

@interface DDHGridView ()
@property (nonatomic) CGSize spacing;
@end

@implementation DDHGridView

- (instancetype)initWithFrame:(NSRect)frame spacing:(CGSize)spacing {
    if (self = [super initWithFrame:frame]) {
        _spacing = spacing;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGRect frame = self.frame;

    NSLog(@"frame: %@", [NSValue valueWithRect:frame]);

    for (CGFloat y = frame.origin.y; y < CGRectGetMaxY(frame); y += self.spacing.height) {

        NSLog(@"DDHGridView y: %lf", y);
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSMakePoint(CGRectGetMinX(frame), y)];
        [path lineToPoint:NSMakePoint(CGRectGetMaxX(frame), y)];
        [[NSColor grayColor] set];
        path.lineWidth = 1;
        [path stroke];
    }

    for (CGFloat x = frame.origin.x; x < CGRectGetMaxX(frame); x += self.spacing.width) {

        NSLog(@"DDHGridView x: %lf", x);
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:NSMakePoint(x, CGRectGetMinY(frame))];
        [path lineToPoint:NSMakePoint(x, CGRectGetMaxY(frame))];
        [[NSColor grayColor] set];
        path.lineWidth = 1;
        [path stroke];
    }
}

@end
