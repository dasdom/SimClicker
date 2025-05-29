//  Created by Dominik Hauser on 17.05.25.
//  
//


#import <Cocoa/Cocoa.h>
#import "DDHInfoWindowControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDHInfoWindowController : NSWindowController
@property (nonatomic, copy, nullable) void (^gridToggleHandler)(BOOL);
@property (nonatomic, copy, nullable) void (^activateToggleHandler)(BOOL);
@property (nonatomic, copy, nullable) void (^rescanHandler)(void);
- (instancetype)initWithRect:(NSRect)rect delegate:(id<DDHInfoWindowControllerProtocol>)delegate possibleCharacters:(NSArray<NSString *> *)possibleCharacters;
- (void)startSpinner;
- (void)stopSpinner;
- (void)reset;
- (void)updateCount:(NSInteger)count duration:(CGFloat)duration;
- (void)activate:(BOOL)activate;
@end

NS_ASSUME_NONNULL_END
