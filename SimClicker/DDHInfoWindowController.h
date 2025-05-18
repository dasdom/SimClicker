//  Created by Dominik Hauser on 17.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHInfoWindowController : NSWindowController
@property (nonatomic, copy, nullable) void (^inputHandler)(NSString *_Nonnull);
- (instancetype)initWithRect:(NSRect)rect;
- (void)startSpinner;
- (void)stopSpinner;
@end

NS_ASSUME_NONNULL_END
