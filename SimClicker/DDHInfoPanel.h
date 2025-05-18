//  Created by Dominik Hauser on 18.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHInfoPanel : NSPanel
- (instancetype)initWithContentRect:(NSRect)contentRect;
- (void)updateWithInput:(NSString *)input;
@end

NS_ASSUME_NONNULL_END
