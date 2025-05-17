//  Created by Dominik Hauser on 09.05.25.
//  
//


#import <Cocoa/Cocoa.h>

@interface DDHInfoViewController : NSViewController
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, copy, nullable) void (^inputHandler)(NSString *_Nonnull);
@property (nonatomic, copy, nullable) void (^reloadHandler)(void);
- (void)updateSimulatorPickerWithNames:(NSArray<NSString *> *_Nonnull)names;
- (void)startedScanning;
- (void)stoppedScanning;
@end

