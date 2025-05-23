//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHOverlayElement;

@interface DDHOverlayWindowController : NSWindowController <NSWindowDelegate>
@property (nonatomic) CGSize spacing;
- (void)setFrame:(NSRect)frame spacing:(CGSize)spacing;
- (void)reset;
- (void)addOverlays:(NSArray<DDHOverlayElement *> *)overlayElements;
- (void)updateWithSearchText:(NSString *)searchText;
- (void)hideGrid;
- (void)showGrid;
- (void)hideWindow;
- (void)showWindow;
- (void)toggleWindowHidden;
@end

NS_ASSUME_NONNULL_END
