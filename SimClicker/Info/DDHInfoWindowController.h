//  Created by Dominik Hauser on 17.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHInfoWindowController : NSWindowController
@property (nonatomic, copy, nullable) void (^inputHandler)(NSString *_Nonnull);
@property (nonatomic, copy, nullable) void (^gridToggleHandler)(BOOL);
@property (nonatomic, copy, nullable) void (^rescanHandler)(void);
- (instancetype)initWithRect:(NSRect)rect possibleCharacters:(NSArray<NSString *> *)possibleCharacters;
- (void)startSpinner;
- (void)stopSpinner;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
