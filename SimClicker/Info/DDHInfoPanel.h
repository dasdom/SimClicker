//  Created by Dominik Hauser on 18.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHInfoPanel : NSPanel
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
@property (nonatomic, strong) NSButton *showGridButton;
@property (nonatomic, strong) NSButton *rescanButton;
- (instancetype)initWithContentRect:(NSRect)contentRect;
- (void)updateWithInput:(NSString *)input;
@end

NS_ASSUME_NONNULL_END
