//  Created by Dominik Hauser on 30.05.25.
//  
//


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHCodeViewController : NSViewController
- (void)updateWithCode:(NSString *)code updateLast:(BOOL)updateLast;
@end

NS_ASSUME_NONNULL_END
