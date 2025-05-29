//  Created by Dominik Hauser on 29.05.25.
//  
//


#ifndef DDHInfoWindowControllerProtocol_h
#define DDHInfoWindowControllerProtocol_h

@class NSWindowController;

@protocol DDHInfoWindowControllerProtocol <NSObject>
- (void)windowController:(NSWindowController *)windowController processInput:(NSString *)input;
@end

#endif /* DDHInfoWindowControllerProtocol_h */
