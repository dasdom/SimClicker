//  Created by Dominik Hauser on 29.05.25.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AXRole) {
    AXRoleUnsupported,
    AXRoleAXButton,
    AXRoleAXStaticText,
    AXRoleAXImage,
    AXRoleAXHeading,
    AXRoleToolbar,
    AXRoleMenuBar,
    AXRoleMenuBarItem,
    AXRoleAXRadioButton,
};

@interface DDHRole : NSObject
- (instancetype)initWithName:(NSString *)name;
- (NSString *)code;
- (NSString *)name;
@end

NS_ASSUME_NONNULL_END
