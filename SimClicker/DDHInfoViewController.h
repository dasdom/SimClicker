//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

@interface DDHInfoViewController : NSViewController
@property (nonatomic, copy, nullable) void (^inputHandler)(NSString *_Nonnull);
- (void)updateSimulatorPickerWithNames:(NSArray<NSString *> *_Nonnull)names;
@end

