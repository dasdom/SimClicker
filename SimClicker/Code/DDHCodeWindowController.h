//  Created by Dominik Hauser on 29.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHCodeWindowController : NSWindowController
- (instancetype)initWithRect:(NSRect)rect;
- (void)updateWithCode:(NSString *)code updateLast:(BOOL)updateLast;
- (NSString *)lastCodeLine;
@end

NS_ASSUME_NONNULL_END
