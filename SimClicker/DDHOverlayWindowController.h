//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHOverlayWindowController : NSWindowController <NSWindowDelegate>
- (void)setFrame:(NSRect)frame;
- (void)addOverlaysWithFrames:(NSArray<NSValue *> *)frames elementIndex:(NSInteger)elementIndex;
@end

NS_ASSUME_NONNULL_END
