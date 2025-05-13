//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHOverlayElement;

@interface DDHOverlayWindowController : NSWindowController <NSWindowDelegate>
- (void)setFrame:(NSRect)frame;
- (void)reset;
- (void)addOverlays:(NSArray<DDHOverlayElement *> *)overlayElements;
@end

NS_ASSUME_NONNULL_END
