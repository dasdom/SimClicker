//  Created by Dominik Hauser on 29.05.25.
//  
//


#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

NS_ASSUME_NONNULL_BEGIN

@class NSRunningApplication;
@class DDHOverlayElement;

@interface DDHSimulatorManager : NSObject
@property (nonatomic, strong) NSRunningApplication *simulator;
@property (nonatomic) AXUIElementRef simulatorRef;
- (instancetype)initWithPossibleCharacters:(NSArray<NSString *> *)possibleCharacters;
- (NSRect)simulatorWindowFrame;
- (NSArray<DDHOverlayElement *> *)overlayChildren;
@end

NS_ASSUME_NONNULL_END
