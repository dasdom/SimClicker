//  Created by Dominik Hauser on 29.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHCodeWindow : NSWindow
- (instancetype)initWithContentRect:(NSRect)contentRect;
- (void)updateWithCode:(NSString *)code;
@end

NS_ASSUME_NONNULL_END
