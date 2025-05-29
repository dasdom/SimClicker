//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHOverlayElement;

@interface DDHOverlayWindowController : NSWindowController <NSWindowDelegate>
@property (nonatomic) CGSize spacing;
- (void)setFrame:(NSRect)frame;
- (void)reset;
- (void)addOverlays:(NSArray<DDHOverlayElement *> *)overlayElements toolbarElement:(DDHOverlayElement *)toolbarElement;
- (void)updateWithSearchText:(NSString *)searchText;
//- (void)hideGrid;
//- (void)showGrid;
- (void)hideWindow;
- (void)showWindow;
- (void)toggleWindowHidden;
- (void)activate:(BOOL)activate;
@end

NS_ASSUME_NONNULL_END
