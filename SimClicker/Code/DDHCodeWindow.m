//  Created by Dominik Hauser on 29.05.25.
//  
//


#import "DDHCodeWindow.h"

@interface DDHCodeWindow ()
@end

@implementation DDHCodeWindow
- (instancetype)initWithContentRect:(NSRect)contentRect {
    if (self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskResizable backing:NSBackingStoreBuffered defer:YES]) {

        self.title = @"UI test code";
    }
    return self;
}
@end
