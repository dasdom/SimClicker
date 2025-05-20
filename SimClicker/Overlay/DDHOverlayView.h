//  Created by Dominik Hauser on 19.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHOverlayView : NSView
- (void)updateWithText:(NSString *)text;
- (void)updateWithSearchText:(NSString *)searchText;
@end

NS_ASSUME_NONNULL_END
